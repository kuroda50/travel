import 'package:flutter/material.dart';

class RecruitmentListScreen extends StatelessWidget {
  const RecruitmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('募集一覧'),
      ),
      body: const Center(
        child: Text('募集一覧画面'),
      ),
    );
  }
}