import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/component/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/component/post_card.dart';
import 'package:travel/functions/function.dart';
import '../component/login_prompt.dart';

class OthersProfileScreen extends StatefulWidget {
  final String userId;

  const OthersProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<OthersProfileScreen> createState() => _OthersProfileScreenState();
}

class _OthersProfileScreenState extends State<OthersProfileScreen> {
  bool isFollowing = false; // フォロー状態を管理する変数
  String name = '', age = '', bio = '', title = '', userImageURL = '';
  String? currentUserId; // 現在のユーザーIDを管理する変数
  List<String> hobbies = [],
      targetGroups = [],
      destinations = [],
      days = [],
      recruitmentPostIdList = [];

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  void _initializeProfile() async {
    FirebaseAuth.instance
        .authStateChanges()
        .firstWhere((user) => user != null)
        .then((user) {
      String userId = widget.userId.isEmpty ? user!.uid : widget.userId;

      if (userId.isEmpty) {
        showLoginPrompt(context);
        return;
      }

      getUserProfile(userId);
      _getCurrentUser();
    });
  }

  Future<void> getUserProfile(String userId) async {
    // ユーザー情報を取得する処理
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    var user = await userRef.get();
    if (user.exists) {
      name = user['name'] ?? '';
      age = user['birthday'] != null
          ? calculateAge(user['birthday'].toDate()).toString()
          : '';
      bio = user['bio'] ?? '';
      hobbies = List<String>.from(user['hobbies'] ?? []);
      userImageURL = user['hasPhoto'] ? user['iconURL'] : '';
      List<String> tempRecruitmentPostIdList =
          List<String>.from(user['participatedPosts'] ?? []);
      setState(() {
        name = name;
        age = age;
        hobbies = hobbies;
        bio = bio;
        userImageURL = userImageURL;
        recruitmentPostIdList = tempRecruitmentPostIdList;
      });
    } else {
      print("ユーザが見つかりません");
    }
  }

  void _getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
      _checkIfFollowing(widget.userId);
    } else {
      print("ユーザーがログインしていません。");
      setState(() {
        currentUserId = null; // 明示的に null を設定
      });
    }
  }

  Future<void> _checkIfFollowing(String targetId) async {
    if (currentUserId == null || targetId.isEmpty) return;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(
        title: "プロフィール",
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
                child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600, // 🔄 最大600px（スマホ幅に固定）
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 20),
                  const Text('今までの募集',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  recruitmentPostIdList.isNotEmpty
                      ? PostCard(postIds: recruitmentPostIdList)
                      : const Text("今までの募集はありません")
                ],
              ),
            ))),
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
                userImageURL != ''
                    ? GestureDetector(
                        child: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(userImageURL)),
                      )
                    : GestureDetector(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                          child: const Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                const SizedBox(width: 12),
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
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColor.mainButtonColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () async {
                                await goMessageScreen();
                              },
                              icon: const Icon(Icons.mail,
                                  color: AppColor.subTextColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _toggleFollow, // フォロー状態を切り替える関数を呼び出す
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.mainButtonColor),
                            child: Text(
                              isFollowing ? 'フォロー中' : 'フォロー',
                              style:
                                  const TextStyle(color: AppColor.subTextColor),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('自己紹介文', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${bio}'),
            const SizedBox(height: 16),
            const Text('趣味', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  hobbies.map((hobby) => Chip(label: Text(hobby))).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

// チャットルームを作成する関数を追加
  Future<void> goMessageScreen() async {
    if (FirebaseAuth.instance.currentUser == null) {
      showLoginPrompt(context);
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

  Future<String> findOrCreateRoom(
      String participantId, String targetUserId) async {
    // 既存のチャットルームを探す
    String? existingRoomId =
        await findExistingRoom(participantId, targetUserId);
    if (existingRoomId != null) {
      return existingRoomId; // 既存のルームが見つかった場合はそれを返す
    }

    // ルームがなければ新規作成
    String roomKey = generateRoomKey(participantId, targetUserId);
    DocumentReference newRoomRef =
        FirebaseFirestore.instance.collection("chatRooms").doc(); // 自動生成ID

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
        "timeStamp": Timestamp.now(),
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
}
