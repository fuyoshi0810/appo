import 'package:appo/choice_group.dart';
import 'package:appo/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_webservice/directions.dart';

//groups:サブコレクションがあると削除できない

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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LogInPage()),
              );
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
          if (value2['groupList'][i]['groupId'] == g_id) {
            userdb.doc(uid).update({
              'groupList': FieldValue.arrayRemove([
                {
                  'groupId': g_id,
                  'groupName': value2['groupList'][i]['groupName']
                }
              ]),
            });
          }
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );

    await groupdb.doc(g_id).get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        id = doc.id;

        for (int i = 0; i < data['members'].length; i++) {
          if (data['members'][i]['userId'] == uid) {
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
        }

        Future.delayed(Duration(seconds: 5));
        if (data['members'].length == 1 && data['invList'].length == 0) {
          groupdb.doc(g_id).delete();
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }
}
