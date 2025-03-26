import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';
import 'package:go_router/go_router.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const Header({super.key, required this.title, this.actions,});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          color: AppColor.subTextColor,
        ),
      ),
      backgroundColor: AppColor.mainButtonColor,
      actions:  actions ?? 
          (FirebaseAuth.instance.currentUser == null
          ? [
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Text("ログイン",
                      style: TextStyle(color: AppColor.mainTextColor)),
                ),
              )
            ]
          : null),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}