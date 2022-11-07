import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class Map extends StatefulWidget {
  @override
  _MapBody createState() => _MapBody();
}

class _MapBody extends State<Map> {
  Completer<GoogleMapController> _controller = Completer();

  late LatLng _initialPosition;
  late bool _loading;

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
      appBar: AppBar(),
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
            title: Text("グループ設定画面"),
            onTap: () {
              Navigator.pushNamed(context, '/s_group');
            },
          ),
          ListTile(
              title: Text("退出"),
              onTap: () {
                Navigator.pushNamed(context, '/c_group');
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
