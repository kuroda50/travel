import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/colors/color.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final Widget child;

  const CustomBottomNavigationBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getSelectedIndex(context),
        onTap: (index) => _onItemTapped(context, index),
        selectedItemColor: AppColor.mainButtonColor , // 選択中のアイコン・テキストの色
        unselectedItemColor: AppColor.nonActiveColor, // 非選択時のアイコン・テキストの色
        showUnselectedLabels: true, // 非選択時のラベルも表示
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: '旅仲間'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '同じ趣味'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'メッセージ'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'アカウント'),
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
      case '/recruitment-post':
        return 4;
      default:
        return 0; // エラーが出るので一時的に0にしておく
    }
  }

  /// ボタンを押したときに対応する画面へ遷移
  void _onItemTapped(BuildContext context, int index) {
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
        context.go('/recruitment-post');
        break;
    }
  }
}


