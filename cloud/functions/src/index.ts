import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

export const addUserToFirestore = functions.auth.user().onCreate((user, ctx) => {
    const { uid, email, displayName, photoURL } = user;

    return db
        .collection('users')
        .doc(uid)
        .set({ email, displayName, avatar: photoURL })
        .catch(console.error);
});
