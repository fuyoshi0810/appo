import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleList extends StatefulWidget {
  // const ScheduleList({super.key});
  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  @override
  Widget build(BuildContext context) {
    final String g_id = ModalRoute.of(context)?.settings.arguments as String;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userdb = FirebaseFirestore.instance.collection('users');
    final groupdb = FirebaseFirestore.instance.collection('groups');
    final schedb = FirebaseFirestore.instance.collection('schedules');
    var uname;
    return Scaffold(
      appBar: AppBar(),
      body: new StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(g_id)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return new Text("読み込み中…");
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          var userDocument = snapshot.data;

          List<dynamic> sList = snapshot.data!['schedules'];

          if (sList.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Text("予定はありません"),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/c_schedule');
                    },
                    child: const Text("スケジュール作成"),
                  ),
                ],
              ),
            );
          } else {
            return SizedBox(
              // width: 200,
              height: 600,
              child: SingleChildScrollView(
                // child: SizedBox(
                // height: 500,
                child: Column(
                  children: [
                    Text("予定一覧"),
                    SizedBox(
                      height: 500,
                      child: Scrollbar(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: sList.length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: Text(sList[index]['scheduleName']),
                                  ),
                                ],
                              );
                            }),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/c_schedule');
                      },
                      child: const Text("スケジュール作成"),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _messageItem(String title) {
    return Container(
      decoration: new BoxDecoration(
          border:
              new Border(bottom: BorderSide(width: 1.0, color: Colors.grey))),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: Colors.black, fontSize: 18.0),
        ),
        onTap: () {
          print("onTap called.");
        }, // タップ
        onLongPress: () {
          print("onLongTap called.");
        }, // 長押し
      ),
    );
  }
}
