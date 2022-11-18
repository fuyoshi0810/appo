import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Invite extends StatefulWidget {
  @override
  State<Invite> createState() => _InviteState();
}

class _InviteState extends State<Invite> {
  final useridController = TextEditingController();
  var members = [];

  @override
  void _addmember(String s) {
    setState(() {
      members.add(s);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("招待"),
      ),
      body: Center(
        child: SizedBox(
          // width: 200,
          height: 600,
          child: SingleChildScrollView(
            // child: SizedBox(
            // height: 500,
            child: Column(children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 12,
                      obscureText: false,
                      maxLines: 1,
                      controller: useridController,
                      decoration: const InputDecoration(
                        hintText: 'ユーザーidを入力してください',
                        labelText: 'ユーザー検索',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      child: Text("検索"),
                      onPressed: () {
                        _addmember(useridController.text);
                      },
                    ),
                  ),
                ],
              ),
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
              )
            ]),
          ),
        ),
      ),
    );
  }
}
