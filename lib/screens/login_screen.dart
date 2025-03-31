// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel/component/header.dart';
import 'package:go_router/go_router.dart';
import '../colors/color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscured = true;
  String _errorMessage = ''; // エラーメッセージの状態を管理

  Future<void> _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    setState(() {
      _errorMessage = ''; // ログイン試行前にエラーメッセージをクリア
    });
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "メールアドレスとパスワードを入力してください";
      });
      return;
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ログイン成功！")),
      );
      context.go('/travel');
    } on FirebaseAuthException catch (e) {
      String errorMessage = "ログインに失敗しました";
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = "メールアドレスまたはパスワードが違います";
      }
      setState(() {
        _errorMessage = errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: "ログイン",
      ),
      backgroundColor: Color(0xFFF5EEDC),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // メールアドレス入力
                _buildLabel('メールアドレス'),
                _buildTextField(controller: emailController),
                SizedBox(height: 15),

                // パスワード入力
                _buildLabel('パスワード'),
                _buildTextField(
                    controller: passwordController, obscureText: _isObscured),
                if (_errorMessage.isNotEmpty) // エラーメッセージがある場合のみ表示
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: AppColor.warningColor, fontSize: 12),
                    ),
                  ),
                SizedBox(height: 15),

                // 「パスワードをお忘れですか？」 + テキストの長さに合わせた横線
                _buildForgotPassword(context),
                SizedBox(height: 15),

                // 「ログイン」ボタン
                Center(
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF559900),
                      minimumSize: Size(200, 50),
                    ),
                    child: Text('ログイン',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),

                SizedBox(height: 20),

                // OR + 左右の横線
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  ],
                ),

                SizedBox(height: 20),

                // 「アカウントを作る」ボタン
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      context.push("/account-create");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF559900),
                      minimumSize: Size(200, 50),
                    ),
                    child: Text('アカウントを作る',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(
      {bool obscureText = false, required TextEditingController controller}) {
    return TextField(
      obscureText: obscureText,
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: controller == passwordController
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
      ),
    );
  }

  // 「パスワードをお忘れですか？」の下にテキストと同じ長さの横線を配置
  Widget _buildForgotPassword(BuildContext context) {
    String text = 'パスワードをお忘れですか？';

    return LayoutBuilder(
      builder: (context, constraints) {
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        double textWidth = textPainter.width;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                context.push('/password-change');
              },
              child: Text(
                text,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
