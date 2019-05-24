import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DocumentReference, DocumentSnapshot } from '@google-cloud/firestore';

admin.initializeApp();
const db = admin.firestore();

export const addUserToFirestore = functions.auth.user().onCreate((user, ctx) => {
    const { uid, email, displayName, photoURL } = user;

    return db
        .collection('users')
        .doc(uid)
        .set({ email, name: displayName, avatar: photoURL })
        .catch(console.error);
});


export const addFriend = functions.https.onCall(async (request, ctx) => {
    const caller = ctx.auth && ctx.auth.uid;
    const toAdd = request.friend as string;
    if (!caller || !toAdd) {
        return;
    }

    const users = db.collection('users');
    const callerUser = users.doc(caller);
    const toAddUser = users.doc(toAdd);

    await callerUser.set({ friends: [toAddUser] }, { merge: true })
    await toAddUser.set({ friends: [callerUser] }, { merge: true })
});



export const updateBalancesOnEventAdded = functions.firestore.document('events/{eventId}').onWrite(async (change, ctx) => {
    type AmountCombiner = (a: number, b: number) => number;
    const add: AmountCombiner = (a, b) => a + b;
    const subtract: AmountCombiner = (a, b) => a - b;

    const getCurrentAmount = (doc: DocumentSnapshot, currency: string) => {
        const data = doc.data();
        return data && data['amount'] && data['amount']['currency'] || 0;
    }

    const updateExpense = async (expense: any, payerComb: AmountCombiner, borrowerComb: AmountCombiner) => {
        const payer = expense['payer'] as DocumentReference;
        const borrower = expense['borrower'] as DocumentReference;
        const amount = expense['amount'] as number;
        const currency = expense['currency'] as string;

        const payerId = payer.id;
        const borrowerId = borrower.id;

        const payerBalancesRef = payer.collection('balances').doc(borrowerId);
        const borrowerBalancesRef = borrower.collection('balances').doc(payerId);
        const payerBalances = await payerBalancesRef.get();
        const borrowerBalances = await borrowerBalancesRef.get();

        const newPayer = payerComb(getCurrentAmount(payerBalances, currency), amount);
        const newBorrower = borrowerComb(getCurrentAmount(borrowerBalances, currency), amount);
        const key = `amount.${currency}`;

        await payerBalancesRef.set({ [key]: newPayer }, { merge: true });
        await borrowerBalancesRef.set({ [key]: newBorrower }, { merge: true });
    };

    const revertExpense = (expense: any) => updateExpense(expense, subtract, add);
    const addExpense = (expense: any) => updateExpense(expense, add, subtract);

    const deleted = change.before && change.before.data();
    const added = change.after && change.after.data();

    if (deleted) {
        for (const expense of deleted['expenses']) {
            await revertExpense(expense);
        }
    }

    if (added) {
        for (const expense of added['expenses']) {
            await addExpense(expense);
        }
    }
});

export const updateBalancesOnPayment = functions.firestore.document('payments/{paymentId}').onCreate(async (snap, ctx) => {
    const data = snap.data();
    if (!data) {
        return;
    }

    const payerRef = data['payer'] as DocumentReference;
    const recipientRef = data['recipient'] as DocumentReference;
    const amount = data['amount'] as number;
    const currency = data['currency'] as string;

    const update = async (user: DocumentReference, friend: DocumentReference, change: number, cur: string) => {
        const balanceRef = user.collection('balances').doc(friend.id);
        const balance = (await balanceRef.get()).data();
        const newAmount = change + (balance && balance['amount'] && balance['amount'][cur] as number || 0);
        await balanceRef.set({ [`amount.${cur}`]: newAmount }, { merge: true })
    };

    await update(payerRef, recipientRef, amount, currency);
    await update(recipientRef, payerRef, -amount, currency);
});