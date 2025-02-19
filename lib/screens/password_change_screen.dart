import 'package:flutter/material.dart';

class PasswordChangeScreen extends StatelessWidget {
  const PasswordChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('パスワード変更'),
      ),
      body: const Center(
        child: Text('パスワード変更画面'),
      ),
    );
  }
}
