import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'dart:async';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';

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
  late LatLng _initialPosition;
  late bool _loading;
  List<Marker> _markers = <Marker>[];
  String sublocation = "";
  String location = "";

  Completer<GoogleMapController> _controller = Completer();

  // 現在位置の監視状況
  StreamSubscription? _locationChangedListen;

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    dateFormat = DateFormat("yyyy年MM月dd日").format(dateTime);
    dTime = TimeOfDay.now();
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
                Text(
                  '$dateFormat',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _datePicker(context);
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue, //ボタンの背景色
                      minimumSize: Size(5, 30)),
                  child: const Text("日付を選択"),
                ),
                Text(
                  "${dTime.hour}時${dTime.minute}分",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _timePicker(context);
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue, //ボタンの背景色
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
                      borderSide: BorderSide(
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
                double lat = detail.result.geometry!.location.lat;
                double lng = detail.result.geometry!.location.lng;
                final reg = RegExp(
                    r'[\u3040-\u309F]|\u3000|[\u30A1-\u30FC]|[\u4E00-\u9FFF]');
                //latlang
                print(lat);
                print(lng);
                //英語の住所を出して日本語を正規表現で抜き出している
                print(p.description);
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
                _markers.add(Marker(
                    markerId: MarkerId('SomeId'),
                    position: LatLng(lat, lng),
                    infoWindow: InfoWindow(
                      title: location,
                      snippet: p.description,
                    )));
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                  primary: Colors.blue, //ボタンの背景色
                  minimumSize: Size(5, 30)),
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
            SizedBox(),
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
        )));
  }
}
