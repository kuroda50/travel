import 'package:flutter/material.dart';

class FollowerListScreen extends StatelessWidget {
  const FollowerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フォロワー一覧'),
      ),
      body: const Center(
        child: Text('フォロワー一覧画面'),
      ),
    );
  }
}
