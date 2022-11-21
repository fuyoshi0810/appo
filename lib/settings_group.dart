import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String g_id = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text("メンバー一覧"),
      ),
      body: new StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(g_id)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return new Text("Loading!");
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          var userDocument = snapshot.data;

          List<dynamic> members = snapshot.data!["members"];

          if (members.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Text("表示可能なグループはありません"),
                  TextButton(
                    child: Text("グループ作成"),
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
                          onTap: (() {
                            print(members.length);
                            // Navigator.pushNamed(context, '/g_menu',
                            //     arguments: members[index]['groupId']);
                          }),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    child: Text("招待"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/invite');
                    },
                  ),
                  TextButton(
                    child: Text("解散"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/invite');
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),

      // body: Center(
      //   // SizedBox(
      //   // height: 500,
      //   child: SingleChildScrollView(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: <Widget>[
      //         SizedBox(
      //           height: 500,
      //           child: Scrollbar(
      //             child: ListView.builder(
      //               shrinkWrap: true,
      //               itemCount: 30,
      //               itemBuilder: (context, index) => ListTile(
      //                 title: Text("item ${index + 1}"),
      //               ),
      //             ),
      //           ),
      //         ),

      //         // )

      //         TextButton(
      //           child: Text("招待"),
      //           onPressed: () {
      //             Navigator.pushNamed(context, '/invite');
      //           },
      //         ),
      //         TextButton(
      //           child: Text("解散"),
      //           onPressed: () {
      //             Navigator.pushNamed(context, '/invite');
      //           },
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
