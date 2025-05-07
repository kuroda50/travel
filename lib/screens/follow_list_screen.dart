import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/component/header.dart';
import 'package:travel/component/post_card.dart';
import 'package:travel/functions/function.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FollowListScreen extends StatefulWidget {
  const FollowListScreen({super.key});
  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  List<UserInformation> followingUserList = [];
  List<UserInformation> followerUserList = [];
  List<String> followingPostsIdList = [];
  String userId = '';

  @override
  void initState() {
    super.initState();
    buildList();
  }

  void buildList() async {
    userId = await getUserId();
    List<UserInformation> tempFollowingUserList =
        await buildFollowingList(userId);
    List<UserInformation> tempFollowerUserList =
        await buildFollowerList(userId);
    List<String> tempFollowingPostsIdList =
        await getFollowerPostsIdList(userId);
    setState(() {
      followingUserList = tempFollowingUserList;
      followerUserList = tempFollowerUserList;
      followingPostsIdList = tempFollowingPostsIdList;
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

  Future<List<UserInformation>> buildFollowingList(String userId) async {
    List<String> followingIdList = await getFollowingList(userId);
    followingUserList = await getFollowingUserList(followingIdList);
    return followingUserList;
  }

  Future<List<String>> getFollowingList(String userId) async {
    List<String> followingIdList = [];
    DocumentReference userRef =
        FirebaseFirestore.instance.collection("users").doc(userId);
    await userRef.get().then((user) {
      if (user.exists) {
        followingIdList = List<String>.from(user["following"]);
      } else {
        print("フォローしている人がいません");
      }
    });
    return followingIdList;
  }

  Future<List<UserInformation>> getFollowingUserList(
      List<String> followingIdList) async {
    List<UserInformation> followingUserList = [];
    for (String followingId in followingIdList) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(followingId)
          .get();
      if (userSnapshot.exists) {
        final data = userSnapshot.data() as Map<String, dynamic>;
        UserInformation followUser = UserInformation(
            userId: followingId,
            iconThumnailURL: data['thumbnailURL'] ?? '',
            name: data['name'],
            age: calculateAge(data['birthday'].toDate()),
            gender: data['gender']);
        followingUserList.add(followUser);
      }
    }
    return followingUserList;
  }

  Future<List<UserInformation>> buildFollowerList(String userId) async {
    List<String> followerIdList = await getFollowerList(userId);
    followerUserList = await getFollowerUserList(followerIdList);
    return followerUserList;
  }

  Future<List<String>> getFollowerList(String userId) async {
    List<String> followingPostsIdList = [];
    DocumentReference userRef =
        FirebaseFirestore.instance.collection("users").doc(userId);
    await userRef.get().then((user) {
      if (user.exists) {
        followingPostsIdList = List<String>.from(user["followers"]);
      } else {
        print("フォローがいません");
      }
    });
    return followingPostsIdList;
  }

  Future<List<UserInformation>> getFollowerUserList(
      List<String> followerIdList) async {
    List<UserInformation> followerUserList = [];
    for (int i = 0; i < followerIdList.length; i++) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(followerIdList[i])
          .get();
      if (userSnapshot.exists) {
        final data = userSnapshot.data() as Map<String, dynamic>;
        UserInformation followerUser = UserInformation(
            userId: followerIdList[i],
            iconThumnailURL: data['thumbnailURL'] ?? '',
            name: data['name'],
            age: calculateAge(data['birthday'].toDate()),
            gender: data['gender']);
        followerUserList.add(followerUser);
      }
    }
    return followerUserList;
  }

  Future<List<String>> getFollowerPostsIdList(String userId) async {
    List<String> followingPostsIdList = [];
    DocumentReference userRef =
        FirebaseFirestore.instance.collection("users").doc(userId);
    await userRef.get().then((user) {
      followingPostsIdList = List<String>.from(user["favoritePosts"]);
    });
    return followingPostsIdList;
  }

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return const Scaffold(
        appBar: Header(
          title: "お気に入り",
        ),
        body: Center(child: CircularProgressIndicator()), // ローディング中の表示
      );
    }
    return DefaultTabController(
      length: 3, // タブの数を指定
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor.mainButtonColor,
            title: const Text(
              '旅へ行こう！',
              style: TextStyle(
                fontSize: 20,
                color: AppColor.subTextColor,
              ),
            ),
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'フォロー(${followingUserList.length})'),
                Tab(text: 'フォロワー(${followerUserList.length})'),
                Tab(text: '募集(${followingPostsIdList.length})'),
              ],
            ),
          ),
          body: Center(
              child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600, // 🔄 最大600px（スマホ幅に固定）
            ),
            child: TabBarView(
              children: [
                FollowingList(
                    userId: userId, followUserList: followingUserList),
                FollowerList(
                    userId: userId, followerUserList: followerUserList),
                SingleChildScrollView(
                    child: PostCard(postIds: followingPostsIdList)),
              ],
            ),
          ))),
    );
  }
}

