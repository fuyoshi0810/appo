import 'package:flutter/material.dart';

class SettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListView(
              children: [Text("メンバー１"), Text("メンバー２")],
            ),
            TextButton(
              child: Text("解散"),
              onPressed: () {
                Navigator.pushNamed(context, '/c_group');
              },
            )
          ],
        ),
      ),
    );
  }
}
