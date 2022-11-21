import 'package:flutter/material.dart';

class ScheduleList extends StatelessWidget {
  const ScheduleList({super.key});

  @override
  Widget build(BuildContext context) {
    final String g_id = ModalRoute.of(context)?.settings.arguments as String;

    var list = [
      "メッセージ1",
      "メッセージ2",
      "メッセージ3",
      "メッセージ4",
      "メッセージ5",
    ];
    return Scaffold(
        appBar: AppBar(
          title: const Text('スケジュール一覧'),
        ),
        // body: Stack(
        body: Column(
          children: [
            Text("予定一覧", style: TextStyle(fontSize: 30)),
            Flexible(
              child: ListView.builder(
                itemCount: 15,
                itemBuilder: (BuildContext context, int index) {
                  print("index" + index.toString());
                  //無限ループ
                  // if (index >= list.length) {
                  list.addAll([
                    "メッセージ${index}",
                  ]);
                  // }
                  return _messageItem(list[index]);
                },
              ),
            ),
            Align(
              child: ElevatedButton(onPressed: () => {}, child: Text("あああ")),
              alignment: Alignment.bottomCenter,
            ),
          ],
        ));
  }

  Widget _messageItem(String title) {
    return Container(
      decoration: new BoxDecoration(
          border:
              new Border(bottom: BorderSide(width: 1.0, color: Colors.grey))),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: Colors.black, fontSize: 18.0),
        ),
        onTap: () {
          print("onTap called.");
        }, // タップ
        onLongPress: () {
          print("onLongTap called.");
        }, // 長押し
      ),
    );
  }
}
