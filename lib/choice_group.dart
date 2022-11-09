import 'package:flutter/material.dart';

final items = ['チーム1', 'チーム2', 'チーム3', 'チーム4', 'チーム5', 'チーム6', 'チーム7'];

class ChoiceGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('グループ選択'),
        ),
        body: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              const TextField(
                maxLength: 10,
                style: TextStyle(color: Colors.red),
                obscureText: false,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: 'グループ名を入力してください',
                  labelText: 'グループ名 *',
                ),
              ),
              ElevatedButton(child: const Text("検索"), onPressed: () {}),
              SizedBox(
                width: 100,
                height: 400,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${items[index]}'),
                      onTap: () {
                        Navigator.pushNamed(context, '/g_menu');
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                child: Text("グループを作成"),
                onPressed: () {
                  //グループ選択画面へ遷移
                  Navigator.pushNamed(context, '/c_group');
                },
              ),
            ])));
  }
}
