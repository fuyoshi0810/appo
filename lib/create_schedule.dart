import 'package:flutter/material.dart';

class CreateSchedule extends StatelessWidget {
  const CreateSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("スケジュール作成画面"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(DateTime.now().toString()),
                ElevatedButton(onPressed: () {}, child: const Text("日付を選択")),
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/s_list');
                },
                child: const Text("スケジュール保存")),
          ],
        ),
      ),
    );
  }
}
