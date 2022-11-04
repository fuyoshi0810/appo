import 'package:flutter/material.dart';

class ChoiceGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/c_group');
                },
                child: Text("グループを追加")),
            TextButton(
              child: Text("グループを新規作成"),
              onPressed: () {
                Navigator.pushNamed(context, '/choice_group');
              },
            )
          ],
        ),
      ),
    );
  }
}
