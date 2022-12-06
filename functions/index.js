// const functions = require("firebase-functions");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
const functions = require("firebase-functions");

// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");
// admin.initializeApp();
admin.initializeApp(functions.config().firebase);

const db = admin.firestore();
const recRef = db.collection("a");
const today = new Date();
                                           // 大阪
exports.deleteSchedule = functions.region("asia-northeast2")
// 15分ごとに実行
 .pubsub.schedule("*/15 * * * *").onRun((_) => {
  // today.getTime()で比較する
  recRef.where("a", "<", today).get()
  .then(snapshot => {
    if(snapshot.empty){
      console.log("ドキュメントなし");
      return;
    }
    snapshot.forEach(doc => {
      doc.ref.update({"a":"a"});
    });
  })
  .catch(err => {
    console.log("エラー",err);
  });
 })

exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

