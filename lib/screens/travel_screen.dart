import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // go_router をインポート
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'travel_search.dart'; // ここに追加
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
    'lib/screens/images/OIP (1).jpg',
    'lib/screens/images/OIP (2).jpg',
    'lib/screens/images/OIP (3).jpg',
    'lib/screens/images/OIP (4).jpg',
    'lib/screens/images/OIP (5).jpg',
    'lib/screens/images/OIP (6).jpg',
    'lib/screens/images/OIP (7).jpg',
    'lib/screens/images/OIP (8).jpg',
    'lib/screens/images/OIP (9).jpg',
    'lib/screens/images/OIP (10).jpg',
    'lib/screens/images/OIP.jpg',
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
          organizerGroup: doc['organizerGroup'] ?? 'グループ不明',
          targetGroups: doc['targetGroups'] ?? '対象不明',
          targetAgeMin: doc['targetAgeMin'] ?? 0,
          targetAgeMax: doc['targetAgeMax'] ?? 100,
          targetHasPhoto: doc['targetHasPhoto'] ?? '不明',
          destinations: List<String>.from(doc['destinations'] ?? []),
          organizerName: doc['organizerName'] ?? '主催者不明',
          organizerAge: doc['organizerAge'] ?? 0,
          startDate: doc['startDate'] ?? '開始日不明',
          endDate: doc['endDate'] ?? '終了日不明',
          days: List<String>.from(doc['days'] ?? []),
          organizerPhotoURL: doc['organizerPhotoURL'] ?? '',
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
      appBar: Header(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        '旅行仲間と\n集まる',
                        textAlign: TextAlign.center,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        '同じ趣味の人と\n集まる',
                        textAlign: TextAlign.center,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TravelSearch()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('検索条件を設定する'),
                      Icon(Icons.search),
                    ],
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
                    Text('全て表示する >'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // 人を募集する処理
                    },
                    child: Text('人を募集する'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
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
    // サンプルデータ
    List<Post> latestPosts = [
      Post(
        postId: '1',
        title: '2週間でアメリカ、カナダ巡り',
        organizerGroup: '旅行グループA',
        targetGroups: '20代',
        targetAgeMin: 20,
        targetAgeMax: 35,
        targetHasPhoto: '写真あり',
        destinations: ['アメリカ', 'カナダ'],
        organizerName: 'てつろう',
        organizerAge: 20,
        startDate: '2025/04/01',
        endDate: '2025/04/30',
        days: ['金', '土', '日'],
        organizerPhotoURL: 'lib/screens/images/OIP (1).jpg',
      ),
      Post(
        postId: '2',
        title: '週末温泉旅行',
        organizerGroup: '温泉同好会',
        targetGroups: '30代以上',
        targetAgeMin: 30,
        targetAgeMax: 100,
        targetHasPhoto: '写真なし',
        destinations: ['箱根', '熱海'],
        organizerName: 'たろう',
        organizerAge: 40,
        startDate: '2025/05/10',
        endDate: '2025/05/12',
        days: ['土', '日'],
        organizerPhotoURL: 'lib/screens/images/OIP (2).jpg',
      ),
      Post(
        postId: '3',
        title: '一人旅仲間募集',
        organizerGroup: '一人旅グループB',
        targetGroups: '年齢不問',
        targetAgeMin: 0,
        targetAgeMax: 100,
        targetHasPhoto: '不明',
        destinations: ['京都'],
        organizerName: 'さくら',
        organizerAge: 25,
        startDate: '2025/06/01',
        endDate: '2025/06/05',
        days: ['月', '火', '水', '木', '金'],
        organizerPhotoURL: 'lib/screens/images/OIP (3).jpg',
      ),
      Post(
        postId: '4',
        title: 'グルメツアー',
        organizerGroup: 'グルメグループC',
        targetGroups: '20代～40代',
        targetAgeMin: 20,
        targetAgeMax: 40,
        targetHasPhoto: '写真あり',
        destinations: ['大阪'],
        organizerName: 'けんた',
        organizerAge: 30,
        startDate: '2025/07/15',
        endDate: '2025/07/16',
        days: ['土', '日'],
        organizerPhotoURL: 'lib/screens/images/OIP (4).jpg',
      ),
    ];

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
  final String? targetGroups;
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
