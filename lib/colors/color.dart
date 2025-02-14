import 'package:flutter/material.dart';

// ここでアプリで使用する色を定義する(現在は仮の色を設定)
class AppColor {
  static const Color backgroundColor = Colors.white; //アプリの背景色
  static const Color subBackgroundColor = Color(0xF9F7F5); //アプリの背景色
  
  static const Color activeColor = Color(0xDEFFCD); //通知などの色
  static const Color nonActiveColor = Color(0xE0E0E0); //灰色。選択してないタブや押せないボタンに使う

  static const Color warningColor = Color(0xFF0000); //警告の赤色。

  static const Color mainButtonColor = Color(0x559900); //一つ目のボタンカラー
  static const Color subButtonColor = Color(0xE0E0E0); //二つ目のボタンカラー

  static const Color mainTextColor = Colors.black;
  static const Color subTextColor = Colors.white;
}
