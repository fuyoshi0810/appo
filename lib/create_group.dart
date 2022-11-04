import 'package:flutter/material.dart';

class CreateGroup extends StatelessWidget {
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
            const TextField(
              maxLength: 10,
              style: TextStyle(color: Colors.red),
              obscureText: false,
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: 'グループ名を入力してください',
                labelText: 'グループ名 *',
              ),
            ),
            ElevatedButton(
              child: Text("メンバー"),
              onPressed: () {
                Navigator.pushNamed(context, '/c_group');
              },
            ),
            ElevatedButton(
              child: Text("グループ作成"),
              onPressed: () {
                Navigator.pushNamed(context, '/c_group');
              },
            )
          ],
        ),
      ),
    );
  }
}
