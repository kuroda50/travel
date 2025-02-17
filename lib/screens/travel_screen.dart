import 'package:flutter/material.dart';

class TravelScreen extends StatelessWidget {
  const TravelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('旅へ行く'),
      ),
      body: const Center(
        child: Text('旅へ行く画面'),
      ),
    );
  }
}
