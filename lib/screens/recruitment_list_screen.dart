import 'package:flutter/material.dart';

// 性別
// 年齢max、年齢min
// 写真があるか
// どこへ行くか（方面）
// 現在地
class RecruitmentListScreen extends StatelessWidget {
  final String gender;
  final int ageMax;
  final int ageMin;
  final bool hasPhoto;
  final String area;
  final String prefecture;
  const RecruitmentListScreen(
      {super.key,
      required this.gender,
      required this.ageMax,
      required this.ageMin,
      required this.hasPhoto,
      required this.area,
      required this.prefecture});

  Future<List<String>> fetchFilteredRecruitment(String gender, int ageMax,
      int ageMin, bool hasPhoto, String area, String prefecture) {
        
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('募集一覧'),
      ),
      body: const Center(
        child: Text('募集一覧画面'),
      ),
    );
  }
}
