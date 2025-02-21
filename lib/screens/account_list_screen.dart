import 'package:flutter/material.dart';
import 'package:travel/models/account_filter_params.dart';

class AccountListScreen extends StatefulWidget {
  final AccountFilterParams accountFilterParams;//ここ
  const AccountListScreen({super.key, required this.accountFilterParams});//ここ

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  @override
  void initState() {
    super.initState();
    print("例えば、このように表示する${widget.accountFilterParams.hobbies[0]}");
    print("例えば、このように表示する${widget.accountFilterParams.ageMax}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント一覧'),
      ),
      body: const Center(
        child: Text('アカウント一覧画面'),
      ),
    );
  }
}
