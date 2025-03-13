import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel/component/header.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/colors/color.dart'; // colorsフォルダのcolor.dartをインポート

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
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
                        photoURL: (data['photoURLs'] as List<dynamic>?)?.isNotEmpty == true
                            ? data['photoURLs'][0]
                            : null,
                        birthday: data['birthday'] != null
                            ? (data['birthday'] as Timestamp).toDate()
                            : null,
                        gender: data['gender'] ?? '不明',
                        hobby: data['hobbies'] != null && data['hobbies'].isNotEmpty
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
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return SizedBox(); // データがない場合はボタンを非表示
                  }

                  int totalPages = (snapshot.data!.docs.length / itemsPerPage).ceil();
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
                              fontWeight: currentPage == index ? FontWeight.bold : FontWeight.normal,
                              color: currentPage == index ? Colors.blue : Colors.black,
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

class ListItem extends StatelessWidget {
  final String userId;
  final String name;
  final String? photoURL;
  final DateTime? birthday;
  final String gender;
  final String hobby;

  ListItem({
    required this.userId,
    required this.name,
    this.photoURL,
    required this.birthday,
    required this.gender,
    required this.hobby,
  });

  int? getAge() {
    if (birthday == null) return null;
    DateTime now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month || (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/profile', extra: userId);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.subBackgroundColor,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: photoURL != null ? NetworkImage(photoURL!) : null,
              child: photoURL == null ? Icon(Icons.person, color: Colors.white, size: 30) : null,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name、${getAge() != null ? getAge().toString() + "歳" : "年齢不明"}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        gender == '男性' ? Icons.male : Icons.female,
                        size: 16,
                        color: gender == '男性' ? Colors.blue : Colors.pink,
                      ),
                      SizedBox(width: 4),
                      Text(gender, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.sports_baseball, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(hobby, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.favorite_border, color: Colors.grey), // いいねボタン（仮）
          ],
        ),
      ),
    );
  }
}
