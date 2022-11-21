import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({Key? key, required this.onSubmit}) : super(key: key);
  final ValueChanged<String> onSubmit;
  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  @override
  final groupController = TextEditingController();
  final useridController = TextEditingController();
  var members = [];
  var _text = '';

  @override
  void dispose() {
    groupController.dispose();
    super.dispose();
  }

  String? get _errorText {
    // at any time, we can get the text from _controller.value.text
    final text = groupController.value.text;
    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code
    if (text.isEmpty) {
      return '1文字から10文字の間で入力してください';
    }
    // return null if the text is valid
    return null;
  }

  void _addmember(String s) {
    setState(() {
      members.add(s);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("グループ作成"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              maxLength: 10,
              obscureText: false,
              maxLines: 1,
              controller: groupController,
              decoration: InputDecoration(
                hintText: 'グループ名を入力してください',
                labelText: 'グループ名',
                errorText: _errorText,
              ),
              onChanged: (text) => setState(() => _text),
            ),
            // Row(
            //   children: [
            //     Expanded(
            //       flex: 2,
            //       child: TextField(
            //         maxLength: 12,
            //         obscureText: false,
            //         maxLines: 1,
            //         controller: useridController,
            //         decoration: const InputDecoration(
            //           hintText: 'ユーザーidを入力してください',
            //           labelText: 'ユーザー検索',
            //         ),
            //       ),
            //     ),
            //     Expanded(
            //       flex: 1,
            //       child: ElevatedButton(
            //         child: Text("検索"),
            //         onPressed: () {
            //           _addmember(useridController.text);
            //         },
            //       ),
            //     ),
            //   ],
            // ),
            // Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            //   LimitedBox(
            //       maxHeight: 300,
            //       child: ListView.builder(
            //           shrinkWrap: true,
            //           physics: const NeverScrollableScrollPhysics(),
            //           itemCount: members.length,
            //           itemBuilder: (BuildContext context, int index) {
            //             return Container(
            //               child: Center(child: Text(members[index].toString())),
            //             );
            //           }))
            // ]),
            ElevatedButton(
              child: Text("グループ作成"),
              onPressed: groupController.value.text.isNotEmpty ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    // if there is no error text
    if (_errorText == null) {
      // notify the parent widget via the onSubmit callback
      widget.onSubmit(groupController.value.text);

      if (FirebaseAuth.instance.currentUser != null) {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final groupdb = FirebaseFirestore.instance.collection('groups').doc();
        final userbd = FirebaseFirestore.instance.collection('users').doc(uid);
        var userName;

        // await FirebaseFirestore.instance.collection('users').doc(uid).update({
        //   'groupList': FieldValue.arrayUnion([groupController.text]),
        //   'updatedAt': FieldValue.serverTimestamp(),
        // });

        await userbd.get().then(
          (DocumentSnapshot doc) {
            final data = doc.data() as Map<String, dynamic>;

            userName = data['userName'];
          },
          onError: (e) => print("Error getting document: $e"),
        );

        await groupdb.set({
          'admin': [uid],
          'members': FieldValue.arrayUnion([
            {'userId': uid, 'userName': userName + "(管理者)"}
          ]),
          'groupName': groupController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await userbd.update({
          'groupList': FieldValue.arrayUnion([
            {'groupId': groupdb.id, 'groupName': groupController.text}
          ]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      Navigator.pushNamed(context, '/choice_group');
    }
  }
}
