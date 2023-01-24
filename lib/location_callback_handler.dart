import 'dart:async';

import 'package:background_locator_2/location_dto.dart';

import 'location_service_repository.dart';

String lat = "";
String lon = "";

@pragma('vm:entry-point')
class LocationCallbackHandler {
  @pragma('vm:entry-point')
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  @pragma('vm:entry-point')
  static Future<void> disposeCallback() async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  @pragma('vm:entry-point')
  static Future<void> callback(LocationDto locationDto) async {
    lat = locationDto.latitude.toString();
    lon = locationDto.longitude.toString();
    print(locationDto.latitude.toString() + locationDto.longitude.toString());
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.callback(locationDto);
  }

  // @pragma('vm:entry-point')
  // static Future<void> testCallback(LocationDto locationDto) async {
  //   lat = locationDto.latitude.toString();
  //   lon = locationDto.longitude.toString();
  //   print(lat + " " + lon);
  //   LocationServiceRepository myLocationCallbackRepository =
  //       LocationServiceRepository();
  //   await myLocationCallbackRepository.callback(locationDto);
  // }

  @pragma('vm:entry-point')
  static Future<void> notificationCallback() async {
    print('***notificationCallback');
  }
}
