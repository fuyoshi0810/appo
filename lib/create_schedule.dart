import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:flutter_picker/flutter_picker.dart';

//スケジュール作成画面
class C_Schedule extends StatefulWidget {
  @override
  C_ScheduleState createState() => new C_ScheduleState();
}

class C_ScheduleState extends State<C_Schedule> {
  dynamic dateTime;
  dynamic dTime;
  dynamic dateFormat;

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    dateFormat = DateFormat("yyyy年MM月dd日").format(dateTime);
    dTime = TimeOfDay.now();
  }

  _datePicker(BuildContext context) async {
    final DateTime? datePicked = await showDatePicker(
      locale: const Locale("ja"),
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(DateTime.now().day - 1),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (datePicked != null && datePicked != dateTime) {
      setState(() {
        dateFormat = DateFormat("yyyy年MM月dd日").format(datePicked);
      });
    }
  }

  _timePicker(BuildContext context) async {
    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: dTime,
    );
    if (timePicked != null && timePicked != dTime) {
      setState(() {
        dTime = timePicked;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("スケジュール作成画面"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('$dateFormat'),
                ElevatedButton(
                    onPressed: () {
                      _datePicker(context);
                    },
                    child: Text("日付を選択")),
                Text("${dTime.hour}時${dTime.minute}分"),
                ElevatedButton(
                  onPressed: () {
                    _timePicker(context);
                  },
                  child: const Text("時刻を選択"),
                )
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/s_list');
                },
                child: Text("スケジュール保存")),
          ],
        ),
      ),
    );
  }
}
