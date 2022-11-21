import 'package:flutter/material.dart';

class GroupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //mapに引数
    final String g_id = ModalRoute.of(context)?.settings.arguments as String;

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
                  Navigator.pushNamed(context, '/s_list', arguments: g_id);
                },
                child: Text("スケジュール一覧")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/map');
                },
                child: Text("マップ")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/s_group', arguments: g_id);
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
