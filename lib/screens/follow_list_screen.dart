import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// class User {
//   final String id;
//   final String name;
//   final String avatarUrl;

//   User({required this.id, required this.name, required this.avatarUrl});
// }

class FollowListScreen extends StatefulWidget {
  const FollowListScreen({super.key});

  @override
  _FollowListScreenState createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  late Future<List<User>> _followList;

  @override
  void initState() {
    super.initState();
    _followList = fetchFollowList();
  }

Future<void> getFollowingList() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    DocumentSnapshot<Object?> snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // ドキュメントのデータを取得
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

    if (data != null && data.containsKey('following')) {
      List<dynamic> followingList = data['following']; // following フィールドの配列を取得

      print("Following List: $followingList");
    } else {
      print("Following list is empty or does not exist.");
    }
  } else {
    print("User is not logged in.");
  }
}

     
  if (user != null) {
    // ユーザーがログインしている場合
    print("User ID: ${user.uid}");
  } else {
    // ユーザーがログインしていない場合
    print("No user is logged in.");
  }


      DocumentSnapshot<Object?> snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();
  }
}
  Future<void> unfollowUser(String userId) async {
    await FirebaseFirestore.instance
        .collection('following')
        .doc(userId)
        .delete();
    setState(() {
      _followList = fetchFollowList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フォロー一覧'),
      ),
      body: FutureBuilder<List<User>>(
        future: _followList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('フォローがいません'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
                title: Text(user.name),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => unfollowUser(user.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
