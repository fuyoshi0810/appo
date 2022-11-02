import 'dart:html';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

//firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Authのサインイン状態のprovider
final signInStateProvider = StateProvider((ref) => 'アカウントを作成してください');

/// サインインユーザーの情報プロバイダー
final userProvider = StateProvider<User?>((ref) => null);
final userEmailProvider = StateProvider<String>((ref) => 'ログインしていません');

/// ページ設定
class C_Account extends ConsumerStatefulWidget {
  const C_Account({Key? key}) : super(key: key);

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends ConsumerState<C_Account> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final singInStatus = ref.watch(signInStateProvider);
    final userController = TextEditingController();
    final mailController = TextEditingController();
    final passController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント作成'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          TextField(
            decoration: const InputDecoration(
              label: Text('ユーザー名'),
            ),
            controller: userController,
          ),

          /// メールアドレス入力
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
              onPressed: () async {
                try {
                  if (userController.text != "") {
                    /// credential にはアカウント情報が記録される
                    final credential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: mailController.text,
                      password: passController.text,
                    );

                    /// ユーザ情報の更新
                    ref.watch(userProvider.state).state = credential.user;

                    /// 画面に表示
                    ref.read(signInStateProvider.state).state =
                        'アカウント作成に成功しました!';
                    print("userProvider = " + credential.user!.uid);

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(credential.user!.uid)
                        .set({
                      'user_name': userController.text,
                      'email': mailController.text,
                      'password': passController.text,
                      'createdAt': FieldValue.serverTimestamp(),
                      'updatedAt': FieldValue.serverTimestamp()
                    });
                  } else {
                    ref.read(signInStateProvider.state).state =
                        'ユーザー名を入力してください';
                  }
                }

                /// アカウントに失敗した場合のエラー処理
                on FirebaseAuthException catch (e) {
                  /// パスワードが弱い場合
                  if (e.code == 'weak-password') {
                    ref.read(signInStateProvider.state).state =
                        'パスワードが弱いです(6文字以上)';

                    /// メールアドレスが既に使用中の場合
                  } else if (e.code == 'email-already-in-use') {
                    ref.read(signInStateProvider.state).state =
                        'すでに使用されているメールアドレスです';
                  }

                  /// その他エラー
                  else {
                    print('elseエラー' + e.toString());
                    ref.read(signInStateProvider.state).state =
                        'ユーザー名・メールアドレス・パスワードを正しく入力してください';
                  }
                } catch (e) {
                  print(e);
                }
              },
              child: const Text('アカウント作成'),
            ),
          ),

          /// サインインのメッセージ表示
          Container(
            padding: const EdgeInsets.all(10),
            child: Text(singInStatus),
          ),

          /// サインアウト
          TextButton(
              onPressed: () {
                _signOut(ref);
              },
              child: const Text('SIGN OUT'))
        ],
      ),
    );
  }
}

/// サインイン処理
void signIn(WidgetRef ref, String email, String pass) async {
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

/// サインアウト
void _signOut(WidgetRef ref) async {
  await FirebaseAuth.instance.signOut();
  ref.read(signInStateProvider.state).state = 'サインインまたはアカウントを作成してください';
}
