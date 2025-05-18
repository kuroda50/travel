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
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../component/login_prompt.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool isFollowing = false; // フォロー状態を管理する変数
  String name = '', age = '', bio = '', title = '', userImageURL = '';
  String userId = '';
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
      userId = user!.uid;

      if (userId.isEmpty) {
        showLoginPrompt(context);
        return;
      }

      getUserProfile(userId);
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

  Future<void> _pickImage() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final userDoc = await userRef.get();

    //アップロード制限をチェックする
    final lastUploaded = userDoc.data()?['lastUploaded']?.toDate();
    final now = DateTime.now();
    if (lastUploaded != null && now.difference(lastUploaded).inHours < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("プロフィール画像は1時間に1回まで変更できます。")),
      );
      return;
    }

    //画像を選択する
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // Web用に画像のバイトデータを取得
    );

    if (result != null && result.files.isNotEmpty) {
      Uint8List? fileBytes = result.files.first.bytes;
      String fileName = "${userId}.jpg";

      // ✅ 圧縮処理をここに追加
      final compressedBytes = await FlutterImageCompress.compressWithList(
        fileBytes!,
        quality: 70, // ✅ 画質を70%に
        format: CompressFormat.jpeg,
      );

      // Firebase Storage にアップロードする場合
      final storageRef =
          FirebaseStorage.instance.ref().child("user_icons/$fileName");
      await storageRef.putData(
        Uint8List.fromList(compressedBytes), // ✅ 圧縮後のデータをアップロード
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uid': userId},
        ),
      );
      final imageUrl = await storageRef.getDownloadURL();

      // ✅ 🔥 サムネイル生成（100x100px & 画質60%）
      final thumbnailBytes = await FlutterImageCompress.compressWithList(
        fileBytes,
        minWidth: 100,
        minHeight: 100,
        quality: 60,
        format: CompressFormat.jpeg,
      );

      // ✅ サムネイルアップロード
      final thumbRef = FirebaseStorage.instance
          .ref()
          .child("user_icons/thumbnails/$fileName");
      await thumbRef.putData(
        Uint8List.fromList(thumbnailBytes),
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uid': userId},
        ),
      );
      final thumbnailUrl = await thumbRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'iconURL': imageUrl,
        'thumbnailURL': thumbnailUrl,
        'hasPhoto': true,
        "lastUploaded": now
      });

      setState(() {
        userImageURL = imageUrl;
      });
    } else {
      print("画像が選択されませんでした");
    }
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
                        onTap: _pickImage,
                        child: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(userImageURL)),
                      )
                    : GestureDetector(
                        onTap: _pickImage,
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
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColor.mainButtonColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                context.pushNamed('settings');
                              },
                              icon: const Icon(Icons.settings,
                                  color: AppColor.subTextColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final updatedProfile =
                              await context.pushNamed('editProfile');

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
                        icon: const Icon(Icons.edit,
                            color: AppColor.subTextColor),
                        label: const Text(
                          'プロフィールを編集する',
                          style: TextStyle(color: AppColor.subTextColor),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.mainButtonColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
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
}
