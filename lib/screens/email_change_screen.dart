import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart'; // GoRouterをインポート
import 'package:travel/component/header.dart'; // ★ カスタムヘッダーをインポート

class EmailChangeScreen extends StatelessWidget {
  const EmailChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // メールアドレスを変更する関数
    Future<void> _changeEmail(BuildContext context) async {
      final newEmail = emailController.text.trim();
      final password = passwordController.text.trim();

      if (newEmail.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メールアドレスとパスワードを入力してください')),
        );
        return;
      }

      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          throw Exception('ユーザーがログインしてません');
        }

        // 再認証が必要
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        // メールアドレスを更新
        await user.updateEmail(newEmail);

        // 成功メッセージを表示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メールアドレスを変更しました')),
        );

        // /travel画面に遷移
        context.go('/travel');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }

    return Scaffold(
      appBar: Header(title: 'メールアドレス変更'), // ★ AppBarをカスタムヘッダーに置き換え
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _changeEmail(context),
                child: const Text('メールアドレスを変更'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}