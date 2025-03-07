import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // go_routerのインポート

class PasswordChangeScreen extends StatelessWidget {
  const PasswordChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();

    // メールアドレスのバリデーション
    String? _validateEmail(String? value) {
      if (value == null || value.isEmpty) {
        return 'メールアドレスを入力してください';
      }
      String pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b';
      RegExp regex = RegExp(pattern);
      if (!regex.hasMatch(value)) {
        return '正しいメールアドレスを入力してください';
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('パスワード変更リクエスト'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '登録済みメールアドレスを入力してください',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
                errorText: _validateEmail(_emailController.text),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_validateEmail(_emailController.text) == null) {
                  // バリデーション成功後、画面2に遷移
                  context.go('/password-change-2');
                }
              },
              child: Text('次へ'),
            ),
          ],
        ),
      ),
    );
  }
}
