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
          child: ElevatedButton(
        onPressed: () {
          context.push('/recruitment-list', extra: (12, 'Taro'));
        },
        child: Text('旅へ行く画面'),
      )),
    );
  }
}
