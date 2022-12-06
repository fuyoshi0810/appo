import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'dart:async';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';

// import 'package:cloud_functions/cloud_functions.dart';
// final functions = FirebaseFunctions.instance;
// final result =
//     await FirebaseFunctions.instance.httpsCallable('addMessage').call();
// try {
//   final result =
//       await FirebaseFunctions.instance.httpsCallable('addMessage').call();
// } on FirebaseFunctionsException catch (error) {
//   print(error.code);
//   print(error.details);
//   print(error.message);
// }
import 'package:http/http.dart' as http;

const kGoogleApiKey = "AIzaSyD_HBnp6ybK_wylg-CSbGTMnh5AQvxEiX0";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

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
  dynamic date;
  late double lat;
  late double lng;
  late LatLng _initialPosition;
  late bool _loading;
  List<Marker> _markers = <Marker>[];
  String sublocation = "";
  String location = "";

  Completer<GoogleMapController> _controller = Completer();

  // 現在位置の監視状況
  StreamSubscription? _locationChangedListen;

  final groupdb = FirebaseFirestore.instance.collection('groups');
  dynamic _index;
  String check = "";
  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    dateFormat = DateFormat("yyyy年MM月dd日").format(dateTime);
    dTime = TimeOfDay.now();
    date = DateTime.now().millisecondsSinceEpoch;
    _loading = true;
    _getUserLocation();
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
        date = datePicked.millisecondsSinceEpoch;
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

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _loading = false;
      print(position);
    });
  }

  //クラウドファンクション
  DateTime _dateTime = DateTime.now();

  void _selectDate() async {
    var pickedDate = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(2022),
        lastDate: DateTime.now().add(Duration(days: 365)));
    if (pickedDate != null) {
      setState(() => _dateTime = DateTime(pickedDate.year, pickedDate.month,
          pickedDate.day, _dateTime.hour, _dateTime.minute));
    }
  }

  void _selectTime() async {
    var pickedTime = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
    if (pickedTime != null) {
      setState(
        () {
          _dateTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day,
              pickedTime.hour, pickedTime.minute);
        },
      );
    }
  }

  void _sendTime(int timestamp) async {
    // https://localhost:5001/jboyexample/us-central1/saveTimeStamp?unixtime=1657986508
    var url = Uri.http(
        'localhost:5001',
        '/dev-functions-679de/us-central1/saveTimeStamp',
        {'unixtime': '$timestamp'});
    var resp = await http.get(url);
    print('http.get($url) status code=${resp.statusCode}.');
  }

  @override
  Widget build(BuildContext context) {
    final scheduleController = TextEditingController();
    final String g_id = ModalRoute.of(context)?.settings.arguments as String;
    final schedb = FirebaseFirestore.instance.collection('schedules');
    final groupdb = FirebaseFirestore.instance.collection('groups');

    // return Scaffold(
    //   appBar: AppBar(),
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         Text(
    //           'DateTime:${_dateTime.toLocal().toString()}',
    //           style: Theme.of(context).textTheme.headline4,
    //         ),
    //         ElevatedButton(
    //           child: Text('set Date'),
    //           onPressed: _selectDate,
    //         ),
    //         ElevatedButton(
    //           child: Text('set Time'),
    //           onPressed: _selectTime,
    //         ),
    //       ],
    //     ),
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () {
    //       _sendTime(_dateTime.toUtc().millisecondsSinceEpoch ~/ 1000);
    //     },
    //     tooltip: 'send to Firestore via Cloud Functions',
    //     child: const Icon(Icons.add),
    //   ), // This trailing comma makes auto-formatting nicer for build methods.
    // );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('スケジュール作成'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Text(DateTime.now().toString()),
              TextField(
                decoration: const InputDecoration(
                  label: Text('スケジュール名'),
                ),
                controller: scheduleController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    '$dateFormat',
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _datePicker(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, //ボタンの背景色
                        minimumSize: const Size(5, 30)),
                    child: const Text("日付を選択"),
                  ),
                  Text(
                    "${dTime.hour}時${dTime.minute}分",
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _timePicker(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, //ボタンの背景色
                        minimumSize: Size(5, 30)),
                    child: const Text("時刻を選択"),
                  )
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  Prediction? p = await PlacesAutocomplete.show(
                    apiKey: kGoogleApiKey,
                    context: context,
                    radius: 10000000,
                    types: [],
                    logo: const SizedBox.shrink(),
                    strictbounds: false,
                    mode: Mode.overlay, // Mode.fullscreen
                    decoration: InputDecoration(
                      hintText: 'Search',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    components: [Component(Component.country, "jp")],
                  );
                  PlacesDetailsResponse detail =
                      await _places.getDetailsByPlaceId(p!.placeId.toString());
                  var placeId = p.placeId;
                  String placeName = p.description.toString();
                  // double lat = detail.result.geometry!.location.lat;
                  // double lng = detail.result.geometry!.location.lng;
                  lat = detail.result.geometry!.location.lat;
                  lng = detail.result.geometry!.location.lng;
                  final reg = RegExp(
                      r'[\u3040-\u309F]|\u3000|[\u30A1-\u30FC]|[\u4E00-\u9FFF]');
                  //latlang
                  print("lat=" + lat.toString());
                  print("lng=" + lng.toString());
                  //英語の住所を出して日本語を正規表現で抜き出している
                  print("全体情報=" + p.description.toString());
                  Iterable<RegExpMatch> matches = reg.allMatches(placeName);
                  for (final m in matches) {
                    print(m[0]);
                    sublocation += m[0].toString();
                    location = sublocation;
                  }
                  LatLng newlatlang = LatLng(lat, lng);
                  GoogleMapController controller = await _controller.future;
                  controller.animateCamera(CameraUpdate.newCameraPosition(
                      // on below line we have given positions of Location 5
                      CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 14,
                  )));
                  _markers.add(
                    Marker(
                      markerId: MarkerId('SomeId'),
                      position: LatLng(lat, lng),
                      infoWindow: InfoWindow(
                        title: location,
                        snippet: p.description,
                      ),
                    ),
                  );
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, //ボタンの背景色
                    minimumSize: const Size(5, 30)),
                child: const Text("検索"),
              ),
              SizedBox(
                  width: 300.0,
                  height: 400.0,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : SafeArea(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              GoogleMap(
                                markers: Set<Marker>.of(_markers),
                                initialCameraPosition: CameraPosition(
                                  target: _initialPosition,
                                  zoom: 14.4746,
                                ),
                                onMapCreated: (GoogleMapController controller) {
                                  _controller.complete(controller);
                                },
                                // markers: _createMarker(),
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                mapToolbarEnabled: false,
                                buildingsEnabled: true,
                                onTap: (LatLng latLang) {
                                  print('Clicked: $latLang');
                                },
                              )
                            ],
                          ),
                        )),
              // SizedBox(),
              // StreamBuilder<DocumentSnapshot>(
              //     // body: new StreamBuilder<DocumentSnapshot>(
              //     stream:
              //         // FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
              //         groupdb.doc(g_id).snapshots(),
              //     builder: (BuildContext context,
              //         AsyncSnapshot<DocumentSnapshot> snapshot) {
              //       if (!snapshot.hasData) {
              //         return const Text("読み込み中…");
              //       }
              //       if (snapshot.hasError) {
              //         return Text('Error: ${snapshot.error}');
              //       }

              //       if (snapshot.connectionState == ConnectionState.waiting) {
              //         return const Text("Loading");
              //       }

              //       List<dynamic> mList = snapshot.data!['members'];
              //       var _isChecked = List.filled(mList.length, false);

              //       return SizedBox(
              //         height: 300,
              //         child: SingleChildScrollView(
              //           child: Column(children: [
              //             const Text("グループメンバー"),
              //             SizedBox(
              //               height: 500,
              //               child: Scrollbar(
              //                 child: ListView.builder(
              //                     shrinkWrap: true,
              //                     itemCount: mList.length,
              //                     itemBuilder: (context, index) {
              //                       // return CheckboxListTile(
              //                       //   title: Text(
              //                       //       mList[index]['userName'].toString()),
              //                       //   value: _isChecked[index],
              //                       //   // onChanged: (bool? value) {
              //                       //   onChanged: (bool? value) {
              //                       //     setState(() {
              //                       //       _isChecked[index] = value!;
              //                       //     });
              //                       //   },
              //                       //   controlAffinity:
              //                       //       ListTileControlAffinity.leading,
              //                       // );
              //                       return Row(
              //                         children: [
              //                           Expanded(
              //                             // child: Text(mList[index]['userName']),
              //                             child: ListTile(
              //                               title: Text(mList[index]['userName']
              //                                   .toString()),
              //                               selected: _index == index,
              //                               onTap: () {
              //                                 _index = index;
              //                                 print(_index.toString() +
              //                                     "を選択しました");
              //                               },
              //                             ),
              //                           ),
              //                           Expanded(
              //                             child: TextButton(
              //                                 style: ButtonStyle(
              //                                     foregroundColor:
              //                                         MaterialStateProperty.all<
              //                                             Color>(Colors.blue)),
              //                                 onPressed: () {},
              //                                 child: Text(check)),
              //                           ),
              //                         ],
              //                       );
              //                     }),
              //               ),
              //             )
              //           ]),
              //         ),
              //       );
              //     }),
              ElevatedButton(
                onPressed: () async {
                  print("データフォーマット＋ｄタイム" +
                      dateFormat.toString() +
                      dTime.toString());
                  print("date======" + date.toString());

                  // await schedb
                  //     .doc(scheduleController.text + date.toString())
                  //     .set({
                  //   "scheduleName": scheduleController.text,
                  //   "meetingTime": date,
                  //   "meetingPlace": [lat, lng],
                  //   // "participant": [],
                  //   "updatedAt": FieldValue.serverTimestamp(),
                  // });

                  // await groupdb.doc(scheduleController.text).update({
                  //   "schedules": FieldValue.arrayUnion([
                  //     {
                  //       "scheduleName": scheduleController.text,
                  //       "meetingTime": date,
                  //       "meetingPlace": [lat, lng],
                  //       // "participant": {あ},
                  //       "updatedAt": FieldValue.serverTimestamp(),
                  //     },
                  //   ]),
                  // });
                  Navigator.pushNamed(context, '/s_list', arguments: g_id);
                },
                child: const Text("スケジュール保存"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
