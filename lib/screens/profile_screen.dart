import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/component/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/component/post_card.dart';
import 'package:travel/functions/function.dart';
import '../component/login_prompt.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

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

      getInformation(userId);
      _getCurrentUser();
    });
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

  Future<void> getInformation(String userId) async {
    await checkUserId(userId);
    await getUserProfile(userId);
  }

  Future<void> checkUserId(String userId) {
    if (userId == FirebaseAuth.instance.currentUser?.uid) {
      isMyProfile = true;
    } else {
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

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // Web用に画像のバイトデータを取得
    );

    if (result != null && result.files.isNotEmpty) {
      Uint8List? fileBytes = result.files.first.bytes;
      String fileName = "${widget.userId}.jpg";
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Firebase Storage にアップロードする場合
      final storageRef =
          FirebaseStorage.instance.ref().child("user_icons/$fileName");
      await storageRef.putData(
        fileBytes!,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uid': userId},
        ),
      );
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'iconURL': imageUrl, 'hasPhoto': true});

      setState(() {
        userImageURL = imageUrl;
      });

      print("画像のURL: $imageUrl");
    } else {
      print("画像が選択されませんでした");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: "プロフィール",
      ),
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
              recruitmentPostIdList.isNotEmpty
                  ? PostCard(postIds: recruitmentPostIdList)
                  : Text("今までの募集はありません")
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
                userImageURL != ''
                    ? GestureDetector(
                        onTap: isMyProfile ? _pickImage : null,
                        child: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(userImageURL)),
                      )
                    : GestureDetector(
                        onTap: isMyProfile ? _pickImage : null,
                        child: CircleAvatar(
                          radius: 40,
                          child: Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: Colors.grey,
                          ),
                          backgroundColor: Colors.grey[200],
                        ),
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
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
                                icon: Icon(Icons.settings,
                                    color: AppColor.subTextColor),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 6),
                      isMyProfile
                          ? ElevatedButton.icon(
                              onPressed: () async {
                                final updatedProfile =
                                    await context.push('/edit-profile');

                                if (updatedProfile != null) {
                                  final profileData = updatedProfile
                                      as Map<String, dynamic>; // 型キャストを追加
                                  setState(() {
                                    // 受け取ったデータで画面を更新
                                    name = profileData['name'];
                                    bio = profileData['bio'];
                                    hobbies = List<String>.from(
                                        profileData['hobbies']); // 型変換を追加
                                  });
                                }
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
                                  onPressed:
                                      _toggleFollow, // フォロー状態を切り替える関数を呼び出す
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
