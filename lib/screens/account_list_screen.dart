import 'package:flutter/material.dart';

class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント一覧'),
      ),
      body: const Center(
        child: Text('アカウント一覧画面'),
      ),
    );
  }
}
