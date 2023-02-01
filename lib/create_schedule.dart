import 'package:appo/schedule_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';
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
  dynamic ayear;
  dynamic amonth;
  dynamic aday;
  dynamic milibyou;
  dynamic zifun = TimeOfDay(hour: 00, minute: 00);
  late double lat = 0;
  late double lng;
  late LatLng _initialPosition;
  late bool _loading;
  List<Marker> _markers = <Marker>[];
  String sublocation = "";
  String location = "";
  final scheduleController = TextEditingController();

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
    ayear = DateTime.now().year;
    amonth = DateTime.now().month;
    aday = DateTime.now().day;
    milibyou = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );
    zifun = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    print("最初のdate" + date.toString());
    _loading = true;
    _getUserLocation();
  }

  String? get _errorText {
    final text = scheduleController.value.text;
    if (text.isEmpty) {
      return '1文字から10文字の間で入力してください';
    }
    return null;
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
        ayear = datePicked.year;
        amonth = datePicked.month;
        aday = datePicked.day;
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
        zifun = timePicked;
      });
    }
  }

  _saveTime(String key, String value) async {
    var prefs = await SharedPreferences.getInstance();
    print("ぷれふ" + prefs.toString());
    prefs.setString(key, value);
    print("ぷれふ" + prefs.toString());
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
    final String g_id = ModalRoute.of(context)?.settings.arguments as String;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final schedb = FirebaseFirestore.instance.collection('schedules');
    final groupdb = FirebaseFirestore.instance.collection('groups');
    final userdb = FirebaseFirestore.instance.collection('users');

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
              TextField(
                decoration: InputDecoration(
                  label: Text('スケジュール名'),
                  errorText: _errorText,
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
                        backgroundColor: Colors.blue,
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
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(5, 30)),
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
                  lat = detail.result.geometry!.location.lat;
                  lng = detail.result.geometry!.location.lng;
                  final reg = RegExp(
                      r'[\u3040-\u309F]|\u3000|[\u30A1-\u30FC]|[\u4E00-\u9FFF]');
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
                    backgroundColor: Colors.blue,
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
              ElevatedButton(
                onPressed: () {
                  if (scheduleController.value.text.isNotEmpty && lat != 0) {
                    print("登録成功");
                    milibyou =
                        DateTime(ayear, amonth, aday, zifun.hour, zifun.minute);
                    _submit(g_id);
                  } else {
                    print("null登録失敗");
                    null;
                  }
                },
                child: const Text("スケジュール保存"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(g_id) async {
    if (_errorText == null) {
      if (FirebaseAuth.instance.currentUser != null) {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        var userName;

        await groupdb
            .doc(g_id)
            .collection('schedules')
            .doc(DateTime.now().toString())
            .set({
          "scheduleName": scheduleController.text,
          "meetingTime": milibyou.millisecondsSinceEpoch,
          "meetingPlace": [lat, lng],
          //仮置き
          "scheduleId": DateTime.now().toString(),
          // "updatedAt": FieldValue.serverTimestamp(),
        });
        Navigator.pop(context);
      }
    } else {
      print("登録失敗");
    }
  }
}
