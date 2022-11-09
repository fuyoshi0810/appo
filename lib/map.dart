import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';

const kGoogleApiKey = "AIzaSyD_HBnp6ybK_wylg-CSbGTMnh5AQvxEiX0";

class Map extends StatefulWidget {
  @override
  _MapBody createState() => _MapBody();
}

class _MapBody extends State<Map> {
  Completer<GoogleMapController> _controller = Completer();

  late LatLng _initialPosition;
  late bool _loading;
  bool _searchBoolean = false; //追加

  Widget _searchTextField() {
    //追加
    return TextField(
      autofocus: true, //TextFieldが表示されるときにフォーカスする（キーボードを表示する）
      cursorColor: Colors.white, //カーソルの色
      style: TextStyle(
        //テキストのスタイル
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
          //hintTextのスタイル
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
    return Scaffold(
      appBar: AppBar(title: Text("検索欄"), actions: [
        IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              Prediction? p = await PlacesAutocomplete.show(
                apiKey: kGoogleApiKey,
                context: context,
                radius: 10000000,
                types: [],
                logo: const SizedBox.shrink(),
                strictbounds: false,
                mode: Mode.overlay, // Mode.fullscreen
                language: "jp",
                components: [
                  //add this
                  Component(Component.country, "jp"),
                  Component(Component.country, "in"),
                  Component(Component.country, "UK")
                ],
              );
            })
      ]),
      drawer: Drawer(
          child: ListView(
        children: [
          DrawerHeader(
              decoration: BoxDecoration(color: Colors.yellowAccent),
              child: Text("各画面遷移")),
          ListTile(
            title: Text("スケジュール一覧"),
            onTap: () {
              Navigator.pushNamed(context, '/s_list');
            },
          ),
          ListTile(
              title: Text("退出"),
              onTap: () {
                Navigator.pushNamed(context, '/g_menu');
              }),
        ],
      )),
      body: _loading
          ? CircularProgressIndicator()
          : SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SizedBox(
                    child: GoogleMap(
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
