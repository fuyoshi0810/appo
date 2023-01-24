/* eslint-disable camelcase */

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
const recRef = db.collection("groups");
// const recRef = db.collection("test");
// const today = new Date();
                                           // 大阪
// exports.deleteSchedule = functions.region("asia-northeast2").pubsub.schedule("*/3 * * * *").onRun((_) => {
// 12時間ごとに実行
exports.deleteSchedule = functions.region("asia-northeast2").pubsub.schedule("0 */12 * * *").timeZone("Asia/Tokyo").onRun(async (context) => {
  // today.getTime()で比較する
  // recRef.where("groupName", "in", ["限界集落", "002"]).get()

  let now = new Date();
  let milli_now = now.getTime();
  // console.log(now.getTime()); // 1654525795212
  let collection = await recRef.get();
  collection.forEach(async doc => {
    // console.log(doc.data());
    functions.logger.info("ここまできた"+milli_now, {structuredData: true});
    // let subCollection = await doc.ref.collection("schedules").get();
    let subCollection = await doc.ref.collection("schedules");
    functions.logger.info("ここまできた2"+milli_now, {structuredData: true});
    
    subCollection.where("meetingTime", "<", milli_now).get()
    .then(snapshot => {
      if(snapshot.empty){
        functions.logger.info("ドキュメントなし"+milli_now, {structuredData: true});
      }
      snapshot.forEach(async doc2 => {
        await doc2.ref.delete();
        functions.logger.info("現在時刻"+milli_now, {structuredData: true});
      });
    })
    .catch(err => {
      functions.logger.info("エラー", {structuredData: true});
    });
  });

  // recRef.where("time", "<", milli_now).get()
  // .then(snapshot => {
  //   if(snapshot.empty){
  //     functions.logger.info("ドキュメントなし", {structuredData: true});
  //     // return { groupName:"なし" }
  //   }
  //   snapshot.forEach(async doc => {
  //   // snapshot.forEach(doc => {
  //     // doc.ref.update({"a":"a"});
  //     await doc.ref.delete();
  //     functions.logger.info("スナップショット長さ"+snapshot.docs.length, {structuredData: true});
  //     // return { groupName: snapshot}
  //     // return { groupName: milli_now.toString()}
  //   });
  // })
  // .catch(err => {
  //   // console.log("エラー",err);
  //   functions.logger.info("エラー", {structuredData: true});
  // });
 })

exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

