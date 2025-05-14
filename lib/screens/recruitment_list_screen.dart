import 'package:flutter/material.dart';
import 'package:travel/component/header.dart';
import '../component/post_card.dart';

class RecruitmentListScreen extends StatefulWidget {
  final List<String> postIds;
  RecruitmentListScreen({super.key, required this.postIds});

  @override
  State<RecruitmentListScreen> createState() => _RecruitmentListScreenState();
}

class _RecruitmentListScreenState extends State<RecruitmentListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(
        title: "募集",
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
              child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600, // 🔄 最大600px（スマホ幅に固定）
            ),
            child: PostCard(postIds: widget.postIds),
          ))),
    );
  }
}
