import 'package:flutter/material.dart';

class PastRecruitmentScreen extends StatelessWidget {
  const PastRecruitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今までの募集'),
      ),
      body: const Center(
        child: Text('今までの募集画面'),
      ),
    );
  }
}
