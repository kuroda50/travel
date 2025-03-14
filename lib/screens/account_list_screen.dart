import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel/component/header.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/colors/color.dart'; // colorsフォルダのcolor.dartをインポート
import 'package:firebase_auth/firebase_auth.dart';

class AccountListScreen extends StatefulWidget {
  @override
  _AccountListScreenState createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  int currentPage = 0;
  final int itemsPerPage = 5; // 1ページに表示するアイテム数

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: "アカウント一覧"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('エラーが発生しました'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('データがありません'));
                  }

                  List<DocumentSnapshot> allDocs = snapshot.data!.docs;
                  int totalPages = (allDocs.length / itemsPerPage).ceil();

                  List<DocumentSnapshot> paginatedDocs = allDocs
                      .skip(currentPage * itemsPerPage)
                      .take(itemsPerPage)
                      .toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: paginatedDocs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                          paginatedDocs[index].data() as Map<String, dynamic>;
                      return ListItem(
                        userId: paginatedDocs[index].id,
                        name: data['name'] ?? '名前',
                        photoURL:
                            (data['photoURLs'] as List<dynamic>?)?.isNotEmpty ==
                                    true
                                ? data['photoURLs'][0]
                                : null,
                        birthday: data['birthday'] != null
                            ? (data['birthday'] as Timestamp).toDate()
                            : null,
                        gender: data['gender'] ?? '不明',
                        hobby: data['hobbies'] != null &&
                                data['hobbies'].isNotEmpty
                            ? data['hobbies'][0] // 最初の趣味を表示
                            : '趣味なし',
                      );
                    },
                  );
                },
              ),
            ),
            // ページネーションボタン
            Container(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return SizedBox(); // データがない場合はボタンを非表示
                  }

                  int totalPages =
                      (snapshot.data!.docs.length / itemsPerPage).ceil();
                  totalPages = totalPages > 0 ? totalPages : 1; // 最低1ページは表示

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalPages, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              currentPage = index;
                            });
                          },
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              fontWeight: currentPage == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: currentPage == index
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListItem extends StatefulWidget {
  final String userId;
  final String name;
  final DateTime? birthday;
  final String hobby;
  final String? photoURL;
  final String? gender;

  ListItem({
    required this.userId,
    required this.name,
    required this.birthday,
    required this.hobby,
    this.photoURL,
    this.gender,
  });

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  bool isFollowing = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // 現在のログインユーザーを取得
  void _getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
      _checkIfFollowing();
    }
  }

  // フォローしているか確認
  Future<void> _checkIfFollowing() async {
    if (currentUserId == null) return;

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(widget.userId)
        .get();

    setState(() {
      isFollowing = snapshot.exists;
    });
  }

  // フォロー/フォロー解除の処理
  Future<void> _toggleFollow() async {
    if (currentUserId == null) return;

    final followingRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(widget.userId);

    final followersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('followers')
        .doc(currentUserId);

    if (isFollowing) {
      // フォロー解除
      await followingRef.delete();
      await followersRef.delete();
    } else {
      // フォロー
      await followingRef.set({'followedAt': FieldValue.serverTimestamp()});
      await followersRef.set({'followedAt': FieldValue.serverTimestamp()});
    }

    setState(() {
      isFollowing = !isFollowing;
    });
  }

  int? getAge() {
    if (widget.birthday == null) return null;
    DateTime now = DateTime.now();
    int age = now.year - widget.birthday!.year;
    if (now.month < widget.birthday!.month ||
        (now.month == widget.birthday!.month &&
            now.day < widget.birthday!.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/profile', extra: widget.userId);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.subBackgroundColor,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              backgroundImage: widget.photoURL != null
                  ? NetworkImage(widget.photoURL!)
                  : null,
              child: widget.photoURL == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.name}、${getAge() != null ? getAge().toString() + "歳" : "年齢不明"}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      if (widget.gender == "男性")
                        Icon(Icons.male, color: Colors.blue, size: 20)
                      else if (widget.gender == "女性")
                        Icon(Icons.female, color: Colors.red, size: 20)
                      else
                        Icon(Icons.help_outline, color: Colors.grey, size: 20),
                      SizedBox(width: 8),
                      Text(
                        widget.gender ?? '不明',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.sports_baseball, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(widget.hobby, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey : AppColor.mainButtonColor,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isFollowing ? 'フォロー解除' : 'フォロー',
                style: TextStyle(
                  color: AppColor.subTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}