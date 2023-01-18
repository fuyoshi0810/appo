import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';

import 'file_manager.dart';
import 'location_callback_handler.dart';
import 'location_service_repository.dart';

void test() => runApp(TestApp());

//workmanager 追加分
const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const simplePeriodicTask =
    "be.tramckrijte.workmanagerExample.simplePeriodicTask";
const fetchBackground = "fetchBackground";
const myTask = "syncWithTheBackEnd";
String idokeido = "";
String kari = "";
int _counter = 0;
Timer? timer;

// @pragma('vm:entry-point')
// Future<void> test2Callback(LocationDto locationDto) async {
//   lat = locationDto.latitude.toString();
//   lon = locationDto.longitude.toString();
//   print(
//       locationDto.latitude.toString() + " " + locationDto.longitude.toString());
// }

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        print("$simpleTaskKey was executed. inputData = $inputData");
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("test", true);
        print("Bool from prefs: ${prefs.getBool("test")}");
        break;
      case simpleDelayedTask:
        print("$simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        print("$simplePeriodicTask was executed");
        print(idokeido);
        break;
      case fetchBackground:
        print("$simplePeriodicTask was executed");
        break;
      case myTask:
        print("aaaaa");
        break;
    }
    return Future.value(true);
  });
}
//一旦ここまで

class TestApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<TestApp> {
  ReceivePort port = ReceivePort();

  String logStr = '';
  bool? isRunning;
  LocationDto? lastLocation;

  @override
  void initState() {
    super.initState();

    if (IsolateNameServer.lookupPortByName(
            LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    port.listen(
      (dynamic data) async {
        await updateUI(data);
      },
    );
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> updateUI(dynamic data) async {
    print("updateui");
    final log = await FileManager.readLogFile();

    LocationDto? locationDto =
        (data != null) ? LocationDto.fromJson(data) : null;
    await _updateNotificationText(locationDto!);
    //追加
    idokeido = locationDto.latitude.toString() +
        " " +
        locationDto.longitude.toString();

    setState(() {
      if (data != null) {
        lastLocation = locationDto;
        print("datain");
      }
      logStr = log;
    });
  }

  Future<void> _updateNotificationText(LocationDto data) async {
    if (data == null) {
      return;
    }

    await BackgroundLocator.updateNotificationText(
        title: "new location received",
        msg: "${DateTime.now()}",
        bigMsg: "${data.latitude}, ${data.longitude}");
  }

  Future<void> initPlatformState() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    logStr = await FileManager.readLogFile();
    print('Initialization done');
    final _isRunning = await BackgroundLocator.isServiceRunning();
    setState(() {
      isRunning = _isRunning;
    });
    print('Running ${isRunning.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    final start = SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        child: Text('Start'),
        onPressed: () {
          Workmanager().initialize(
            callbackDispatcher,
            isInDebugMode: true,
          );
          _onStart();
        },
      ),
    );
    final delay = SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
          child: Text('simpletask'),
          onPressed: () async {
            Future.delayed(Duration(seconds: 10), () {
              Workmanager().registerOneOffTask(
                "1",
                fetchBackground,
                inputData: <String, dynamic>{
                  'String': lastLocation!.latitude.toString() +
                      "・" +
                      lastLocation!.longitude.toString()
                },
              );
            });
            Future.delayed(Duration(seconds: 30), () {
              Workmanager().registerOneOffTask(
                "2",
                fetchBackground,
                inputData: <String, dynamic>{
                  'String': lastLocation!.latitude.toString() +
                      "・" +
                      lastLocation!.longitude.toString()
                },
              );
            });
          }),
    );
    final Periodic = SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
          child: Text('Periodic'),
          onPressed: Platform.isAndroid
              ? () {
                  Workmanager().registerPeriodicTask(
                    "3",
                    simplePeriodicTask,
                    inputData: <String, dynamic>{
                      'double': lastLocation!.latitude.toString() +
                          lastLocation!.longitude.toString(),
                      'string': idokeido,
                    },
                  );
                }
              : null),
    );
    final check = SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        child: Text('Check'),
        onPressed: () async {
          print(lastLocation!.latitude.toString() +
              "・" +
              lastLocation!.longitude.toString());
        },
      ),
    );
    final stop = SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        child: Text('Stop'),
        onPressed: () async {
          await Workmanager().cancelAll();
          onStop();
        },
      ),
    );
    final clear = SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        child: Text('Clear Log'),
        onPressed: () {
          FileManager.clearLogFile();
          setState(() {
            logStr = '';
          });
        },
      ),
    );
    final pop = SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        child: Text('色々確認ボタン'),
        onPressed: () {
          print(lastLocation!.latitude.toString());
          print(idokeido.toString());
          // SystemNavigator.pop();
        },
      ),
    );
    String msgStatus = "-";
    if (isRunning != null) {
      if (isRunning!) {
        msgStatus = 'Is running';
      } else {
        msgStatus = 'Is not running';
      }
    }
    final status = Text("Status: $msgStatus");

    final log = Text(
      logStr,
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter background Locator'),
        ),
        body: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                start,
                delay,
                Periodic,
                check,
                stop,
                pop,
                clear,
                status,
                log,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onStop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    final _isRunning = await BackgroundLocator.isServiceRunning();
    setState(() {
      isRunning = _isRunning;
    });
  }

  void _onStart() async {
    print("onstart");
    if (await _checkLocationPermission()) {
      await _startLocator();
      final _isRunning = await BackgroundLocator.isServiceRunning();

      setState(() {
        isRunning = _isRunning;
        lastLocation = null;
      });
    } else {
      // show error
    }
  }

  Future<bool> _checkLocationPermission() async {
    final access = await LocationPermissions().checkPermissionStatus();
    switch (access) {
      case PermissionStatus.unknown:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await LocationPermissions().requestPermissions(
          permissionLevel: LocationPermissionLevel.locationAlways,
        );
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
        break;
      case PermissionStatus.granted:
        return true;
        break;
      default:
        return false;
        break;
    }
  }

  Future<void> _startLocator() async {
    print("startloca");
    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            distanceFilter: 0,
            stopWithTerminate: true),
        autoStop: false,
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 5,
            distanceFilter: 0,
            client: LocationClient.google,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                    'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }
}
