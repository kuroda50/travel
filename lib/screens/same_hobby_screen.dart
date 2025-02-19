import 'package:flutter/material.dart';

class SameHobbyScreen extends StatelessWidget {
  const SameHobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('同じ趣味'),
      ),
      body: const Center(
        child: Text('同じ趣味画面'),
      ),
    );
  }
}
