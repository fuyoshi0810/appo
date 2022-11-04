import 'package:flutter/material.dart';

class C_Schedule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("スケジュール作成画面"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(DateTime.now().toString()),
                ElevatedButton(onPressed: () {}, child: Text("日付を選択")),
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/s_list');
                },
                child: Text("スケジュール保存")),
          ],
        ),
      ),
    );
  }
}
