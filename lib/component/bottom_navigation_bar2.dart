import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel/component/login_prompt.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  bool _isProtectedTab(int index) {
    // 1: 募集投稿, 2: メッセージ, 3: お気に入り, 4: マイページ
    return index == 1 || index == 2 || index == 3 || index == 4;
  }

  bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (_isProtectedTab(index) && !isLoggedIn()) {
          showLoginPrompt(context);
        } else {
          onTap(index);
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'さがす'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: '募集投稿'),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'メッセージ'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
      ],
    );
  }
}
