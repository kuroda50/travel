import 'package:flutter/material.dart';
import 'package:travel/component/post.dart';

class TravelScreen extends StatelessWidget {
  const TravelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('旅へ行く'),
      ),
      body: Column(
        children: [
          PostWidget(postId: "bgvY4C5aQH3LVfsrMhFj"),
          SizedBox(height: 10),
          PostWidget(postId: "bgvY4C5aQH3LVfsrMhFj"),
          SizedBox(height: 10),
        ],
      ),
      
    );
  }
}
