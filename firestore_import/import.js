const admin = require('../cloud/functions/node_modules/firebase-admin');
const serviceAccount = require("./service-key.json");

const data = require("./data.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://debtor-893b0.firebaseio.com"
});

// const firestore = admin.firestore();

data &&
    data.forEach(user => {
        admin
            .firestore()
            .collection('users')
            .add(user);
    });
