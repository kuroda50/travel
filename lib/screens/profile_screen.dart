import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/component/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isMyProfile = false;
  String name = '', age = '', bio = '', title = '', userImageURL = '';
  List<String> hobbies = [],
      targetGroups = [],
      destinations = [],
      days = [],
      recruitmentPostIdList = [];
  List<RecruitmentPost> recruitmentPosts = [];
  @override
  void initState() {
    super.initState();
    checkUserId(widget.userId);
    getUserProfile(widget.userId);
    getRecruitmentList();
  }

  void checkUserId(String userId) {
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
    return;
  }

  void getUserProfile(String userId) {
    // ユーザー情報を取得する処理
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    userRef.get().then((user) {
      if (user.exists) {
        print("ユーザ情報を取得します");
        name = user['name'];
        age = calculateAge(user['birthday'].toDate()).toString();
        hobbies = user['hobbies'].map((hobby) => hobby.toString()).toList();
        bio = user['bio'];
        userImageURL = user['hasPhoto'] ? user['photoURLs'][0] : '';
        recruitmentPostIdList =
            user['participatedPosts'].map((post) => post.toString()).toList();
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
    });
  }

  void getRecruitmentList() {
    for (int i = 0; i < recruitmentPostIdList.length; i++) {
      DocumentReference recruitmentRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(recruitmentPostIdList[i]);
      recruitmentRef.get().then((recruitment) {
        if (recruitment.exists) {
          recruitmentPosts[i].title = recruitment['title'];
          recruitmentPosts[i].targetGroups = recruitment['target']
                  ['targetGroups']
              .map((group) => group.toString())
              .toList();
          recruitmentPosts[i].targetAgeMin = recruitment['target']['AgeMin'];
          recruitmentPosts[i].targetAgeMax = recruitment['target']['AgeMax'];
          recruitmentPosts[i].targetHasPhoto =
              recruitment['target']['hasPhoto'] ? '写真あり' : '写真なし';
          recruitmentPosts[i].destinations = recruitment['destination']
              .map((destination) => destination.toString())
              .toList();
          recruitmentPosts[i].organizerGroup =
              recruitment['organizer']['organizerGroup'];
          recruitmentPosts[i].organizerName =
              recruitment['organizer']['organizerName'];
          recruitmentPosts[i].organizerAge = calculateAge(
                  recruitment['organizer']['organizerBirthday'].toDate())
              .toString();
          recruitmentPosts[i].startDate =
              recruitment['when']['startDate'].toDate().toString();
          recruitmentPosts[i].endDate =
              recruitment['when']['endDate'].toDate().toString();
          recruitmentPosts[i].days = recruitment['when']['dayOfWeek']
              .map((day) => day.toString())
              .toList();
          RecruitmentPost post = RecruitmentPost(
            postId: recruitmentPostIdList[i],
            title: recruitmentPosts[i].title,
            organizerPhotoURL: recruitment['organizer']['photoURL'],
            organizerGroup: recruitmentPosts[i].organizerGroup,
            targetGroups: recruitmentPosts[i].targetGroups,
            targetAgeMin: recruitmentPosts[i].targetAgeMin,
            targetAgeMax: recruitmentPosts[i].targetAgeMax,
            targetHasPhoto: recruitmentPosts[i].targetHasPhoto,
            destinations: recruitmentPosts[i].destinations,
            organizerName: recruitmentPosts[i].organizerName,
            organizerAge: recruitmentPosts[i].organizerAge,
            startDate: recruitmentPosts[i].startDate,
            endDate: recruitmentPosts[i].endDate,
            days: recruitmentPosts[i].days,
          );
          recruitmentPosts.add(post);
          setState(() {
            recruitmentPosts = recruitmentPosts;
          });
        } else {
          print("募集情報が見つかりません");
        }
      });
    }
  }

  int calculateAge(DateTime birth) {
    DateTime today = DateTime.now();
    int age = today.year - birth.year;

    // 誕生日がまだ来ていなければ1歳引く
    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
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
                  backgroundImage: NetworkImage(userImageURL),
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
                                    onPressed: () {},
                                    icon: Icon(Icons.mail,
                                        color: AppColor.subTextColor),
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text(
                                    'フォロー',
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
    return Column(
      children: recruitmentPosts.map((post) {
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
                Row(
                  children: <Widget>[
                    Icon(Icons.person),
                    Text(
                        '${post.organizerGroup}>${post.targetGroups} ${post.targetAgeMin}~${post.targetAgeMax} ${post.targetHasPhoto}'),
                  ],
                ),
                Text(post.destinations
                    .map((destination) => destination)
                    .join('、')),
                Text(
                    '${post.organizerName}、${post.organizerAge}歳 ${post.startDate}~${post.endDate} ${post.days.map((destination) => destination).join('')}'),
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

class RecruitmentPost {
  String postId;
  String title;
  String organizerPhotoURL;
  String organizerGroup;
  List<String> targetGroups;
  String targetAgeMin;
  String targetAgeMax;
  String targetHasPhoto;
  List<String> destinations;
  String organizerName;
  String organizerAge;
  String startDate;
  String endDate;
  List<String> days;

  RecruitmentPost({
    required this.postId,
    required this.title,
    required this.organizerPhotoURL,
    required this.organizerGroup,
    required this.targetGroups,
    required this.targetAgeMin,
    required this.targetAgeMax,
    required this.targetHasPhoto,
    required this.destinations,
    required this.organizerName,
    required this.organizerAge,
    required this.startDate,
    required this.endDate,
    required this.days,
  });
}
