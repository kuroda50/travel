import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel/component/header.dart';
import 'package:go_router/go_router.dart'; // go_routerをインポート

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: "設定"),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 50.0, bottom: 10.0),
                child: Text(
                  'アカウント設定',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            buildButton(context, 'メールアドレスを変更する',
                isFirst: true, showDialog: false, isEmailChange: true), // 変更点
            buildButton(context, 'パスワードを変更する',
                showDialog: false, isPasswordChange: true),
            buildButton(context, 'ログアウト', isLogout: true),
            buildButton(context, 'アカウントを削除する', isLast: true, isDelete: true),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 50.0, bottom: 10.0),
                child: Text(
                  'サービス',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            buildButton(context, '利用規約',
                isTerms: true, isFirst: true, isLast: true, showDialog: false),
          ],
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, String text,
      {bool isFirst = false,
      bool isLast = false,
      bool isLogout = false,
      bool isDelete = false,
      bool showDialog = true,
      bool isTerms = false,
      bool isPasswordChange = false,
      bool isEmailChange = false}) {
    // 変更点
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
          onPressed: () => {
            if (showDialog)
              {
                showConfirmationDialog(
                    context, text, isLogout, isDelete),
              }
            else if (isPasswordChange)
              {
                context.go('/password-change'),
              }
            else if (isEmailChange)
              {
                context.go('/email-change'),
              }
            else if(isTerms)
              {
                context.push('/terms-of-use'),
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

void showConfirmationDialog(BuildContext context, String title, bool isLogout,
    bool isDelete) {
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
                    context.go('/travel'); // ログアウト後に/travelに遷移
                  } catch (e) {
                    print(e);
                  }
                } else if (isDelete) {
                  // アカウント削除処理
                  try {
                    FirebaseAuth.instance.currentUser?.delete();
                    context.go('/travel'); // アカウント削除後に/travelに遷移
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
      });
}

// class PlaceholderScreen extends StatelessWidget {
//   final String title;
//   const PlaceholderScreen({super.key, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       body: Center(child: Text('$title の画面')),
//     );
//   }
// }

// class TermsScreen extends StatelessWidget {
//   const TermsScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('利用規約')),
//       body: const Center(child: Text('ここに利用規約の内容を表示')),
//     );
//   }
// }
