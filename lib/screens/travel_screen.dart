import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TravelScreen extends StatelessWidget {
  const TravelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('旅へ行く'),
      ),
      body: Center(
          child: Column(
        children: [
          Text('旅へ行く画面'),
          ElevatedButton(
              onPressed: () {
                String postId = 'bgvY4C5aQH3LVfsrMhFj';
                context.go('/recruitment', extra: postId);
              },
              child: Text("aaa"))
        ],
      )),
    );
  }
}
