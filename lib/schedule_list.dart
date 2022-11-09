import 'package:flutter/material.dart';

class ScheduleList extends StatelessWidget {
  const ScheduleList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール一覧画面'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("スケジュール一覧画面"),
            // Scrollbar(
            //   thickness: 12,
            //   isAlwaysShown: true,
            //   radius: const Radius.circular(20),
            //   child: ListView.separated(
            //     padding: const EdgeInsets.all(20),
            //     separatorBuilder: (context, index) => const SizedBox(height: 8),
            //     itemCount: 30,
            //     itemBuilder: (context, index) => _buildCard(index + 1),
            //   ),
            // ),
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

  // Widget _buildCard(int index) {
  //   return Card(
  //     child: Container(
  //       margin: const EdgeInsets.all(10),
  //       child: Text(
  //         'Item $index',
  //         style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  //       ),
  //     ),
  //   );
  // }
}
