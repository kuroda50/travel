import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/component/header.dart';
import 'package:travel/colors/color.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth パッケージをインポート
import 'package:fluttertoast/fluttertoast.dart'; // トースト表示用パッケージをインポート

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  bool _isLoading = false; // ローディング状態を管理

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

  Future<void> _submit() async {
    final error = _validateEmail(_emailController.text);
    setState(() {
      _emailError = error;
    });
    if (error == null) {
      setState(() {
        _isLoading = true; // ローディング開始
      });
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
        // パスワードリセットメール送信成功
        Fluttertoast.showToast(
          msg: "パスワードリセットメールを送信しました",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        context.go('/password-change-2'); // 成功したら次の画面へ遷移
      } on FirebaseAuthException catch (e) {
        // パスワードリセットメール送信失敗
        String errorMessage = 'エラーが発生しました。しばらくしてから再度お試しください。';
        if (e.code == 'auth/user-not-found') {
          errorMessage = 'このメールアドレスは登録されていません。';
        } else if (e.code == 'auth/invalid-email') {
          errorMessage = 'メールアドレスの形式が正しくありません。';
        }
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } finally {
        setState(() {
          _isLoading = false; // ローディング終了
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: 'パスワード変更リクエスト',
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
                errorText: _emailError,
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {
                  _emailError = null;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit, // ローディング中はボタンを無効化
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.mainButtonColor,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : Text('次へ'),
            ),
          ],
        ),
      ),
    );
  }
}