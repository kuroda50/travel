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
      appBar: Header(
        title: "募集",
      ),
      body: SingleChildScrollView(
        child: PostCard(postIds: widget.postIds),
      ),
    );
  }
}
