import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChoiceGroup extends StatefulWidget {
  @override
  State<ChoiceGroup> createState() => _ChoiceGroupState();
}

class _ChoiceGroupState extends State<ChoiceGroup> {
  @override
  Widget build(BuildContext context) {
    var groupList = [];

    @override
    void initState() async {
      print("MyHomePage画面が表示されました。");
      // final users = FirebaseFirestore.instance.collection('users');
      // DocumentSnapshot snapshot =
      //     await users.doc(FirebaseAuth.instance.currentUser!.uid).get();
      // print(snapshot.data()['email']);
      // FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(FirebaseAuth.instance.currentUser!.uid)
      //     .get()
      //     .then((DocumentSnapshot snapshot) {
      //   a = snapshot.get('groupList');
      final docRef = FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid);
      docRef.get().then(
        (DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          groupList = data['groupList'];
        },
        onError: (e) => print("Error getting document: $e"),
      );
      // });

      // super.initState();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('グループ選択'),
      ),
      body: Center(
        // child: Expanded(
        // child: StreamBuilder(
        // stream: users
        //     .doc(uid)
        //     .get()
        // .collection('comments')
        // .orderBy(
        //   'datePublished',
        //   descending: true,
        // )
        // .snapshots(),
        // builder: (context,
        //     AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        //   if (snapshot.connectionState == ConnectionState.waiting) {
        //     return const Center(
        //       child: CircularProgressIndicator(),
        //     );
        //   }
        //   return ListView.builder(
        //       itemCount: snapshot.data!.docs.length,
        //       itemBuilder: (ctx, index) => CommentCard(
        //             snap: snapshot.data!.docs[index],
        //           ));
        // }),
        // ),

        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 500,
                child: Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 30,
                    itemBuilder: (context, index) => ListTile(
                      title: Text("item ${index + 1}"),
                      onTap: (() {
                        Navigator.pushNamed(context, '/g_menu');
                      }),
                    ),
                  ),
                ),
              ),
              TextButton(
                child: Text("グループ作成"),
                onPressed: () {
                  // print("ああああ");
                  // print(a[0]);
                  initState();
                  print(groupList.toString());
                  // Navigator.pushNamed(context, '/c_group');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// body: SingleChildScrollView(
      //     child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: <Widget>[
      //       const TextField(
      //         maxLength: 10,
      //         style: TextStyle(color: Colors.red),
      //         obscureText: false,
      //         maxLines: 1,
      //         decoration: InputDecoration(
      //           hintText: 'グループ名を入力してください',
      //           labelText: 'グループ名 *',
      //         ),
      //       ),
      //       ElevatedButton(child: const Text("検索"), onPressed: () {}),
      //       SizedBox(
      //         width: 100,
      //         height: 400,
      //         child: ListView.builder(
      //           itemCount: items.length,
      //           itemBuilder: (context, index) {
      //             return ListTile(
      //               title: Text('${items[index]}'),
      //               onTap: () {
      //                 Navigator.pushNamed(context, '/g_menu');
      //               },
      //             );
      //           },
      //         ),
      //       ),

      //     ])),