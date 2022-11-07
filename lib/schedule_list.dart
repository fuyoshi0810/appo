import 'package:flutter/material.dart';

class ScheduleList extends StatelessWidget {
  const ScheduleList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("スケジュール一覧画面"),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/c_schedule');
                },
                child: const Text("スケジュール作成")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/map');
                },
                child: const Text("マップ")),
          ],
        ),
      ),
    );
  }
}
