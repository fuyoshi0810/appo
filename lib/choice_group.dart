import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:appo/main.dart';

//藤尾変更分
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
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';

import 'file_manager.dart';
import 'location_callback_handler.dart';
import 'location_service_repository.dart';

//workmanager 追加分
const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const simplePeriodicTask =
    "be.tramckrijte.workmanagerExample.simplePeriodicTask";
const fetchBackground = "fetchBackground";
const myTask = "syncWithTheBackEnd";
String idokeido = "";
String karilat = "";
String karilon = "";
int Counter = 0;
Timer? timer;
const latKey = '';
const testkey = " ";

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    switch (task) {
      case simpleTaskKey:
        print("$simpleTaskKey was executed. inputData = $inputData");
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("test", true);
        print("Bool from prefs: ${prefs.getBool("test")}");
        break;
      case simpleDelayedTask:
        print("$simpleDelayedTask was executed(シンプルディレイ)");
        break;
      case simplePeriodicTask:
        print("$simplePeriodicTask was executed(シンプルペリオディック)");
        print(idokeido);
        break;
      case fetchBackground:
        print("$simplePeriodicTask was executed");
        //SharedPreferencesから取得してfirebaseに送る
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        List test = prefs.getStringList('latlng_list') ?? [];
        print(test.toString() + "ワークマネージャーじゃあああああああああああああ");
        final testdb = FirebaseFirestore.instance.collection('test').doc();
        await testdb.set({'lat': test.elementAt(0), 'lng': test.elementAt(1)});

        break;
      case myTask:
        print("aaaaa");
        break;
    }
    return Future.value(true);
  });
}

class ChoiceGroup extends StatefulWidget {
  const ChoiceGroup({super.key});

  @override
  State<ChoiceGroup> createState() => _ChoiceGroupState();
}

class _ChoiceGroupState extends State<ChoiceGroup> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final userdb = FirebaseFirestore.instance.collection('users');

  ReceivePort port = ReceivePort();

  String logStr = '';
  bool? isRunning;
  LocationDto? lastLocation;

  //追加
  @override
  void initState() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    workStart();
    if (Counter == 0) {
      _onStart();
      Counter = 1;
      print(Counter.toString() + "カウンター");
    }

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

    @override
    dispose() {
      Workmanager().cancelAll();
      onStop();
      Counter = 0;
      print(Counter.toString() + "カウンター");
      print("disposeeeeeあああああああああああああああああ");
      super.dispose();
    }
  }

  void workStart() {
    Timer.periodic(Duration(minutes: 5), // 5分毎にループ
        (timer) {
      Workmanager().registerOneOffTask(
        "work",
        fetchBackground,
        inputData: <String, dynamic>{'String': karilat + " " + karilon},
      );
    });
  }

  Future<void> updateUI(dynamic data) async {
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
        // kari =
        //     locationDto.latitude.toString() + locationDto.longitude.toString();
        karilat = lastLocation!.latitude.toString();
        karilon = lastLocation!.longitude.toString();
      }
      logStr = log;
    });
  }

  Future<void> _updateNotificationText(LocationDto data) async {
    if (data == null) {
      return;
    }

    //SharedPreferencesに送る
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('latlng_list', [karilat, karilon]);

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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('グループ一覧'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: '招待グループ一覧',
            onPressed: () {
              Navigator.pushNamed(context, '/inv_list');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // ignore: use_build_context_synchronously
              // Navigator.pushNamed(context, '/');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LogInPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            userdb.doc(uid).snapshots(), //returns a Stream<DocumentSnapshot>
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text("読み込み中…"),
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Text("読み込み中…");
          // }

          List<dynamic> groupList = snapshot.data!["groupList"];

          if (groupList.isEmpty) {
            return SingleChildScrollView(
                //追加
                child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 500,
                    child: Text("表示可能なグループはありません"),
                  ),
                  TextButton(
                    child: const Text("グループ作成"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/c_group');
                    },
                  ),
                ],
              ),
            ));
          } else {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 500,
                    child: Scrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: groupList.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(groupList[index]['groupName'].toString()),
                          onTap: (() {
                            Navigator.pushNamed(context, '/g_menu',
                                arguments: groupList[index]['groupId']);
                          }),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    child: const Text("グループ作成"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/c_group');
                    },
                  ),
                  TextButton(
                    child: const Text("stop"),
                    onPressed: () async {
                      await Workmanager().cancelAll();
                      onStop();
                      Counter = 0;
                    },
                  ),
                ],
              ),
            );
          }

          // return ListView.builder(
          //   itemBuilder: (BuildContext context, int index) {
          //     return Container(
          //         decoration: BoxDecoration(
          //           border: Border(
          //             bottom: BorderSide(color: Colors.black38),
          //           ),
          //         ),
          //         child: ListTile(onTap: () {
          //           print(vocabulary);
          //         }));
          //   },
          // );
        },
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
  // ),
        // });
  // }