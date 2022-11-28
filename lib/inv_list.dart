import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 招待されているグループ一覧画面
// ログイン画面→グループ選択画面→ここ

class InvList extends StatefulWidget {
  @override
  State<InvList> createState() => _InvListState();
}

class _InvListState extends State<InvList> {
  final userdb = FirebaseFirestore.instance.collection('users');
  final groupdb = FirebaseFirestore.instance.collection('groups');
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    var uname;
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<DocumentSnapshot>(
        // body: new StreamBuilder<DocumentSnapshot>(
        stream:
            // FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
            userdb.doc(uid).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Text("読み込み中…");
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          List<dynamic> iList = snapshot.data!['invList'];
          uname = snapshot.data!['userName'];

          if (iList.isEmpty) {
            return Center(
              child: Column(
                children: const [
                  Text("招待されているグループはありません"),
                ],
              ),
            );
          } else {
            return SizedBox(
              height: 600,
              child: SingleChildScrollView(
                child: Column(children: [
                  const Text("招待されているグループ一覧"),
                  SizedBox(
                    height: 500,
                    child: Scrollbar(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: iList.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(iList[index]['groupName']),
                                ),
                                Expanded(
                                  child: TextButton(
                                      style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.blue)),
                                      onPressed: () {
                                        accept(
                                            iList[index]['groupId'],
                                            iList[index]['groupName'],
                                            uid,
                                            uname);
                                      },
                                      child: const Text("参加")),
                                ),
                                Expanded(
                                  child: TextButton(
                                      style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.red)),
                                      onPressed: () {
                                        delete(
                                            iList[index]['groupId'],
                                            iList[index]['groupName'],
                                            uid,
                                            uname);
                                      },
                                      child: const Text("削除")),
                                ),
                              ],
                            );
                          }),
                    ),
                  )
                ]),
              ),
            );
          }
        },
      ),
    );
  }

  void accept(gid, gname, uid, uname) async {
    await userdb.doc(uid).update({
      // await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'groupList': FieldValue.arrayUnion([
        {'groupId': gid, 'groupName': gname}
      ]),
      'invList': FieldValue.arrayRemove([
        {'groupId': gid, 'groupName': gname}
      ]),
    });

    // await FirebaseFirestore.instance.collection('groups').doc(gid).update({
    await groupdb.doc(gid).update({
      'members': FieldValue.arrayUnion([
        {'userId': uid, 'userName': uname}
      ]),
      'invList': FieldValue.arrayRemove([
        {'userId': uid, 'userName': uname}
      ]),
    });
  }

  void delete(gid, gname, uid, uname) async {
    await userdb.doc(uid).update({
      // await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'invList': FieldValue.arrayRemove([
        {'groupId': gid, 'groupName': gname}
      ])
    });

    await groupdb.doc(gid).update({
      // await FirebaseFirestore.instance.collection('groups').doc(gid).update({
      'invList': FieldValue.arrayRemove([
        {'userId': uid, 'userName': uname}
      ])
    });
  }
}
