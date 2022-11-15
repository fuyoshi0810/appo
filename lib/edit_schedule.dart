import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//スケジュール編集画面
class EditSchedule extends StatefulWidget {
  const EditSchedule({super.key});

  @override
  EditScheduleState createState() => EditScheduleState();
}

class EditScheduleState extends State<EditSchedule> {
  dynamic dateTime;
  dynamic dTime;
  dynamic dateFormat;
  var db = FirebaseFirestore.instance;

  @override
  void initState() async {
    super.initState();
    dateTime = DateTime.now();
    // dateTime = await db.collection("グループ名").doc("ああ").get();
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

  @override
  Widget build(BuildContext context) {
    final scheduleController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール編集画面'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("スケジュール編集画面"),
            TextField(
              decoration: const InputDecoration(
                label: Text('スケジュール名'),
              ),
              controller: scheduleController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('$dateFormat'),
                ElevatedButton(
                  onPressed: () {
                    _datePicker(context);
                  },
                  child: const Text("日付を選択"),
                ),
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
                // await FirebaseFirestore.instance
                //     .collection("groups")
                //     .doc(scheduleController.text)
                //     .set({
                //   "schedule": {
                //     "name": scheduleController.text,
                //     "meetingTime": dateFormat+dTimeあ,
                //     "meetingPlace": 緯度経度,
                //     "person": {あ},
                //     "updatedAt": FieldValue.serverTimestamp(),
                //   },
                // });
              },
              child: const Text("スケジュールを変更"),
            ),
          ],
        ),
      ),
    );
  }
}
