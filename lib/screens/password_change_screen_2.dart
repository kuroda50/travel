import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // go_routerのインポート

class PasswordChangeScreen2 extends StatelessWidget {
  const PasswordChangeScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('パスワード変更手順'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'パスワードを変更するための手順が電子メールに送信されました。',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // OKボタンを押すと画面1に戻る
                context.go('/login');
              },
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}