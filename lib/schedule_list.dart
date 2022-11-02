import 'package:flutter/material.dart';

class S_list extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("スケジュール一覧画面"),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/c_schedule');
                },
                child: Text("スケジュール作成")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/map');
                },
                child: Text("マップ")),
          ],
        ),
      ),
    );
  }
}
