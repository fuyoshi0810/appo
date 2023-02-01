import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final String g_id = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("メンバー一覧"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(g_id)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Text("読み込み中…");
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("読み込み中…");
          }
          var userDocument = snapshot.data;

          List<dynamic> members = snapshot.data!["members"];

          if (members.isEmpty) {
            return Center(
              child: Column(
                children: [
                  const Text("表示可能なグループはありません"),
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
                        itemCount: members.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(members[index]['userName'].toString()),
                          onTap: (() {}),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    child: const Text("招待"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/invite', arguments: g_id);
                    },
                  ),
                  TextButton(
                    child: const Text("解散"),
                    onPressed: () {},
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
