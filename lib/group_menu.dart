import 'package:appo/choice_group.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_webservice/directions.dart';

//groups:サブコレクションがあると削除できない？
//users:invList削除

class GroupMenu extends StatelessWidget {
  const GroupMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final String g_id = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('グループメニュー'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // ignore: use_build_context_synchronously
              Navigator.pushNamed(context, '/');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/s_list', arguments: g_id);
                  },
                  child: const Text("スケジュール一覧")),
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/map', arguments: g_id);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => Map("g_id": g_id)),
                    // );
                  },
                  child: const Text("マップ")),
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/s_group', arguments: g_id);
                  },
                  child: const Text("メンバー")),
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    leaveGroup(g_id);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const ChoiceGroup(),
                      ),
                    );
                  },
                  child: const Text("グループから抜ける")),
            ),
          ],
        ),
      ),
    );
  }

  void leaveGroup(g_id) async {
    final db = FirebaseFirestore.instance;
    final groupdb = db.collection('groups');
    final userdb = db.collection('users');
    final uid = FirebaseAuth.instance.currentUser!.uid;
    var invList = [];
    var id;

    await userdb.doc(uid).get().then(
      (value) {
        var value2 = value.data();
        print("ここからユーザー");
        for (int i = 0; i < value2!['groupList'].length; i++) {
          // invList.add(data['invList'][i]['userId']);
          if (value2['groupList'][i]['groupId'] == g_id) {
            print("メンバー一致" + i.toString());
            userdb.doc(uid).update({
              'groupList': FieldValue.arrayRemove([
                {
                  'groupId': g_id,
                  'groupName': value2['groupList'][i]['groupName']
                }
              ]),
            });
          }
          // print(invList);
          print("一致してない" + i.toString());
          print(value2['groupList'][i]['groupId']);
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );

    await groupdb.doc(g_id).get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        // print(doc.id);
        print("ここからグループ");
        print(uid);
        id = doc.id;
        // print("りーぶぐる");
        // print(data);
        // print("あ");
        // print(data['invList'][0]['userId']);
        // if (data['invList'].length != 0) {
        //   for (int i = 0; i < data['invList'].length; i++) {
        //     // invList.add(data['invList'][i]['userId']);
        //     if (data['invList'][i]['userId'] == uid) {
        //       print("一致" + i.toString());
        //     }
        //     // print(invList);
        //     print("一致してない" + i.toString());
        //     print(data['invList'][i]['userId']);
        //   }
        // }

        for (int i = 0; i < data['members'].length; i++) {
          // invList.add(data['invList'][i]['userId']);
          if (data['members'][i]['userId'] == uid) {
            print("メンバー一致" + i.toString());
            groupdb.doc(g_id).update({
              'members': FieldValue.arrayRemove([
                {
                  'lat': data['members'][i]['lat'],
                  'lng': data['members'][i]['lng'],
                  'userId': data['members'][i]['userId'],
                  'userName': data['members'][i]['userName']
                }
              ]),
            });
          }
          // print(invList);
          print("一致してない" + i.toString());
          print(data['members'][i]['userId']);
        }

        Future.delayed(Duration(seconds: 5));
        print("長さ" + data['members'].length.toString());
        print(data['invList'].length.toString());
        if (data['members'].length == 1 && data['invList'].length == 0) {
          groupdb.doc(g_id).delete();
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }
}
