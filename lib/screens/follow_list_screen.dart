import 'package:flutter/material.dart';

class FollowListScreen extends StatelessWidget {
  const FollowListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フォロー一覧'),
      ),
      body: const Center(
        child: Text('フォロー一覧画面'),
      ),
    );
  }
}
