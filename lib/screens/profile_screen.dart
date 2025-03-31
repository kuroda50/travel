import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/component/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/functions/function.dart';
import 'package:image_picker/image_picker.dart'; // 画像ピッカーのインポート
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storageのインポート
import 'dart:io'; // 画像ファイルの取り扱い

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isMyProfile = false;
  String name = '', age = '', bio = '', title = '', userImageURL = '';
  List<String> hobbies = [], targetGroups = [], destinations = [], days = [], recruitmentPostIdList = [];
  List<RecruitmentPost> recruitmentPosts = [];
  File? _image; // 選択した画像を格納する変数

  @override
  void initState() {
    super.initState();
    getInformation();
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
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    var user = await userRef.get();
    if (user.exists) {
      name = user['name'];
      age = calculateAge(user['birthday'].toDate()).toString();
      bio = user['bio'];
      hobbies = List<String>.from(user['hobbies'] as List);
      userImageURL = user['hasPhoto'] ? user['photoURLs'][0] : '';
      recruitmentPostIdList = List<String>.from(user['participatedPosts'] as List);
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

  // 画像選択
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path); // 画像をFileとして保存
      });

      // 画像をFirebase Storageにアップロード
      await _uploadImageToFirebase(_image!);
    }
  }

  // Firebase Storageに画像をアップロード
  Future<void> _uploadImageToFirebase(File image) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("profile_pictures/$userId.jpg");

      // アップロード
      await ref.putFile(image);

      // アップロードが完了したら、URLを取得
      String imageUrl = await ref.getDownloadURL();

      // Firestoreのユーザー情報を更新
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({
        'photoURLs': [imageUrl],
        'hasPhoto': true,
      });

      setState(() {
        userImageURL = imageUrl; // プロフィール画像URLを更新
      });

      print("画像がアップロードされました: $imageUrl");
    } catch (e) {
      print("画像のアップロードに失敗しました: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: "プロフィール"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              SizedBox(height: 20),
              Text('今までの募集', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                GestureDetector(
                  onTap: isMyProfile ? _pickImage : null, // 自分のプロフィールのみ画像変更可能
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: userImageURL != '' ? NetworkImage(userImageURL) : null,
                    child: userImageURL == '' ? Icon(Icons.camera_alt, size: 40) : null,
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
                            child: Text('${name}  ${age}歳', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          ),
                          Container(
                            decoration: BoxDecoration(color: AppColor.mainButtonColor, shape: BoxShape.circle),
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
                              icon: Icon(Icons.edit, color: AppColor.subTextColor),
                              label: Text('プロフィールを編集する', style: TextStyle(color: AppColor.subTextColor)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.mainButtonColor,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            )
                          : Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: AppColor.mainButtonColor, shape: BoxShape.circle),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.mail, color: AppColor.subTextColor),
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text('フォロー', style: TextStyle(color: AppColor.subTextColor)),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColor.mainButtonColor),
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
              children: hobbies.map((hobby) => Chip(label: Text(hobby))).toList(),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecruitmentList() {
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
                Text('${post.organizerGroup}>${post.targetGroups} ${post.targetAgeMin}歳~${post.targetAgeMax}歳 ${post.targetHasPhoto}'),
                Text(post.destinations.map((destination) => destination).join('、')),
                Text('${post.organizerName}、${post.organizerAge}歳'),
                Text('${post.startDate}~${post.endDate} ${post.days.map((destination) => destination).join('')}'),
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
}
