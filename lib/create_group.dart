import 'package:flutter/material.dart';

class CreateGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                  decoration: BoxDecoration(color: Colors.yellowAccent),
                  child: Text("My Home Page")),
              ListTile(
                title: Text("スケジュール一覧"),
                onTap: () {
                  Navigator.pushNamed(context, '/s_list');
                },
              ),
              ListTile(
                title: Text("グループ設定画面"),
                onTap: () {
                  Navigator.pushNamed(context, '/s_group');
                },
              ),
            ],
          ),
        ));
  }
}
