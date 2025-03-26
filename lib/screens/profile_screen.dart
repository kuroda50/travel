// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/component/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/functions/function.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isMyProfile = false;
  bool isFollowing = false; // フォロー状態を管理する変数
  String name = '', age = '', bio = '', title = '', userImageURL = '';
  String? currentUserId; // 現在のユーザーIDを管理する変数
  List<String> hobbies = [],
      targetGroups = [],
      destinations = [],
      days = [],
      recruitmentPostIdList = [];
  List<RecruitmentPost> recruitmentPosts = [];

  @override
  void initState() {
    super.initState();
    getInformation();
    _getCurrentUser(); // 現在のユーザー情報を取得する関数を呼び出す
  }

  void _getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
      _checkIfFollowing(widget.userId); // フォロー状態をチェックする関数を呼び出す
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
    if (currentUserId == null) return;

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

  getInformation() async {
    await checkUserId(widget.userId);
    await getUserProfile(widget.userId);
    await fetchRecruitmentList();
  }

  Future<void> checkUserId(String userId) {
    if (userId == FirebaseAuth.instance.currentUser!.uid) {
      print('自分のプロフィールを見ています');
      isMyProfile = true;
    } else {
      print('他人のプロフィールを見ています');
      isMyProfile = false;
    }
    setState(() {
      isMyProfile = isMyProfile;
    });
    return Future.value();
  }

  Future<void> getUserProfile(String userId) async {
    // ユーザー情報を取得する処理
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    var user = await userRef.get();
    if (user.exists) {
      print("ユーザ情報を取得します");
      name = user['name'];
      age = calculateAge(user['birthday'].toDate()).toString();
      bio = user['bio'];
      hobbies = List<String>.from(user['hobbies'] as List);
      userImageURL = user['hasPhoto'] ? user['photoURLs'][0] : '';
      recruitmentPostIdList =
          List<String>.from(user['participatedPosts'] as List);
      setState(() {
        name = name;
        age = age;
        hobbies = hobbies;
        bio = bio;
        userImageURL = userImageURL;
      });
    } else {
      print("ユーザが見つかりません");
    }
  }

  Future<void> fetchRecruitmentList() async {
    recruitmentPosts = await getRecruitmentList(recruitmentPostIdList);
    setState(() {
      recruitmentPosts = recruitmentPosts;
    });
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: "プロフィール",),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              SizedBox(height: 20),
              Text('今までの募集',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildRecruitmentList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      userImageURL != '' ? NetworkImage(userImageURL) : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${name}  ${age}歳',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isMyProfile) // isMyProfileがtrueの時だけ表示する
                            Container(
                              decoration: BoxDecoration(
                                color: AppColor.mainButtonColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  context.push('/settings');
                                },
                                icon: Icon(Icons.settings, color: AppColor.subTextColor),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 6),
                      isMyProfile
                          ? ElevatedButton.icon(
                              onPressed: () {
                                context.push('/edit-profile');
                              },
                              icon: Icon(Icons.edit,
                                  color: AppColor.subTextColor),
                              label: Text(
                                'プロフィールを編集する',
                                style: TextStyle(color: AppColor.subTextColor),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.mainButtonColor,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            )
                          : Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.mainButtonColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: () async {
                                      await goMessageScreen();
                                    },
                                    icon: Icon(Icons.mail,
                                        color: AppColor.subTextColor),
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _toggleFollow, // フォロー状態を切り替える関数を呼び出す
                                  child: Text(
                                    isFollowing ? 'フォロー中' : 'フォロー',
                                    style:
                                        TextStyle(color: AppColor.subTextColor),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColor.mainButtonColor),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text('自己紹介文', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('${bio}'),
                  SizedBox(height: 16),
                  Text('趣味', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children:
                        hobbies.map((hobby) => Chip(label: Text(hobby))).toList(),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          );
        }

  Widget _buildRecruitmentList() {
  if (recruitmentPosts.isEmpty) {
    return Text(
      '今までの募集はありません',
      style: TextStyle(fontSize: 16, color: Colors.grey),
    );
  }

  return Column(
    children: recruitmentPosts.map((post) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              Text(post.destinations.map((destination) => destination).join('、')),
              Text('${post.organizerName}、${post.organizerAge}歳'),
              Text(
                  '${post.startDate}~${post.endDate} ${post.days.map((destination) => destination).join('')}'),
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

// チャットルームを作成する関数を追加
Future<void> goMessageScreen() async {
  if (FirebaseAuth.instance.currentUser == null) {
    _showLoginPrompt(context);
    return;
  }
  String participantId = FirebaseAuth.instance.currentUser!.uid;
  String roomId = await findOrCreateRoom(participantId, widget.userId);

  context.push('/message-room',
      extra: {"roomId": roomId, "currentUserId": participantId});
}

Future<String?> findExistingRoom(String userIdA, String userIdB) async {
    String roomKey = generateRoomKey(userIdA, userIdB);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("chatRooms")
        .where("roomKey", isEqualTo: roomKey)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id; // 既存の roomId を返す
    }
    return null; // 見つからなかった場合は null
  }

Future<String> findOrCreateRoom(String participantId, String targetUserId) async {
  // 既存のチャットルームを探す
  String? existingRoomId = await findExistingRoom(participantId, targetUserId);
  if (existingRoomId != null) {
    return existingRoomId; // 既存のルームが見つかった場合はそれを返す
  }

  // ルームがなければ新規作成
  String roomKey = generateRoomKey(participantId, targetUserId);
  DocumentReference newRoomRef = FirebaseFirestore.instance.collection("chatRooms").doc(); // 自動生成ID

  WriteBatch batch = FirebaseFirestore.instance.batch();

  // 新しいチャットルームを作成
  batch.set(newRoomRef, {
    "postId": "",
    "postTitle": "",
    "participants": [participantId, targetUserId], // 参加者を設定
    "roomKey": roomKey,
    "createdAt": Timestamp.now(),
    "group": false,
    "latestMessage": {
      "text": "",
      "sender": "",
      "timeStamp": "",
      "readBy": [],
    }
  });

  await batch.commit();

  // ユーザーのチャットルームリストを更新
  await updateUserChatRooms(participantId, newRoomRef.id);
  await updateUserChatRooms(targetUserId, newRoomRef.id);

  return newRoomRef.id;
}

Future<void> updateUserChatRooms(String userId, String roomId) async {
  final userRef = FirebaseFirestore.instance.collection("users").doc(userId);

  await userRef.update({
    "chatRooms": FieldValue.arrayUnion([roomId])
  });

  print("$userId の chatRooms に $roomId を追加");
}

void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ログインが必要です'),
          content: const Text('この機能を利用するにはログインが必要です。ログインしますか？'),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.black),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                    ),
                    child: const Text(
                      'キャンセル',
                      style: TextStyle(color: AppColor.mainTextColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 16), // ボタン間のスペース
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColor.mainButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                    ),
                    child: const Text(
                      'ログイン',
                      style: TextStyle(color: AppColor.subTextColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
