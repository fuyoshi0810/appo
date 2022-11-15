//担当者：中島
import 'package:appo/create_account.dart';
import 'package:appo/create_schedule.dart';
import 'package:appo/edit_schedule.dart';
import 'package:appo/schedule_list.dart';

//担当者：藤尾
import 'package:appo/map.dart';
import 'package:appo/choice_group.dart';
import 'package:appo/create_group.dart';
import 'package:appo/settings_group.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'dart:async';

import 'group_menu.dart';

// await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );
// void main() {
//   runApp(const MyApp());
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MyApp());
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
void main() async {
  /// クラッシュハンドラ
  // runZonedGuarded<Future<void>>(() async {
  /// Firebaseの初期化
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// クラッシュハンドラ(Flutterフレームワーク内でスローされたすべてのエラー)
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  /// runApp w/ Riverpod
  // runApp(const ProviderScope(child: MyApp()));
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
  // },

  /// クラッシュハンドラ(Flutterフレームワーク内でキャッチされないエラー)
  // (error, stack) =>
  // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

/// Authのサインイン状態のprovider
final signInStateProvider = StateProvider((ref) => 'サインインまたはアカウントを作成してください');

/// サインインユーザーの情報プロバイダー
final userProvider = StateProvider<User?>((ref) => null);
final userEmailProvider = StateProvider<String>((ref) => 'ログインしていません');

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Counter Firebase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => LogInPage(),
        '/c_account': (context) => C_Account(), //アカウント作成画面
        '/s_list': (context) => S_list(), //スケジュール一覧画面
        '/c_schedule': (context) => C_Schedule(), //スケジュール作成画面
        '/e_schedule': (context) => E_Schedule(), //スケジュール編集画面
        '/s_group': (context) => SettingsGroup(), //グループ設定画面
        '/map': (context) => Map(), //マップ画面
        '/c_group': (context) => CreateGroup(), //グループ作成画面
        '/choice_group': (context) => ChoiceGroup(), //グループ選択画面
        '/g_menu': (context) => GroupMenu(), //グループ画面
      },
      // home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// MaterialAppの設定
class LogInPage extends ConsumerStatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  _LogInPage createState() => _LogInPage();
}

/// ホーム画面
class _LogInPage extends ConsumerState<LogInPage> {
  // const LoginPage({Key? key}) : super(key: key);
  @override
  void initState() {
    super.initState();
  }

  @override
  // Widget build(BuildContext context, WidgetRef ref) {
  Widget build(BuildContext context) {
    final singInStatus = ref.watch(signInStateProvider);
    final mailController = TextEditingController();
    final passController = TextEditingController();

    /// ユーザー情報の取得
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        ref.watch(userEmailProvider.state).state = 'ログインしていません';
      } else {
        ref.watch(userEmailProvider.state).state = user.email!;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Homepage'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          /// ユーザ情報の表示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person),
              Text(ref.watch(userEmailProvider)),
            ],
          ),
          TextField(
            decoration: const InputDecoration(
              label: Text('メールアドレス'),
              icon: Icon(Icons.mail),
            ),
            controller: mailController,
          ),

          /// パスワード入力
          TextField(
            decoration: const InputDecoration(
              label: Text('パスワード'),
              icon: Icon(Icons.key),
            ),
            controller: passController,
            obscureText: true,
          ),

          /// アカウント作成
          Container(
            margin: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                /// アカウント作成の場合
                _signIn(ref, mailController.text, passController.text, context);
              },
              child: const Text('ログイン'),
            ),
          ),

          TextButton(
            child: Text("アカウントを作成"),
            onPressed: () {
              //グループ選択画面へ遷移
              Navigator.pushNamed(context, '/c_account');
            },
          ),

          /// サインインのメッセージ表示
          Container(
            padding: const EdgeInsets.all(10),
            child: Text(singInStatus),
          ),
        ],
      ),
    );
  }
}

/// Analyticsの実装
// class AnalyticsService {
/// ページ遷移のログ
// Future<void> logPage(String screenName) async {
// await FirebaseAnalytics.instance.logEvent(
// name: 'screen_view',
// parameters: {
// 'firebase_screen': screenName,
// },
// );
// }
// }

/// サインイン処理
void _signIn(
    WidgetRef ref, String email, String pass, BuildContext context) async {
  try {
    /// credential にはアカウント情報が記録される
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: pass,
    );

    /// ユーザ情報の更新
    ref.watch(userProvider.state).state = credential.user;

    /// 画面に表示
    ref.read(signInStateProvider.state).state = 'サインインできました!';
    Navigator.pushNamed(context, '/choice_group');
  }

  /// サインインに失敗した場合のエラー処理
  on FirebaseAuthException catch (e) {
    /// メールアドレスが無効の場合
    if (e.code == 'invalid-email') {
      ref.read(signInStateProvider.state).state = 'メールアドレスが無効です';
    }

    /// ユーザーが存在しない場合
    else if (e.code == 'user-not-found') {
      ref.read(signInStateProvider.state).state = 'ユーザーが存在しません';
    }

    /// パスワードが間違っている場合
    else if (e.code == 'wrong-password') {
      ref.read(signInStateProvider.state).state = 'パスワードが間違っています';
    }

    /// その他エラー
    else {
      print('その他のエラー' + e.toString());
      ref.read(signInStateProvider.state).state = 'サインインエラー';
    }
  }
}
