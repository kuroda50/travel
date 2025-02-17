import 'package:flutter/material.dart';

class MessageRoomScreen extends StatelessWidget {
  const MessageRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メッセージルーム'),
      ),
      body: const Center(
        child: Text('メッセージルーム画面'),
      ),
    );
  }
}
