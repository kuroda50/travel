import 'package:flutter/material.dart';

class RecruitmentPostScreen extends StatelessWidget {
  const RecruitmentPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('募集投稿'),
      ),
      body: const Center(
        child: Text('募集投稿画面'),
      ),
    );
  }
}
