import 'package:flutter/material.dart';

class AccountListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const AccountListScreen({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ユーザー一覧')),
      body: users.isEmpty
          ? const Center(child: Text('該当するユーザーが見つかりません'))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['name'] ?? '名前なし'),
                  subtitle: Text('年齢: ${user['age'] ?? '不明'}'),
                );
              },
            ),
    );
  }
}
