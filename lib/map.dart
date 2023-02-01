import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//暗号化

const kGoogleApiKey = "AIzaSyD_HBnp6ybK_wylg-CSbGTMnh5AQvxEiX0";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class Map extends StatefulWidget {
  // 画面遷移元からのデータを受け取る変数
  // final String g_id;
  // const Map({super.key, required this.g_id});

  @override
  _MapBody createState() => _MapBody();
}

class _MapBody extends State<Map> {
  // 状態を管理する変数
  // late String state;
  Completer<GoogleMapController> _controller = Completer();
  //list of markers

  late LatLng _initialPosition;
  late bool _loading;
  bool _searchBoolean = false; //追加
  List<Marker> _markers = <Marker>[];
  String sublocation = "";
  String location = "";
  final groupdb = FirebaseFirestore.instance.collection('groups');

  Widget _searchTextField() {
    //追加
    return TextField(
      autofocus: true, //TextFieldが表示されるときにフォーカスする（キーボードを表示する）
      cursorColor: Colors.white, //カーソルの色
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      decoration: InputDecoration(
        //TextFiledのスタイル
        enabledBorder: UnderlineInputBorder(
            //デフォルトのTextFieldの枠線
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: UnderlineInputBorder(
            //TextFieldにフォーカス時の枠線
            borderSide: BorderSide(color: Colors.white)),
        hintText: 'Search', //何も入力してないときに表示されるテキスト
        hintStyle: TextStyle(
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    _getUserLocation();
    // 受け取ったデータを状態を管理する変数に格納
    // state = widget.g_id;
  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final String g_id = ModalRoute.of(context)?.settings.arguments as String;
    final groupdb = FirebaseFirestore.instance.collection('groups');
    final userdb = FirebaseFirestore.instance.collection('users');
    var placename;
    var glat;
    var glng;
    var placelist = [];
    var testtestlist = [];
    var glatlist = [];
    var glnglist = [];
    var namelist = [];
    var userIds = [];

    void getUserLocation() async {
      glatlist = [];
      glnglist = [];
      namelist = [];

      groupdb
          .doc(g_id)
          .collection('schedules')
          .where("meetingTime", isNotEqualTo: "0")
          .snapshots()
          .listen(
        (event) {
          for (var doc in event.docs) {
            placelist = doc.data()['meetingPlace'];
            testtestlist.add(doc.data()['meetingTime']);
          }
          var listzero = event.docs[0];
          for (int i = 0; i < event.docs.length; i++) {
            if (listzero['meetingTime'] > testtestlist[i]) {
              listzero = event.docs[i];
            }
          }
          print(listzero['meetingPlace']);
          glat = listzero['meetingPlace'][0];
          glng = listzero['meetingPlace'][1];
          placename = listzero['scheduleName'].toString();
        },
        onError: (error) => print("Listen failed: $error"),
      );

      groupdb.doc(g_id).snapshots().listen(
        (event) {
          for (var a in event.data()!['members']) {
            userIds.add(a['userId']);
          }
        },
        onError: (error) => print("Listen failed: $error"),
      );

      groupdb.doc(g_id).snapshots().listen(
        (event) {
          for (var a in event.data()!['members']) {
            userIds.add(a['userId']);
          }
        },
        onError: (error) => print("Listen failed: $error"),
      );

      userdb.get().then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((doc) {
          if (userIds.contains(doc.id)) {
            glatlist.add(doc.get('lat'));
            glnglist.add(doc.get('lng'));
            namelist.add(doc.get('userName'));
          }
        });
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text("検索欄"), actions: [
        IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              sublocation = "";
              setState(() {});
              _loading = false;
              Prediction? p = await PlacesAutocomplete.show(
                apiKey: kGoogleApiKey,
                context: context,
                radius: 10000000,
                types: [],
                logo: const SizedBox.shrink(),
                strictbounds: false,
                mode: Mode.overlay, // Mode.fullscreen
                decoration: InputDecoration(
                  hintText: '検索',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                ),
                components: [Component(Component.country, "jp")],
              );
              //nullチェックしてないから値入れずに検索するとエラー
              PlacesDetailsResponse detail =
                  await _places.getDetailsByPlaceId(p!.placeId.toString());
              var placeId = p.placeId;
              String placeName = p.description.toString();
              double lat = detail.result.geometry!.location.lat;
              double lng = detail.result.geometry!.location.lng;
              final reg = RegExp(
                  r'[\u3040-\u309F]|\u3000|[\u30A1-\u30FC]|[\u4E00-\u9FFF]');
              print(lat);
              print(lng);
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
                  markerId: MarkerId('Search'),
                  position: LatLng(lat, lng),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                  infoWindow: InfoWindow(
                    title: location,
                    // snippet: p.description,
                  )));
              print(p.description);
              setState(() {});
            }),
        IconButton(
            icon: Icon(Icons.update),
            onPressed: () async {
              _loading = true;
              getUserLocation();
              Future.delayed(Duration(seconds: 2), () async {
                for (int len = 0; len < glatlist.length; len++) {
                  _markers.add(Marker(
                      markerId: MarkerId(len.toString()),
                      position: LatLng(double.parse(glatlist[len]),
                          double.parse(glnglist[len])),
                      infoWindow: InfoWindow(
                        title: namelist[len],
                        // snippet: "仮置き",
                      )));
                  _markers.add(Marker(
                      markerId: MarkerId('location'),
                      position: LatLng(glat, glng),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                      infoWindow: InfoWindow(
                        title: placename,
                        // snippet: p.description,
                      )));
                  Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high);
                  setState(() {
                    _initialPosition =
                        LatLng(position.latitude, position.longitude);
                    _loading = false;
                    print(position);
                  });
                }
                print("おわり");
              });
            })
      ]),
      body: _loading
          ? const CircularProgressIndicator()
          : SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SizedBox(
                    child: GoogleMap(
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
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
