import 'package:flutter/material.dart';

class Follow {
  final String name;
  final String avatarUrl;

  Follow({required this.name, required this.avatarUrl});
}

class FollowListScreen extends StatelessWidget {
  FollowListScreen({super.key});

  // ダミーデータ
  final List<Follow> follows = List.generate(
    10,
    (index) => Follow(
      name: 'ユーザー $index',
      avatarUrl: 'https://via.placeholder.com/150', // ダミー画像URL
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フォロー一覧'),
      ),
      body: ListView.builder(
        itemCount: follows.length,
        itemBuilder: (context, index) {
          final follow = follows[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(follow.avatarUrl),
            ),
            title: Text(follow.name),
            onTap: () {
              // フォローユーザーの詳細画面に遷移する処理（後で追加可能）
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${follow.name} をタップしました')),
              );
            },
          );
        },
      ),
    );
  }
}
