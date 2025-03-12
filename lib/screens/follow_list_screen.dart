import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/component/header.dart';
import 'package:travel/functions/function.dart';
import 'package:go_router/go_router.dart';

class FollowListScreen extends StatefulWidget {
  const FollowListScreen({super.key});

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  List<UserInformation> followingUserList = [];
  List<UserInformation> followerUserList = [];
  List<RecruitmentPost> followerPostsList = [];
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
    List<RecruitmentPost> tempFollowerPostsList =
        await buildFollowPostsList(userId);
    setState(() {
      followingUserList = tempFollowingUserList;
      followerUserList = tempFollowerUserList;
      followerPostsList = tempFollowerPostsList;
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
    List<String> followIdList = await getFollowingList(userId);
    followingUserList = await getFollowingUserList(followIdList);
    return followingUserList;
  }

  Future<List<String>> getFollowingList(String userId) async {
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

  Future<List<UserInformation>> getFollowingUserList(
      List<String> followIdList) async {
    List<UserInformation> followingUserList = [];
    for (String followId in followIdList) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(followId)
          .get();
      if (userSnapshot.exists) {
        UserInformation followUser = UserInformation(
            userId: followId,
            photoURL: userSnapshot['photoURLs'][0],
            name: userSnapshot['name'],
            age: calculateAge(userSnapshot['birthday'].toDate()),
            gender: userSnapshot['gender']);
        followingUserList.add(followUser);
      }
    }
    print("ここまで実行2");
    return followingUserList;
  }

  Future<List<UserInformation>> buildFollowerList(String userId) async {
    List<String> followerIdList = await getFollowerList(userId);
    followerUserList = await getFollowerUserList(followerIdList);
    return followerUserList;
  }

  Future<List<String>> getFollowerList(String userId) async {
    List<String> followerPostsIdList = [];
    DocumentReference userRef =
        FirebaseFirestore.instance.collection("users").doc(userId);
    await userRef.get().then((user) {
      if (user.exists) {
        followerPostsIdList = List<String>.from(user["followers"]);
      } else {
        print("フォローがいません");
      }
    });
    return followerPostsIdList;
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
        UserInformation followerUser = UserInformation(
            userId: followerIdList[i],
            photoURL: userSnapshot['photoURLs'][0],
            name: userSnapshot['name'],
            age: calculateAge(userSnapshot['birthday'].toDate()),
            gender: userSnapshot['gender']);
        followerUserList.add(followerUser);
      }
    }
    return followerUserList;
  }

  Future<List<RecruitmentPost>> buildFollowPostsList(String userId) async {
    List<String> followerPostsIdList = await getFollowerPostsIdList(userId);
    followerPostsList = await getFollowerPostsList(followerPostsIdList);
    return followerPostsList;
  }

  Future<List<String>> getFollowerPostsIdList(String userId) async {
    List<String> followerPostsIdList = [];
    DocumentReference userRef =
        FirebaseFirestore.instance.collection("users").doc(userId);
    await userRef.get().then((user) {
      followerPostsIdList = List<String>.from(user["favoritePosts"]);
    });
    return followerPostsIdList;
  }

  Future<List<RecruitmentPost>> getFollowerPostsList(
      List<String> followerIdList) async {
    return await getRecruitmentList(followerIdList);
  }

  Widget _buildRecruitmentList() {
    if (followerPostsList.isEmpty) {
      return Center(
        child: Text("ブックマークしている募集がありません"),
      );
    }
    return Column(
      children: followerPostsList.map((post) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(post.organizerPhotoURL),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${post.title}'),
                Text(
                    '${post.organizerGroup}>${post.targetGroups} ${post.targetAgeMin}歳~${post.targetAgeMax}歳 ${post.targetHasPhoto}'),
                Text(post.destinations
                    .map((destination) => destination)
                    .join('、')),
                Text('${post.organizerName}、${post.organizerAge}歳'),
                Text(
                    '${post.startDate}~${post.endDate} ${post.days.map((destination) => destination).join('')}')
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

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty ||
        followingUserList.isEmpty &&
            followerUserList.isEmpty &&
            followerPostsList.isEmpty) {
      return Scaffold(
        appBar: Header(title: "お気に入り",),
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
              Tab(text: '募集(${followerPostsList.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FollowingList(userId: userId, followUserList: followingUserList),
            FollowerList(userId: userId, followerUserList: followerUserList),
            _buildRecruitmentList(),
          ],
        ),
      ),
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

    await batch.commit();

    print('フォロー関係を解除しました');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.followUserList.isEmpty) {
      return Center(
        child: Text("フォローしているユーザがいません"),
      );
    }

    return ListView.builder(
      itemCount: widget.followUserList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: widget.followUserList[index].photoURL != ''
                ? NetworkImage(widget.followUserList[index].photoURL)
                : null,
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
            context.push('/profile',
                extra: widget.followUserList[index].userId);
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
      return Center(
        child: Text("フォロワーがいません"),
      );
    }
    return ListView.builder(
      itemCount: followerUserList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: followerUserList[index].photoURL != ''
                ? NetworkImage(followerUserList[index].photoURL)
                : null,
          ),
          title: Text(
              '${followerUserList[index].name}、${followerUserList[index].age}、${followerUserList[index].gender}'),
          // ブロック機能を後で追加する
          // trailing: IconButton(
          //   icon: const Icon(Icons.close),
          //   onPressed: () {
          //     blockFollower(followerUserList[index].userId);
          //   },
          // ),
          onTap: () {
            context.push('/profile', extra: followerUserList[index].userId);
          },
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
