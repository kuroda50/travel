import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel/component/header.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/colors/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../component/login_prompt.dart';

class AccountListScreen extends StatefulWidget {
  final List<String>? userIds;

  AccountListScreen({this.userIds});

  @override
  _AccountListScreenState createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  int currentPage = 0;
  final int itemsPerPage = 20;

  Future<List<DocumentSnapshot>> _fetchUserData() async {
    List<DocumentSnapshot> userDocs = [];

    if (widget.userIds == null || widget.userIds!.isEmpty) {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      userDocs = snapshot.docs;
    } else {
      for (String userId in widget.userIds!) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          userDocs.add(userDoc);
        }
      }
    }
    return userDocs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: "アカウント一覧"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: _fetchUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('エラーが発生しました'));
                  }
                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(child: Text('データがありません'));
                  }

                  List<DocumentSnapshot> allDocs = snapshot.data!;
                  // int totalPages = (allDocs.length / itemsPerPage).ceil();

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
                        iconURL: data['iconURL'] ?? '',
                        birthday: data['birthday'] != null
                            ? (data['birthday'] as Timestamp).toDate()
                            : null,
                        gender: data['gender'] ?? '不明',
                        hobbies: data['hobbies'] is List
                            ? List<String>.from(data['hobbies'])
                            : (data['hobbies'] is String
                                ? [data['hobbies']]
                                : []),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: _fetchUserData(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SizedBox();
                  }

                  int totalPages =
                      (snapshot.data!.length / itemsPerPage).ceil();
                  totalPages = totalPages > 0 ? totalPages : 1;

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
  final List<String>? hobbies;
  final String? iconURL;
  final String? gender;

  ListItem({
    required this.userId,
    required this.name,
    required this.birthday,
    required this.hobbies,
    this.iconURL,
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

  void _getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
      _checkIfFollowing(widget.userId);
    }
  }

  Future<void> _checkIfFollowing(String targetId) async {
    if (currentUserId == null) return;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    List<String> following =
        (userSnapshot.data()?['following'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

    setState(() {
      isFollowing = following.contains(targetId);
    });
  }

  Future<void> _toggleFollow() async {
    final currentUserRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);
    final targetUserRef =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);

    if (isFollowing) {
      await currentUserRef.update({
        'following': FieldValue.arrayRemove([widget.userId])
      });
      await targetUserRef.update({
        'followers': FieldValue.arrayRemove([currentUserId])
      });
    } else {
      await currentUserRef.update({
        'following': FieldValue.arrayUnion([widget.userId])
      });
      await targetUserRef.update({
        'followers': FieldValue.arrayUnion([currentUserId])
      });
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

  String getHobbiesText() {
    if (widget.hobbies == null || widget.hobbies!.isEmpty) {
      return '趣味なし';
    }
    if (widget.hobbies!.length > 2) {
      return '${widget.hobbies!.take(2).join(", ")} ……';
    }
    return widget.hobbies!.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentUser = currentUserId == widget.userId; // 自分自身かどうか判定

    return GestureDetector(
      onTap: () {
        if (FirebaseAuth.instance.currentUser == null) {
          showLoginPrompt(context);
          return;
        }
        context.push('/profile/${widget.userId}'); // URL パラメータとして userId を渡す
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    widget.iconURL != null && widget.iconURL!.isNotEmpty
                        ? NetworkImage(widget.iconURL!)
                        : null, // URLが空の場合はnullを設定
                child: widget.iconURL == null || widget.iconURL!.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.grey) // 仮のアイコン
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.name}、${getAge() != null ? getAge().toString() + "歳" : "年齢不明"}',
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (widget.gender == "male")
                          const Icon(Icons.male,
                              color: Colors.blue, size: 20) // 男性アイコン（青）
                        else if (widget.gender == "female")
                          const Icon(Icons.female,
                              color: Colors.red, size: 20) // 女性アイコン（赤）
                        else
                          const Icon(Icons.help_outline,
                              color: Colors.grey, size: 20), // 不明な場合のアイコン
                        const SizedBox(width: 8),
                        Text(
                          widget.gender ?? '不明',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.sports_baseball,
                            size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(getHobbiesText(), style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isCurrentUser) // 自分自身のアカウントでない場合のみフォローボタンを表示
                ElevatedButton(
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      showLoginPrompt(context);
                      return;
                    }
                    _toggleFollow();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFollowing ? Colors.grey : AppColor.mainButtonColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isFollowing ? 'フォロー解除' : 'フォロー',
                    style: const TextStyle(
                      color: AppColor.subTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
