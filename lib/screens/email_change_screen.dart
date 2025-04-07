import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/component/header.dart';

class EmailChangeScreen extends StatefulWidget {
  const EmailChangeScreen({super.key});

  @override
  _EmailChangeScreenState createState() => _EmailChangeScreenState();
}

class _EmailChangeScreenState extends State<EmailChangeScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  static const Color warningColor = Color(0xFFFF0000);

  Future<void> _changeEmail() async {
    final newEmail = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    if (newEmail.isEmpty && password.isEmpty) {
      setState(() {
        errorMessage = "メールアドレスとパスワードを入力してください";
        isLoading = false;
      });
      return;
    } else if (newEmail.isEmpty) {
      setState(() {
        errorMessage = "新しいメールアドレスを入力してください";
        isLoading = false;
      });
      return;
    } else if (password.isEmpty) {
      setState(() {
        errorMessage = "パスワードを入力してください";
        isLoading = false;
      });
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('ユーザーがログインしていません');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // 新しいメールアドレスを設定する前に確認メールを送信
      await user.verifyBeforeUpdateEmail(newEmail);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('確認メールを送信しました。メールを確認してください。')),
      );

      // ログアウトしてログイン画面に遷移
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        context.go('/login'); // ログイン画面へのルートに遷移
      }
    } on FirebaseAuthException catch (e) {
      String errorText = "エラーが発生しました: ${e.message}";

      if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'user-disabled' ||
          e.code == 'user-not-found') {
        errorText = "パスワードが間違っています";
      } else if (e.code == 'email-already-in-use') {
        errorText = "このメールアドレスは既に使われています";
      } else if (e.code == 'invalid-email') {
        errorText = "メールアドレスの形式が正しくありません";
      } else if (e.code == 'requires-recent-login') {
        errorText = "もう一度ログインしてから試してください";
      }

      setState(() {
        errorMessage = errorText;
      });
    } catch (e) {
      setState(() {
        errorMessage = "エラーが発生しました: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: 'メールアドレス変更'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: '新しいメールアドレス',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: '現在のパスワード',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: warningColor, fontSize: 14),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : _changeEmail, // isLoadingがtrueの場合、ボタンを無効化
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('メールアドレスを変更'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
