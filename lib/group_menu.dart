import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_webservice/directions.dart';

class GroupMenu extends StatelessWidget {
  const GroupMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final String g_id = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('グループメニュー'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // ignore: use_build_context_synchronously
              Navigator.pushNamed(context, '/');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/s_list', arguments: g_id);
                  },
                  child: const Text("スケジュール一覧")),
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/map', arguments: g_id);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => Map("g_id": g_id)),
                    // );
                  },
                  child: const Text("マップ")),
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/s_group', arguments: g_id);
                  },
                  child: const Text("メンバー")),
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/choice_group");
                  },
                  child: const Text("グループから抜ける")),
            ),
          ],
        ),
      ),
    );
  }
}
