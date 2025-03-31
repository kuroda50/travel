import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/component/header.dart';

class EmailChangeScreen extends StatelessWidget {
  const EmailChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future<void> checkEmailVerified() async {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload(); // 最新のユーザー情報を取得
      if (user != null && user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メールアドレスが認証されました！')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メールが未確認です。認証メールのリンクをクリックしてください。')),
        );
      }
    }

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
        final User? user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          throw Exception('ログインしてください');
        }

        await user.sendEmailVerification();

        // 再認証が必要
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        // メールアドレスを更新
        await user.verifyBeforeUpdateEmail(newEmail);

        // 新しいメールアドレスに確認メールを送信
        await user.sendEmailVerification();//ここでエラーが出る

        // 成功メッセージを表示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メールアドレスを変更しました')),
        );

        // メール認証をチェック
        Future.delayed(const Duration(seconds: 5), checkEmailVerified);

        // /travel画面に遷移
        context.go('/travel');
      } on FirebaseAuthException catch (e) {
        print(e);
        String errorMessage = 'エラーが発生しました';
        if (e.code == 'wrong-password') {
          errorMessage = 'パスワードが間違っています';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'このメールアドレスは既に使用されています';
        } else if (e.code == 'requires-recent-login') {
          errorMessage = 'セキュリティのため、もう一度ログインしてください';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生した: $e')),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.mainButtonColor,
                ),
                onPressed: () => _changeEmail(context),
                child: const Text(
                  'メールアドレスを変更',
                  style: TextStyle(color: AppColor.subTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