class FollowingList extends StatefulWidget {
  final List<UserInformation> followUserList;
  final String userId;
  const FollowingList(
      {super.key, required this.userId, required this.followUserList});

  @override
  State<FollowingList> createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList> {
  Future<void> deleteFollow(String targetUserId) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final targetUserRef =
        FirebaseFirestore.instance.collection('users').doc(targetUserId);

    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.update(userRef, {
      'following': FieldValue.arrayRemove([targetUserId])
    });
    batch.update(targetUserRef, {
      'followers': FieldValue.arrayRemove([widget.userId])
    });

    try {
      await batch.commit();

      // フォローリストから削除したユーザーを除外
      setState(() {
        widget.followUserList
            .removeWhere((user) => user.userId == targetUserId);
      });

      print('フォロー関係を解除しました');
    } catch (e) {
      print('フォロー解除中にエラーが発生しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.followUserList.isEmpty) {
      return const Center(
        child: Text("フォローしているユーザがいません"),
      );
    }

    return ListView.builder(
      itemCount: widget.followUserList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage: widget.followUserList[index].iconThumnailURL != ''
                ? CachedNetworkImageProvider(
                    widget.followUserList[index].iconThumnailURL)
                : null,
            child: widget.followUserList[index].iconThumnailURL != ''
                ? null
                : const Icon(Icons.person, size: 30, color: Colors.grey),
          ),
          title: Text(
              '${widget.followUserList[index].name}、${widget.followUserList[index].age}、${widget.followUserList[index].gender}'),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              deleteFollow(widget.followUserList[index].userId);
            },
          ),
          onTap: () {
            context.push(
                '/profile/${widget.followUserList[index].userId}'); // URL パラメータとして userId を渡す
          },
        );
      },
    );
  }
}

class FollowerList extends StatelessWidget {
  final List<UserInformation> followerUserList;
  final String userId;

  const FollowerList(
      {super.key, required this.userId, required this.followerUserList});

  Future<void> blockFollower(String targetUserId) async {} //ブロック機能を後で追加

  @override
  Widget build(BuildContext context) {
    if (followerUserList.isEmpty) {
      return const Center(
        child: Text("フォロワーがいません"),
      );
    }
    return ListView.builder(
      itemCount: followerUserList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: followerUserList[index].iconThumnailURL != ''
                ? CachedNetworkImageProvider(
                    followerUserList[index].iconThumnailURL)
                : null,
            child: followerUserList[index].iconThumnailURL != ''
                ? null
                : const Icon(Icons.person, size: 40, color: Colors.grey),
          ),
          title: Text(
              '${followerUserList[index].name}、${followerUserList[index].age}、${followerUserList[index].gender}'),
          // ブロック機能を後で追加する
          onTap: () {
            context.push(
                '/profile/${followerUserList[index].userId}'); // URL パラメータとして userId を渡す
          },
        );
      },
    );
  }
}

class UserInformation {
  String userId;
  String iconThumnailURL;
  String name;
  int age;
  String gender;

  UserInformation(
      {required this.userId,
      required this.iconThumnailURL,
      required this.name,
      required this.age,
      required this.gender});
}
