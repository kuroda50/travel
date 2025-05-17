import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/colors/color.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 追加
import 'login_prompt.dart';
import 'package:travel/app_router.dart';

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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'さがす'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '募集投稿'),
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
    final extra = GoRouterState.of(context).extra;
    final String? userId = extra is String ? extra : null; // `extra`がStringなら取得
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    switch (location) {
      case '/travel':
        return 0;
      case '/recruitment-post':
        return 1;
      case '/message':
        return 2;
      case '/follow-list':
        return 3;
      case '/profile':
        // `extra`に現在のユーザーのIDが含まれていればハイライト、それ以外は非ハイライト
        return (userId != null && userId == currentUserId) ? 4 : -1;
      default:
        return -1;
    }
  }

  /// ボタンを押したときに対応する画面へ遷移
  void _onItemTapped(BuildContext context, int index) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null &&
        (index == 1 || index == 2 || index == 3 || index == 4)) {
      showLoginPrompt(context);
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.travel);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.recruitmentPost);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.message);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.followList);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }
}
