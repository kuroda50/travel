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
  final int itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: "アカウント一覧"),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppColor.subBackgroundColor, // AppColorクラスから色を使用
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      context.go('/profile');
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text('旅の仲間',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
            ),
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
                  List<DocumentSnapshot> paginatedDocs =
                      allDocs.skip(currentPage * itemsPerPage).take(itemsPerPage).toList();

                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: paginatedDocs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      return ListItem(
                        userId: document.id,
                        name: data['name'] ?? '名前',
                        birthday: data['birthday'] != null
                            ? (data['birthday'] as Timestamp).toDate()
                            : null,
                        location: data['location'] ?? '場所',
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  int pageNumber = index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentPage = pageNumber;
                        });
                      },
                      child: Text(
                        (pageNumber + 1).toString(),
                        style: TextStyle(
                          fontWeight: currentPage == pageNumber
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: currentPage == pageNumber
                              ? Colors.blue
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                }),
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
  final DateTime? birthday;
  final String location;

  ListItem({required this.userId, required this.name, required this.birthday, required this.location});

  int? getAge() {
    if (birthday == null) return null;
    DateTime now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month ||
        (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.subBackgroundColor,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${name}、${getAge() != null ? getAge().toString() + "歳" : "年齢不明"}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(location, style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () {
              context.go('/profile', extra: userId);
            },
          ),
        ],
      ),
    );
  }
}