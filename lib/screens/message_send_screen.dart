import 'package:flutter/material.dart';

class MessageSendScreen extends StatelessWidget {
  const MessageSendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メッセージ送信'),
      ),
      body: const Center(
        child: Text('メッセージ送信画面'),
      ),
    );
  }
}
