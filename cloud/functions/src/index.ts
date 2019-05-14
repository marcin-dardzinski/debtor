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



export const updateBalances = functions.firestore.document('events/{eventId}').onWrite(async (change, ctx) => {
    type AmountCombiner = (a: number, b: number) => number;
    const add: AmountCombiner = (a, b) => a + b;
    const subtract: AmountCombiner = (a, b) => a - b;

    const getCurrentAmount = (doc: DocumentSnapshot) => {
        const data = doc.data();
        return data && data['amount'] as number || 0;
    }

    const updateExpense = async (expense: any, payerComb: AmountCombiner, borrowerComb: AmountCombiner) => {
        const payer = expense['payer'] as DocumentReference;
        const borrower = expense['borrower'] as DocumentReference;
        const amount = expense['amount'] as number;

        const payerId = payer.id;
        const borrowerId = borrower.id;

        const payerBalancesRef = payer.collection('balances').doc(borrowerId);
        const borrowerBalancesRef = borrower.collection('balances').doc(payerId);
        const payerBalances = await payerBalancesRef.get();
        const borrowerBalances = await borrowerBalancesRef.get();

        const newPayer = payerComb(getCurrentAmount(payerBalances), amount);
        const newBorrower = borrowerComb(getCurrentAmount(borrowerBalances), amount);

        await payerBalancesRef.set({ amount: newPayer });
        await borrowerBalancesRef.set({ amount: newBorrower });
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



// function getFriends(user: FirebaseFirestore.DocumentData) {
//     if (!user) {
//         return undefined;
//     }
//     const friends = user['friends'] as string[];
//     if (!friends) {
//         return undefined;
//     }
//     return new Set(friends);
// }

// export const addFriendRelationShips = functions.firestore.document('users/{userId}').onUpdate(async (user, context) => {
//     const newFriends = getFriends(user.after);
//     const oldFriends = getFriends(user.before);

//     if (!newFriends || !oldFriends) {
//         return;
//     }

//     let added = [...newFriends].filter(x => !oldFriends.has(x));
//     let removed = [...oldFriends].filter(x => !newFriends.has(x));

//     added.map()






// });