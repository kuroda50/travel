// ignore_for_file: use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, duplicate_ignore, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, sort_child_properties_last, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // go_router をインポート
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel/colors/color.dart';
import 'dart:async';
import 'package:travel/component/header.dart';

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
  List<Post> latestPosts = []; // 投稿データを格納

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

  Future<List<Post>> getRecruitmentList(List<String> postIds) async {
    List<Post> posts = [];

    for (String postId in postIds) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      if (doc.exists) {
        posts.add(Post(
          postId: doc.id,
          title: doc['title'] ?? 'タイトルなし',
          organizerGroup: doc['organizer']['organizerGroup'],
          targetGroups: List<String>.from(doc['target']['targetGroups'] ?? []),
          targetAgeMin: doc['target']['ageMin'] ?? 0,
          targetAgeMax: doc['target']['ageMax'] ?? 100,
          targetHasPhoto: doc['target']['hasPhoto'] == true
              ? 'はい'
              : 'いいえ', // bool を String に変換
          destination: List<String>.from(doc['where']['destination'] ?? []),
          organizerName: doc['organizer']['organizerName'] ?? '主催者不明',
          organizerAge: doc['organizer']['organizerBirthday'] != null
              ? DateTime.now().year -
                  (doc['organizer']['organizerBirthday'] as Timestamp)
                      .toDate()
                      .year
              : null,
          startDate: doc['when']['startDate'] != null
              ? (doc['when']['startDate'] as Timestamp)
                  .toDate()
                  .toIso8601String()
              : null,
          endDate: doc['when']['endDate'] != null
              ? (doc['when']['endDate'] as Timestamp).toDate().toIso8601String()
              : null,

          days: List<String>.from(doc['when']['dayOfWeek'] ?? []),
          organizerPhotoURL: doc['organizer']['photoURL'] ?? '',
        ));
      }
    }

    return posts;
  }

  Future<void> fetchLatestPosts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(4)
        .get();

    latestPostIds = querySnapshot.docs.map((doc) => doc.id).toList();
    latestPosts = await getRecruitmentList(latestPostIds);
    setState(() {});
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    context.push('/travel_search');
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                _buildLatestPostsSection(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          // 全ての投稿のIDを取得
                          QuerySnapshot querySnapshot = await FirebaseFirestore
                              .instance
                              .collection('posts')
                              .get();
                          List<String> allPostIds =
                              querySnapshot.docs.map((doc) => doc.id).toList();

                          // 次の画面に全ての投稿のIDを渡す
                          context.push('/recruitment-list', extra: allPostIds);
                        },
                        child: Text('全て表示する >'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestPostsSection() {
    Map<String, String> reverseGenderMap = {
      'male': '男性',
      'female': '女性',
      'family': '家族',
      'group': 'グループ'
    };

    Map<String, String> reverseDayMap = {
      'Mon': '月',
      'Tue': '火',
      'Wed': '水',
      'Thu': '木',
      'Fri': '金',
      'Sat': '土',
      'Sun': '日'
    };

    return Column(
      children: latestPosts.map((post) {
        String organizerGroup = reverseGenderMap[post.organizerGroup] ?? '不明';
        String days =
            post.days?.map((day) => reverseDayMap[day] ?? day).join(', ') ??
                '日程不明';
        String targetGroups = post.targetGroups
                ?.map((group) => reverseGenderMap[group] ?? group)
                .join(', ') ??
            '対象不明';

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: (post.organizerPhotoURL != null &&
                      post.organizerPhotoURL!.isNotEmpty)
                  ? NetworkImage(post.organizerPhotoURL!)
                  : null,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(post.title ?? 'タイトルなし'),
                Text(
                    '${post.startDate != null ? post.startDate!.substring(0, 10) : '開始日不明'}~${post.endDate != null ? post.endDate!.substring(0, 10) : '終了日不明'} $days'),
                Text(post.destination?.join('、') ?? '目的地なし'),
                Text('$organizerGroup > $targetGroups'),
                Text(
                    '${post.targetAgeMin ?? '年齢不明'}歳以上 ${post.targetAgeMax ?? '年齢不明'}歳以下 '),
                Text(
                    '${post.organizerName ?? '主催者不明'}、${post.organizerAge ?? '年齢不明'}歳')
              ],
            ),
            onTap: () {
              print("postId:${post.postId}");
              context.push('/recruitment', extra: post.postId);
            },
          ),
        );
      }).toList(),
    );
  }
}

class Post {
  final String postId;
  final String? title;
  final String? organizerGroup;
  final List<String>? targetGroups;
  final int? targetAgeMin;
  final int? targetAgeMax;
  final String? targetHasPhoto;
  final List<String>? destination;
  final String? organizerName;
  final int? organizerAge;
  final String? startDate;
  final String? endDate;
  final List<String>? days;
  final String? organizerPhotoURL;

  Post({
    required this.postId,
    this.title,
    this.organizerGroup,
    this.targetGroups,
    this.targetAgeMin,
    this.targetAgeMax,
    this.targetHasPhoto,
    this.destination,
    this.organizerName,
    this.organizerAge,
    this.startDate,
    this.endDate,
    this.days,
    this.organizerPhotoURL,
  });
}

  // "where": {
  //     "area": "アジア",
  //     "destination": ["台湾","中国"],
  // }
  // "when": {
  //     "startDate":"2025-02-28",
  //     "endDate":"2025-03-02",
  //     "dayOfWeek":["Fri","Sat","Sun"],
  // }
  // "target": {
  //     "targetGroups": ["female","male"],
  //     "ageMax": 29,
  //     "ageMin": 20,
  //     "hasPhoto": true
  // },
  // "organizer": {
  //     "organizerGroup": "female",
  //     "organizerBirthday": "2005-02-24",
  //     "hasPhoto": true,
  // }
  // "budget": {
  //     "budgetMin": 10, //nullでもok
  //     "budgetMax": 15, //nullでもok
  //     "budgetType": "splitEvenly" //nullでもok
  // }
  // "meetingPlace": {
  //     "region": "日本", //nullでもok
  //     "departure": "福岡県", //nullでもok
  // }
  // "title": "北欧、ヨーロッパ旅行",
  // "tags": ["オーロラ","犬ぞり","北欧","ヨーロッパ"],
  // "expire": false,