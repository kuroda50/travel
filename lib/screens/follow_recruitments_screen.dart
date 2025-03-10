import 'package:flutter/material.dart';

class FollowRecruitmentsScreen extends StatelessWidget {
  const FollowRecruitmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フォローしている募集'),
      ),
      body: const Center(
        child: Text('フォローしている募集'),
      ),
    );
  }
}
