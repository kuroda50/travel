// ignore_for_file: use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, duplicate_ignore, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, sort_child_properties_last, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // go_router をインポート
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel/colors/color.dart';
import 'dart:async';
import 'package:travel/component/header.dart';
import 'package:travel/component/post_card.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({Key? key}) : super(key: key);

  @override
  _TravelScreenState createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  List<String> latestPostIds = []; // 投稿の ID を格納
  List<Map<String, dynamic>> cachedPosts = [];

  final List<String> _imageUrls = [
    'assets/images/OIP (1).jpg',
    'assets/images/OIP (2).jpg',
    'assets/images/OIP (3).jpg',
    'assets/images/OIP (4).jpg',
    'assets/images/OIP (5).jpg',
    'assets/images/OIP (6).jpg',
    'assets/images/OIP (7).jpg',
    'assets/images/OIP (8).jpg',
    'assets/images/OIP (9).jpg',
    'assets/images/OIP (10).jpg',
    'assets/images/OIP.jpg',
  ];

  @override
  void initState() {
    super.initState();

    // 最新の投稿を取得
    fetchLatestPosts();

    // 3秒ごとに次のページへ移動する
    // ignore: prefer_const_constructors
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _imageUrls.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // 最後まで行ったら最初に戻る
      }
      if (mounted) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> fetchLatestPosts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(4)
        .get();
    setState(() {
      latestPostIds = querySnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: Header(
          title: "旅へ行こう！",
        ),
        body: SafeArea(
          child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.push('/travel_search');
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('募集を検索する'),
                              Icon(Icons.search),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // 画像スライドショーを追加
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            width: 390,
                            height: 227,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _imageUrls.length,
                              itemBuilder: (context, index) {
                                return Image.asset(
                                  _imageUrls[index],
                                  fit: BoxFit.cover,
                                );
                              },
                              onPageChanged: (int page) {
                                setState(() {
                                  _currentPage = page;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16), // 余白追加
                      // 他のウィジェット
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/same-hobby');
                            },
                            child: Text('同じ趣味の人をさがす'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.mainButtonColor,
                              foregroundColor: AppColor.subTextColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16), // 余白追加
                      latestPostIds.isEmpty
                          ? Center(
                              child:
                                  CircularProgressIndicator()) // データ取得中はローディングを表示
                          : PostCard(postIds: latestPostIds),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                // 全ての投稿のIDを取得
                                QuerySnapshot querySnapshot =
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .get();
                                List<String> allPostIds = querySnapshot.docs
                                    .map((doc) => doc.id)
                                    .toList();

                                // 次の画面に全ての投稿のIDを渡す
                                context.push('/recruitment-list',
                                    extra: allPostIds);
                              },
                              child: Text('全て表示する >'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
