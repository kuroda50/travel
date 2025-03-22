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
          destinations: List<String>.from(doc['where']['destinations'] ?? []),
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
    return Column(
      children: latestPosts.map((post) {
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
                    '${post.organizerGroup ?? 'グループ不明'} > ${post.targetGroups ?? '対象不明'} ${post.targetAgeMin ?? '年齢不明'}歳~${post.targetAgeMax ?? '年齢不明'}歳 ${post.targetHasPhoto ?? '不明'}'),
                Text(post.destinations?.join('、') ?? '目的地なし'),
                Text(
                    '${post.organizerName ?? '主催者不明'}、${post.organizerAge ?? '年齢不明'}歳'),
                Text(
                    '${post.startDate ?? '開始日不明'}~${post.endDate ?? '終了日不明'} ${post.days?.join('') ?? '日程不明'}')
              ],
            ),
            onTap: () {
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
  final List<String>? destinations;
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
    this.destinations,
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