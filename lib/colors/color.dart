import 'package:flutter/material.dart';

// ここでアプリで使用する色を定義する(他に必要な色があったら、各自追加してください)
class AppColor {
  static const Color backgroundColor = Colors.white; //1つ目のアプリの背景色
  static const Color subBackgroundColor = Color(0xFFF9F7F5); //2つ目のアプリの背景色

  static const Color activeColor = Color(0xFFDEFFCD); //通知などの色
  static const Color nonActiveColor = Color(0xFFE0E0E0); //灰色。選択してないタブや押せないボタンに使う

  static const Color warningColor = Color(0xFFFF0000); //警告の赤色。

  static const Color mainButtonColor = Color(0xFF559900); //1つ目のボタンカラー
  static const Color subButtonColor = Color(0xFFE0E0E0); //2つ目のボタンカラー

  static const Color mainTextColor = Colors.black; //1つ目のテキストカラー
  static const Color subTextColor = Colors.white; //2つ目のテキストカラー
}