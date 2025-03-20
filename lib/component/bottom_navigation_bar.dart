import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/colors/color.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 追加

class CustomBottomNavigationBar extends StatelessWidget {
  final Widget child;

  const CustomBottomNavigationBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    int selectedIndex = _getSelectedIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex == -1 ? 0 : selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
        selectedItemColor: selectedIndex == -1
            ? AppColor.nonActiveColor
            : AppColor.mainButtonColor, // 選択中のアイコン・テキストの色
        unselectedItemColor: AppColor.nonActiveColor, // 非選択時のアイコン・テキストの色
        showUnselectedLabels: true, // 非選択時のラベルも表示
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: '旅仲間'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '同じ趣味'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'メッセージ'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
      ),
    );
  }

  /// 現在のページに応じてボトムナビゲーションの選択状態を決定
  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    switch (location) {
      case '/travel':
        return 0;
      case '/same-hobby':
        return 1;
      case '/message':
        return 2;
      case '/follow-list':
        return 3;
      case '/profile':
        return 4;
      default:
        return -1;
    }
  }

  /// ボタンを押したときに対応する画面へ遷移
  void _onItemTapped(BuildContext context, int index) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && (index == 2 || index == 3 || index == 4)) {
      _showLoginPrompt(context);
      return;
    }

    switch (index) {
      case 0:
        context.go('/travel');
        break;
      case 1:
        context.go('/same-hobby');
        break;
      case 2:
        context.go('/message');
        break;
      case 3:
        context.go('/follow-list');
        break;
      case 4:
        context.go('/profile', extra: user!.uid);
        break;
    }
  }

  /// ログインを促すウインドウを表示
  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ログインが必要です'),
          content: const Text('この機能を利用するにはログインが必要です。ログインしますか？'),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.black),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                    ),
                    child: const Text(
                      'キャンセル',
                      style: TextStyle(color: AppColor.mainTextColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 16), // ボタン間のスペース
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColor.mainButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                    ),
                    child: const Text(
                      'ログイン',
                      style: TextStyle(color: AppColor.subTextColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
