import 'package:appo/choice_group.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//グループ作成時 サブコレクションも作成するようにする

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
  // ignore: prefer_final_fields
  var _text = '';

  @override
  void dispose() {
    groupController.dispose();
    super.dispose();
  }

  String? get _errorText {
    final text = groupController.value.text;
    if (text.isEmpty) {
      return '1文字から10文字の間で入力してください';
    }
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
        centerTitle: true,
        title: const Text("グループ作成"),
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
            ElevatedButton(
              onPressed: groupController.value.text.isNotEmpty ? _submit : null,
              child: const Text("グループ作成"),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_errorText == null) {
      widget.onSubmit(groupController.value.text);

      if (FirebaseAuth.instance.currentUser != null) {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final groupdb = FirebaseFirestore.instance.collection('groups').doc();
        final userbd = FirebaseFirestore.instance.collection('users').doc(uid);
        var userName;

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
            {
              'userId': uid,
              'userName': userName + "(管理者)",
              "lat": "",
              "lng": ""
            }
          ]),
          'schedules': FieldValue.arrayUnion([]),
          'groupName': groupController.text,
          'invList': [],
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

      Navigator.pop(context);
    }
  }
}
