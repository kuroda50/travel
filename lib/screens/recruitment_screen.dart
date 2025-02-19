import 'package:flutter/material.dart';

class RecruitmentScreen extends StatelessWidget {
  const RecruitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('募集'),
      ),
      body: const Center(
        child: Text('募集画面'),
      ),
    );
  }
}
