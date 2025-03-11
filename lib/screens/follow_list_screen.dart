import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/functions/function.dart';

class FollowListScreen extends StatefulWidget {
  const FollowListScreen({super.key});

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  List<UserInformation> followUserList = [];

  @override
  void initState() {
    super.initState();
    buildFollowList();
  }

  void buildFollowList() async {
    String userId = await getUserId();
    List<String> followIdList = await getFollowList(userId);
    followUserList = await getFollowUserList(followIdList);
    setState(() {
      followUserList = followUserList;
    });
  }

  Future<String> getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return "ログインしていません";
    } else {
      return user.uid;
    }
  }

  Future<List<String>> getFollowList(String userId) async {
    List<String> followIdList = [];
    DocumentReference userRef =
        FirebaseFirestore.instance.collection("users").doc(userId);
    await userRef.get().then((user) {
      if (user.exists) {
        followIdList = List<String>.from(user["following"]);
      } else {
        print("フォローしている人がいません");
      }
    });
    return followIdList;
  }

  Future<List<UserInformation>> getFollowUserList(
      List<String> followIdList) async {
    List<UserInformation> followUserList = [];
    for (int i = 0; i < followIdList.length; i++) {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection("users").doc(followIdList[i]);
      await userRef.get().then((user) {
        UserInformation followUser = UserInformation(
            userId: followIdList[i],
            photoURL: user['photoURLs'][0],
            name: user['name'],
            age: calculateAge(user['birthday'].toDate()),
            gender: user['gender']);
        followUserList.add(followUser);
      });
    }
    return followUserList;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // タブの数を指定
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.mainButtonColor,
          title: const Text(
            '仲間と集まる',
            style: TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'フォロー(${followUserList.length})'),
              Tab(text: 'フォロワー(5)'),
              Tab(text: '募集(3)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FollowList(followUserList: followUserList),
            Center(child: Text('フォロワー一覧')), // 仮の画面
            Center(child: Text('募集一覧')), // 仮の画面
          ],
        ),
      ),
    );
  }
}

class FollowList extends StatelessWidget {
  final List<UserInformation> followUserList;

  const FollowList({super.key, required this.followUserList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: followUserList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: followUserList[index].photoURL != ''
                ? NetworkImage(followUserList[index].photoURL)
                : null,
          ),
          title: Text('${followUserList[index].name}、${followUserList[index].age}、${followUserList[index].gender}'),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {}, // 削除機能を後で追加
          ),
        );
      },
    );
  }
}

class UserInformation {
  String userId;
  String photoURL;
  String name;
  int age;
  String gender;

  UserInformation(
      {required this.userId,
      required this.photoURL,
      required this.name,
      required this.age,
      required this.gender});
}














// バックアップとして残しておく
// class FollowListScreen extends StatefulWidget {
//   const FollowListScreen({super.key});

//   @override
//   _FollowListScreenState createState() => _FollowListScreenState();
// }

// class _FollowListScreenState extends State<FollowListScreen> {
//   late Future<List<User>> _followList;

//   @override
//   void initState() {
//     super.initState();
//     _followList = fetchFollowList();
//   }

// Future<void> getFollowingList() async {
//   User? user = FirebaseAuth.instance.currentUser;

//   if (user != null) {
//     DocumentSnapshot<Object?> snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .get();

//     // ドキュメントのデータを取得
//     Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

//     if (data != null && data.containsKey('following')) {
//       List<dynamic> followingList = data['following']; // following フィールドの配列を取得

//       print("Following List: $followingList");
//     } else {
//       print("Following list is empty or does not exist.");
//     }
//   } else {
//     print("User is not logged in.");
//   }
//     if (user != null) {
//     // ユーザーがログインしている場合
//     print("User ID: ${user.uid}");
//   } else {
//     // ユーザーがログインしていない場合
//     print("No user is logged in.");
//   }


//       DocumentSnapshot<Object?> snapshot = await FirebaseFirestore.instance
//     .collection('users')
//     .doc(user.uid)
//     .get();
//   }
// }

     


//   Future<void> unfollowUser(String userId) async {
//     await FirebaseFirestore.instance
//         .collection('following')
//         .doc(userId)
//         .delete();
//     setState(() {
//       _followList = fetchFollowList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('フォロー一覧'),
//       ),
//       body: FutureBuilder<List<User>>(
//         future: _followList,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('フォローがいません'));
//           }
//           return ListView.builder(
//             itemCount: snapshot.data!.length,
//             itemBuilder: (context, index) {
//               final user = snapshot.data![index];
//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundImage: NetworkImage(user.avatarUrl),
//                 ),
//                 title: Text(user.name),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.remove_circle, color: Colors.red),
//                   onPressed: () => unfollowUser(user.id),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
