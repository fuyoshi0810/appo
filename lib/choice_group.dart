import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChoiceGroup extends StatefulWidget {
  const ChoiceGroup({super.key});

  @override
  State<ChoiceGroup> createState() => _ChoiceGroupState();
}

class _ChoiceGroupState extends State<ChoiceGroup> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final userdb = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('グループ一覧'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: '招待グループ一覧',
            onPressed: () {
              Navigator.pushNamed(context, '/inv_list');
            },
          ),
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
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            userdb.doc(uid).snapshots(), //returns a Stream<DocumentSnapshot>
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text("読み込み中…"),
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("読み込み中…");
          }

          List<dynamic> groupList = snapshot.data!["groupList"];

          if (groupList.isEmpty) {
            return Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 500,
                    child: Text("表示可能なグループはありません"),
                  ),
                  TextButton(
                    child: const Text("グループ作成"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/c_group');
                    },
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 500,
                    child: Scrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: groupList.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(groupList[index]['groupName'].toString()),
                          onTap: (() {
                            Navigator.pushNamed(context, '/g_menu',
                                arguments: groupList[index]['groupId']);
                          }),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    child: const Text("グループ作成"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/c_group');
                    },
                  ),
                ],
              ),
            );
          }

          // return ListView.builder(
          //   itemBuilder: (BuildContext context, int index) {
          //     return Container(
          //         decoration: BoxDecoration(
          //           border: Border(
          //             bottom: BorderSide(color: Colors.black38),
          //           ),
          //         ),
          //         child: ListTile(onTap: () {
          //           print(vocabulary);
          //         }));
          //   },
          // );
        },
      ),
    );
  }
}
  // ),
        // });
  // }