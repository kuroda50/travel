import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: Center(
        child: Column(
          children: [
            buildButton('メールアドレスを変更する', isFirst: true),
            buildButton('パスワードを変更する'),
            buildButton('ログアウト'),
            buildButton('アカウントを削除する', isLast: true),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String text, {bool isFirst = false, bool isLast = false}) {
    BorderRadius borderRadius = BorderRadius.only(
      topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
      topRight: isFirst ? const Radius.circular(16) : Radius.zero,
      bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
      bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
    );

    return Container(
      width: 300,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: Colors.black),
      ),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
              side: const BorderSide(color: Colors.black),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
