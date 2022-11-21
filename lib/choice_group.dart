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
    final uid = FirebaseAuth.instance.currentUser!.uid;

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
      body: new StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(), //returns a Stream<DocumentSnapshot>
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
          // return new Text(userDocument!["userName"]);

          List<dynamic> vocabulary = snapshot.data!["groupList"];

          if (vocabulary.isEmpty) {
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
                        itemCount: vocabulary.length,
                        itemBuilder: (context, index) => ListTile(
                          title:
                              Text(vocabulary[index]['groupName'].toString()),
                          onTap: (() {
                            print(vocabulary.length);
                            Navigator.pushNamed(context, '/g_menu',
                                arguments: vocabulary[index]['groupId']);
                          }),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    child: Text("グループ作成"),
                    onPressed: () {
                      // initState();
                      // print(groupList.toString());
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




  //     List<DocumentSnapshot> vocabulary = snapshot.data!.docs;
  //     return ListView.builder(
  //       itemBuilder: (BuildContext context, int index) {
  //         if (index == 0) {
  //           return Container(
  //             width: 375,
  //             height: 60,
  //             decoration: new BoxDecoration(
  //                 color: Color(0xff098a8c),
  //                 border: Border.all(color: Color(0xff098a8c), width: 1)),
  //             child: InkWell(
  //               onTap: () {
  //                 showDialog(
  //                     context: context,
  //                     builder: (context) {
  //                       return AlertDialog(
  //                         title: Text("単語名"),
  //                         content: TextField(
  //                           decoration:
  //                               InputDecoration(hintText: "単語名を入力してください"),
  //                           onChanged: (value) {
  //                             WordName = value;
  //                           },
  //                         ),
  //                         actions: <Widget>[
  //                           // ボタン領域
  //                           FlatButton(
  //                             child: Text("キャンセル"),
  //                             onPressed: () => Navigator.pop(context),
  //                           ),
  //                           FlatButton(
  //                             child: Text("追加"),
  //                             onPressed: () async {
  //                               if (WordName != null) {
  //                                 await FirebaseFirestore.instance
  //                                     .collection('users')
  //                                     .doc('d0Etsd7V1eU0TkK0kAAjpIeVKFk1')
  //                                     .collection('note')
  //                                     .doc(NoteName)
  //                                     .collection('word')
  //                                     .doc(WordName)
  //                                     .set({
  //                                   'WordName': WordName,
  //                                   'date': Timestamp.now()
  //                                 });
  //                                 Navigator.pop(context);
  //                               } else {}
  //                             },
  //                           ),
  //                         ],
  //                       );
  //                     });
  //               },
  //               child: Container(
  //                 // margin: EdgeInsets.only(right: 10, bottom: 10),
  //                 child: Row(crossAxisAlignment: CrossAxisAlignment.center,
  //                     // verticalDirection: VerticalDirection.up,
  //                     // textDirection: TextDirection.rtl,
  //                     children: [
  //                       TextButton(
  //                         onPressed: () {
  //                           showDialog(
  //                               context: context,
  //                               builder: (context) {
  //                                 return AlertDialog(
  //                                   title: Text("ノート名"),
  //                                   content: TextField(
  //                                     decoration: InputDecoration(
  //                                         hintText: "ノート名を入力してください"),
  //                                     onChanged: (value) {
  //                                       WordName = value;
  //                                     },
  //                                   ),
  //                                   actions: <Widget>[
  //                                     // ボタン領域
  //                                     FlatButton(
  //                                       child: Text("キャンセル"),
  //                                       onPressed: () =>
  //                                           Navigator.pop(context),
  //                                     ),
  //                                     FlatButton(
  //                                       child: Text("追加"),
  //                                       onPressed: () async {
  //                                         if (WordName != null) {
  //                                           await FirebaseFirestore.instance
  //                                               .collection('users')
  //                                               .doc(
  //                                                   'd0Etsd7V1eU0TkK0kAAjpIeVKFk1')
  //                                               .collection('note')
  //                                               .doc(NoteName)
  //                                               .collection('word')
  //                                               .doc(WordName)
  //                                               .set({
  //                                             'WordName': WordName,
  //                                             'date': Timestamp.now()
  //                                           });
  //                                           Navigator.pop(context);
  //                                         } else {}
  //                                       },
  //                                     ),
  //                                   ],
  //                                 );
  //                               });
  //                         },
  //                         child: Text(
  //                           '単語を追加',
  //                           style: TextStyle(
  //                             fontFamily: 'SFProDisplay',
  //                             color: Color(0xffffffff),
  //                             fontSize: 30,
  //                             fontWeight: FontWeight.w400,
  //                             fontStyle: FontStyle.normal,
  //                             letterSpacing: 0.0075,
  //                           ),
  //                           textAlign: TextAlign.center,
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                       ),
  //                     ]),
  //               ),
  //             ),
  //           );
  //         }

  //         return Container(
  //             decoration: BoxDecoration(
  //               border: Border(
  //                 bottom: BorderSide(color: Colors.black38),
  //               ),
  //             ),
  //             child: ListTile(
  //               trailing: IconButton(
  //                 icon: Icon(Icons.delete),
  //                 onPressed: () {
  //                   _index = index - 1;
  //                   showDialog(
  //                       context: context,
  //                       builder: (context) {
  //                         return AlertDialog(
  //                           title: Text(
  //                               vocabulary[_index!]['WordName'].toString() +
  //                                   'を削除しますか？'),
  //                           actions: <Widget>[
  //                             // ボタン領域
  //                             FlatButton(
  //                               child: Text("いいえ"),
  //                               onPressed: () => Navigator.pop(context),
  //                             ),
  //                             FlatButton(
  //                                 child: Text("はい"),
  //                                 onPressed: () async {
  //                                   await FirebaseFirestore.instance
  //                                       .collection('users')
  //                                       .doc('d0Etsd7V1eU0TkK0kAAjpIeVKFk1')
  //                                       .collection('note')
  //                                       .doc(NoteName)
  //                                       .collection('word')
  //                                       .doc(vocabulary[_index!].id)
  //                                       .delete();
  //                                   Navigator.pop(context);
  //                                 }),
  //                           ],
  //                         );
  //                       });
  //                 },
  //               ),
  //               title: Text(
  //                 vocabulary[index - 1]['WordName'].toString(),
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //               onTap: () {
  //                 // Navigator.pushNamed(context, '/word',
  //                 //     arguments:
  //                 //         vocabulary[index - 1]['WordName'].toString());
  //                 Navigator.pushNamed(context, '/word', arguments: {
  //                   'Note': NoteName,
  //                   // 'Word': vocabulary[index - 1]['WordName'].toString()
  //                   'Word': vocabulary[index - 1].id.toString()
  //                 });
  //               },
  //             ));
  //       },
  //       itemCount: vocabulary.length + 1,
  //     );
  //   },
  // ),

  // body: Center(
  //   // child: Expanded(
  //   // child: StreamBuilder(
  //   // stream: users
  //   //     .doc(uid)
  //   //     .get()
  //   // .collection('comments')
  //   // .orderBy(
  //   //   'datePublished',
  //   //   descending: true,
  //   // )
  //   // .snapshots(),
  //   // builder: (context,
  //   //     AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
  //   //   if (snapshot.connectionState == ConnectionState.waiting) {
  //   //     return const Center(
  //   //       child: CircularProgressIndicator(),
  //   //     );
  //   //   }
  //   //   return ListView.builder(
  //   //       itemCount: snapshot.data!.docs.length,
  //   //       itemBuilder: (ctx, index) => CommentCard(
  //   //             snap: snapshot.data!.docs[index],
  //   //           ));
  //   // }),
  //   // ),

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
  //                 onTap: (() {
  //                   Navigator.pushNamed(context, '/g_menu');
  //                 }),
  //               ),
  //             ),
  //           ),
  //         ),
  //         TextButton(
  //           child: Text("グループ作成"),
  //           onPressed: () {
  //             // print("ああああ");
  //             // print(a[0]);
  //             initState();
  //             print(groupList.toString());
  //             // Navigator.pushNamed(context, '/c_group');
  //           },
  //         ),
  //       ],
  //     ),
  //   ),
  // ),
  // );
// }
// }



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