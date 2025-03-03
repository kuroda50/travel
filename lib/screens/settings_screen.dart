import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
            buildButton(context, 'メールアドレスを変更する', isFirst: true, showDialog: false),
            buildButton(context, 'パスワードを変更する', showDialog: false),
            buildButton(context, 'ログアウト', isLogout: true),
            buildButton(context, 'アカウントを削除する', isLast: true, isDelete: true),
          ],
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context,  String text, {bool isFirst = false, bool isLast = false,  bool isLogout = false, bool isDelete = false, bool showDialog = true}) {
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
          onPressed: () =>{
            if(showDialog){
              showConfirmationDialog(context, text, isLogout, isDelete),
            }else{
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceholderScreen(title: text),
                ),
              )
            }
          },
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

void showConfirmationDialog(BuildContext context, String title, bool isLogout, bool isDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(isLogout
              ? 'ログアウトしますか？'
              : isDelete
                  ? 'アカウントを削除しますか？\n削除すると復元できません。'
                  : ''),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (isLogout) {
                  // ログアウト処理
                  try {
                    FirebaseAuth.instance.signOut();
                  } catch (e) {
                    print(e);
                  }
                } else if (isDelete) {
                  // アカウント削除処理
                  try { 
                    FirebaseAuth.instance.currentUser?.delete();
                  } catch (e) {
                    print(e);
                  }
                } else {
                  // その他処理
                }
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      }
    );
  }

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title の画面')),
    );
  }
}
