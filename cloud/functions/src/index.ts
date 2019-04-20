import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

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