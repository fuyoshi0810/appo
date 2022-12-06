import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Invite extends StatefulWidget {
  const Invite({Key? key, required this.onSubmit}) : super(key: key);
  final ValueChanged<String> onSubmit;
  @override
  State<Invite> createState() => _InviteState();
}

class _InviteState extends State<Invite> {
  final userdb = FirebaseFirestore.instance.collection('users');
  final groupdb = FirebaseFirestore.instance.collection('groups');
  final useridController = TextEditingController();
  var invList = [];
  var _text = "招待済み一覧";

  @override
  void dispose() {
    useridController.dispose();
    super.dispose();
  }

  String? get _errorText {
    // at any time, we can get the text from _controller.value.text
    final text = useridController.value.text;
    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code
    if (text.length == 12) {
      return null;
    }
    // return null if the text is valid
    return '12文字で入力してください';
  }

  void _addmember(String s) {
    setState(() {
      invList.add(s);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String g_id = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("招待リスト"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            groupdb.doc(g_id).snapshots(), //returns a Stream<DocumentSnapshot>
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
            return const Text("Loading");
          }
          var userDocument = snapshot.data;
          // return new Text(userDocument!["userName"]);

          List<dynamic> invList = snapshot.data!["invList"];

          if (invList.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          maxLength: 12,
                          obscureText: false,
                          maxLines: 1,
                          controller: useridController,
                          decoration: InputDecoration(
                            hintText: 'ユーザーidを入力してください',
                            labelText: 'ユーザー検索',
                            errorText: _errorText,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          child: const Text("招待"),
                          onPressed: () {
                            if (useridController.value.text.length == 12) {
                              _submit(g_id);
                              // _addmember(useridController.text);
                            } else {
                              null;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const Text("招待している人はいません"),
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
                child: Column(children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          maxLength: 12,
                          obscureText: false,
                          maxLines: 1,
                          controller: useridController,
                          decoration: InputDecoration(
                            hintText: 'ユーザーidを入力してください',
                            labelText: 'ユーザー検索',
                            errorText: _errorText,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          child: const Text("検索"),
                          onPressed: () {
                            if (useridController.value.text.length == 12) {
                              _submit(g_id);
                              // _addmember(useridController.text);
                            } else {
                              null;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Text(_text),
                  SizedBox(
                    height: 500,
                    child: Scrollbar(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: invList.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Expanded(
                                    child: Text(invList[index]['userName'])),
                                Expanded(
                                    child: TextButton(
                                        style: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.red)),
                                        onPressed: () {
                                          delete(invList[index]['userId'],
                                              invList[index]['userName'], g_id);
                                        },
                                        child: const Text("削除")))
                              ],
                            );
                          }),
                    ),
                  )
                ]),
              ),
            );

            // return SingleChildScrollView(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       SizedBox(
            //         height: 500,
            //         child: Scrollbar(
            //           child: ListView.builder(
            //             shrinkWrap: true,
            //             itemCount: vocabulary.length,
            //             itemBuilder: (context, index) => ListTile(
            //               title: Text(vocabulary[index].toString()),
            //               onTap: (() {
            //                 print(vocabulary.length);
            //                 Navigator.pushNamed(context, '/g_menu',
            //                     arguments: vocabulary[index]);
            //               }),
            //             ),
            //           ),
            //         ),
            //       ),
            //       TextButton(
            //         child: Text("グループ作成"),
            //         onPressed: () {
            //           Navigator.pushNamed(context, '/c_group');
            //         },
            //       ),
            //     ],
            //   ),
            // );
          }
        },
      ),

      // body: Center(
      //   child: SizedBox(
      //     // width: 200,
      //     height: 600,
      //     child: SingleChildScrollView(
      //       // child: SizedBox(
      //       // height: 500,
      //       child: Column(children: [
      //         Row(
      //           children: [
      //             Expanded(
      //               flex: 2,
      //               child: TextField(
      //                 keyboardType: TextInputType.number,
      //                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      //                 maxLength: 12,
      //                 obscureText: false,
      //                 maxLines: 1,
      //                 controller: useridController,
      //                 decoration: InputDecoration(
      //                   hintText: 'ユーザーidを入力してください',
      //                   labelText: 'ユーザー検索',
      //                   errorText: _errorText,
      //                 ),
      //               ),
      //             ),
      //             Expanded(
      //               flex: 1,
      //               child: ElevatedButton(
      //                 child: Text("検索"),
      //                 onPressed: () {
      //                   if (useridController.value.text.length == 12) {
      //                     _submit(g_id);
      //                     // _addmember(useridController.text);
      //                   } else {
      //                     null;
      //                   }
      //                 },
      //               ),
      //             ),
      //           ],
      //         ),
      //         SizedBox(
      //           height: 500,
      //           child: Scrollbar(
      //             child: ListView.builder(
      //               shrinkWrap: true,
      //               itemCount: invList.length,
      //               itemBuilder: (context, index) => ListTile(
      //                 title: Text(invList[index]),
      //               ),
      //             ),
      //           ),
      //         )
      //       ]),
      //     ),
      //   ),
      // ),
    );
  }

  void delete(id, name, g) async {
    var groupRef = await groupdb.doc(g).get();
    var groupdata =
        groupRef.exists ? groupRef.data() : null; // `data()`で中身を取り出す
    userdb.doc(id).update({
      'invList': FieldValue.arrayRemove([
        {'groupId': g, 'groupName': groupdata!['groupName']}
      ])
    });

    groupdb.doc(g).update({
      'invList': FieldValue.arrayRemove([
        {'userId': id, 'userName': name}
      ])
    });
  }

  void _submit(g) async {
    if (_errorText == null) {
      widget.onSubmit(useridController.value.text);

      final groupdoc = groupdb.doc(g);
      var uDocId = '';
      var uname = 'aaaaaa';

      // var invp =
      await userdb.where('userId', isEqualTo: useridController.text).get().then(
            (QuerySnapshot snapshot) => {
              snapshot.docs.forEach((f) {
                uDocId = f.reference.id;
                uname = f['userName'];
                print('userNameis' + uname);
                print("documentID---- " + f.reference.id);
              }),
            },
          );

      if (uDocId == '') {
        print("nulllll");
      } else {
        print('nullじゃない');
      }

      var groupRef = await groupdoc.get();
      var groupdata =
          groupRef.exists ? groupRef.data() : null; // `data()`で中身を取り出す
      print("グループ名" + groupdata!['groupName']);

      await userdb.doc(uDocId).update({
        'invList': FieldValue.arrayUnion([
          {'groupId': g, 'groupName': groupdata['groupName']}
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await groupdoc.update({
        'invList': FieldValue.arrayUnion([
          {'userId': uDocId, 'userName': uname}
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await groupdoc.get().then(
        (DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          invList = data['invList'];
        },
        onError: (e) => print("Error getting document: $e"),
      );
      print("リスト" + invList.toString());
      _text = "招待を送りました";
    }
  }
}
