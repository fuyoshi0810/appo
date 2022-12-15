import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//firebase;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Authのサインイン状態のprovider
final signInStateProvider = StateProvider((ref) => 'アカウントを作成してください');

/// サインインユーザーの情報プロバイダー
final userProvider = StateProvider<User?>((ref) => null);

/// ページ設定
class CreateAccount extends ConsumerStatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends ConsumerState<CreateAccount> {
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
        centerTitle: true,
        title: const Text('アカウント作成'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          TextField(
            decoration: const InputDecoration(
              label: Text('ユーザー名'),
              icon: Icon(Icons.account_circle),
            ),
            controller: userController,
          ),

          /// メールアドレス入力
          TextField(
            keyboardType: TextInputType.emailAddress,
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
                    ref.read(signInStateProvider.state).state = 'アカウント登録完了';

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(credential.user!.uid)
                        .set({
                      'userId': DateTime.now().day.toString().padLeft(2, '0') +
                          DateTime.now().hour.toString().padLeft(2, '0') +
                          DateTime.now().second.toString().padLeft(2, '0') +
                          DateTime.now()
                              .year
                              .toString()
                              .substring(2, 4)
                              .padLeft(2, '0') +
                          DateTime.now().minute.toString().padLeft(2, '0') +
                          DateTime.now().month.toString().padLeft(2, '0'),
                      'userName': userController.text,
                      'email': mailController.text,
                      'password': passController.text,
                      'groupList': [],
                      'invList': [],
                      'lat': '',
                      'lng': '',
                      'createdAt': FieldValue.serverTimestamp(),
                      'updatedAt': FieldValue.serverTimestamp(),
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
                    ref.read(signInStateProvider.state).state =
                        'ユーザー名・メールアドレス・パスワードを正しく入力してください';
                  }
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
              child: const Text('アカウント作成'),
            ),
          ),

          /// サインインのメッセージ表示
          Container(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Text(singInStatus),
            ),
          ),
        ],
      ),
    );
  }
}
