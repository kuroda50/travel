import 'package:flutter/material.dart';

class AccountCreateScreen extends StatelessWidget {
  const AccountCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント作成'),
      ),
      body: const Center(
        child: Text('アカウント作成画面'),
      ),
    );
  }
}
