import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

//スケジュール作成画面
class CreateSchedule extends StatefulWidget {
  const CreateSchedule({super.key});

  @override
  CreateScheduleState createState() => CreateScheduleState();
}

class CreateScheduleState extends State<CreateSchedule> {
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

  @override
  Widget build(BuildContext context) {
    final scheduleController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール作成'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(DateTime.now().toString()),
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
              onPressed: () async {
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
              child: const Text("スケジュール保存"),
            ),
          ],
        ),
      ),
    );
  }
}
