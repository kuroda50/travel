import 'package:flutter/material.dart';
import '../colors/color.dart';
import 'package:go_router/go_router.dart';

void showLoginPrompt(BuildContext context) {
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
                      side: const BorderSide(color: Colors.black),
                    ),
                    padding: const EdgeInsets.symmetric(
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
                const SizedBox(width: 16), // ボタン間のスペース
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColor.mainButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                  ),
                  child: const Text(
                    'ログイン',
                    style: TextStyle(color: AppColor.subTextColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.pushNamed('login');
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
