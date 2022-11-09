import 'package:flutter/material.dart';

class GroupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('グループ画面'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("グループ画面"),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/s_list');
                },
                child: Text("スケジュール一覧")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/map');
                },
                child: Text("マップ")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/s_group');
                },
                child: Text("メンバー")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/choice_group");
                },
                child: Text("グループから抜ける"))
          ],
        ),
      ),
    );
  }
}
