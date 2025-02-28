import 'package:flutter/material.dart';

class Follower {
  final String name;
  final String avatarUrl;

  Follower({required this.name, required this.avatarUrl});
}

class FollowerListScreen extends StatelessWidget {
  FollowerListScreen({super.key});

  // ダミーデータ
  final List<Follower> followers = List.generate(
    10,
    (index) => Follower(
      name: 'フォロワー $index',
      avatarUrl: 'https://via.placeholder.com/150', // ダミー画像URL
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フォロワー一覧'),
      ),
      body: ListView.builder(
        itemCount: followers.length,
        itemBuilder: (context, index) {
          final follower = followers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(follower.avatarUrl),
            ),
            title: Text(follower.name),
            onTap: () {
              // ここでフォロワーの詳細画面に遷移する処理などを追加
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${follower.name} をタップしました')),
              );
            },
          );
        },
      ),
    );
  }
}
