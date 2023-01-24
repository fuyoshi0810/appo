import 'package:appo/invite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

//担当者：中島
import 'package:appo/create_account.dart';
import 'package:appo/create_schedule.dart';
import 'package:appo/edit_schedule.dart';
import 'package:appo/schedule_list.dart';
import 'package:appo/inv_list.dart';
//担当者：藤尾
import 'package:appo/map.dart';
import 'package:appo/choice_group.dart';
import 'package:appo/create_group.dart';
import 'package:appo/settings_group.dart';
import 'package:appo/group_menu.dart';
import 'package:appo/invite.dart';
//firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'group_menu.dart';
import 'package:cloud_functions/cloud_functions.dart';

//グループ一覧遷移時戻らないようにする
//ログイン済みの場合飛ばす

// await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );
// void main() {
//   runApp(const MyApp());
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

// // Ideal time to initialize
//   await FirebaseAuth.instance.useAuthEmulator('localhost', 9002);

// //Webでやるなら認証情報の永続化設定が必要
//   FirebaseAuth.instance.authStateChanges().listen((User? user) {
//     if (user == null) {
//       print('User is currently signed out!');
//       runApp(const ProviderScope(child: MyApp()));
//     } else {
//       print('User is signed in!');
//       runApp(ChoiceGroup());
//     }
//   });
// }

/// メイン
Future<void> main() async {
  /// クラッシュハンドラ
  // runZonedGuarded<Future<void>>(() async {
  /// Firebaseの初期化
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// クラッシュハンドラ(Flutterフレームワーク内でスローされたすべてのエラー)
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
  // runApp(MyApp());
  // },

  /// クラッシュハンドラ(Flutterフレームワーク内でキャッチされないエラー)
  // (error, stack) =>
  // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

/// Authのサインイン状態のprovider
// final signInStateProvider = StateProvider((ref) => 'サインインまたはアカウントを作成してください');

/// サインインユーザーの情報プロバイダー
// final userProvider = StateProvider<User?>((ref) => null);
// final userEmailProvider = StateProvider<String>((ref) => 'ログインしていません');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoginPage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/log': (context) => LogInPage(), //ログイン画面
        // '/': (context) => const LogInPage(), //ログイン画面
        '/c_account': (context) => CreateAccount(), //アカウント作成画面
        '/s_list': (context) => ScheduleList(), //スケジュール一覧画面
        '/c_schedule': (context) => CreateSchedule(), //スケジュール作成画面
        '/e_schedule': (context) => const EditSchedule(), //スケジュール編集画面
        '/g_menu': (context) => GroupMenu(), //グループ設定画面
        '/s_group': (context) => SettingsGroup(), //グループ設定画面
        '/map': (context) => Map(), //マップ画面
        '/inv_list': (context) => InvList(), //招待されているグループ一覧画面
        '/invite': (context) => Invite(
              onSubmit: (String value) {},
            ), //招待画面
        '/c_group': (context) => CreateGroup(
              onSubmit: (String value) {},
            ), //グループ作成画面
        '/choice_group': (context) => ChoiceGroup(), //グループ選択画面
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          if (snapshot.hasData) {
            // return ChoiceGroup();
            return ChoiceGroup();
          }
          return LogInPage();
          // return ChoiceGroup();
        },
      ),
    );
  }
}

class LogInPage extends StatefulWidget {
  // const LogInPage({Key? key}) : super(key: key);

  @override
  _LogInPage createState() => _LogInPage();
}

class _LogInPage extends State<LogInPage> {
  final _auth = FirebaseAuth.instance;

  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ログイン'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
                email = value;
              },
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'メールアドレスを入力',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
                password = value;
              },
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'パスワードを入力',
              ),
            ),
          ),
          ElevatedButton(
            child: const Text('ログイン'),
            onPressed: () async {
              try {
                final newUser = await _auth.signInWithEmailAndPassword(
                    email: email, password: password);
                if (newUser != null) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChoiceGroup()));
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'invalid-email') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(''),
                    ),
                  );
                  print('メールアドレスのフォーマットが正しくありません');
                } else if (e.code == 'user-disabled') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('現在指定したメールアドレスは使用できません'),
                    ),
                  );
                  print('現在指定したメールアドレスは使用できません');
                } else if (e.code == 'user-not-found') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('指定したメールアドレスは登録されていません'),
                    ),
                  );
                  print('指定したメールアドレスは登録されていません');
                } else if (e.code == 'wrong-password') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('パスワードが間違っています'),
                    ),
                  );
                  print('パスワードが間違っています');
                }
              }
            },
          ),
          TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateAccount()));
              },
              child: Text('新規登録'))
        ],
      ),
    );
  }

//   void functiontest() async {
//   try {
//     /// カウントアップの関数の読み出し
//     final result = await FirebaseFunctions.instance
//         .httpsCallable('deleteSchedule')
//         .call({'groupName': _number, });
//     _number = result.data['addNumber'];
//     print(result.data['contextUid']);
//   } on FirebaseFunctionsException catch (error) {
//     print(error.code);
//     print(error.details);
//     print(error.message);
//   }
// }
}
