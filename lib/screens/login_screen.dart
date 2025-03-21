import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel/component/header.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscured = true; // パスワードの表示状態を管理

  Future<void> _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("メールアドレスとパスワードを入力してください")),
      );
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
      // ログイン成功時に '/travel' に遷移
      context.go('/travel'); // ここを変更
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ログイン失敗: ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: "ログイン",
      ),
      backgroundColor: Color(0xFFF5EEDC), // 背景色
      body: SingleChildScrollView(
        // スマホ対応
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
              children: [
                // メールアドレス入力
                _buildLabel('メールアドレス'),
                _buildTextField(controller: emailController),
                SizedBox(height: 15),

                // パスワード入力
                _buildLabel('パスワード'),
                _buildTextField(
                    controller: passwordController, obscureText: _isObscured), // 変更
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
        suffixIcon: controller == passwordController // パスワードフィールドのみアイコンを表示
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
        // テキストの横幅を測定
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(color: Colors.grey, fontSize: 40),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        double textWidth = textPainter.width; // テキストの幅を取得

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {},
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