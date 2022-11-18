import 'package:flutter/material.dart';

class SettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("メンバー一覧"),
      ),
      body: Center(
        // SizedBox(
        // height: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 500,
                child: Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 30,
                    itemBuilder: (context, index) => ListTile(
                      title: Text("item ${index + 1}"),
                    ),
                  ),
                ),
              ),

              // )

              TextButton(
                child: Text("招待"),
                onPressed: () {
                  Navigator.pushNamed(context, '/invite');
                },
              ),
              TextButton(
                child: Text("解散"),
                onPressed: () {
                  Navigator.pushNamed(context, '/invite');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
