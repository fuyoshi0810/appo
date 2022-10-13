import 'package:appo/create_account.dart';
import 'package:appo/create_schedule.dart';
import 'package:appo/edit_schedule.dart';
import 'package:appo/schedule_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => MyHomePage(
              title: 'aa',
            ),
        '/c_account': (context) => C_Account(),
        '/s_list': (context) => S_list(),
        '/c_schedule': (context) => C_Schedule(),
        '/e_schedule': (context) => E_Schedule(),
        '/s_group': (context) => SettingsGroup(),
        '/map': (context) => Map(),
        '/s_group': (context) => SearchGroup(),
        '/c_group': (context) => Create_Group(),
        '/choice_group': (context) => Choice_Group(),
      },
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
