import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../functions/function.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PostCard extends StatefulWidget {
  final List<String> postIds;
  const PostCard({super.key, required this.postIds});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  Map<String, String> reverseGenderMap = {
    'male': '男性',
    'female': '女性',
    'family': '家族',
    'group': 'グループ'
  };

  Map<String, String> reverseDayMap = {
    'Mon': '月',
    'Tue': '火',
    'Wed': '水',
    'Thu': '木',
    'Fri': '金',
    'Sat': '土',
    'Sun': '日'
  };
  List<RecruitmentPost> recruitmentPosts = [];
  bool isLoading = true;
  String age = "";

  @override
  void initState() {
    super.initState();
    _getRecruitments();
  }

  void _getRecruitments() async {
    recruitmentPosts = await fetchRecruitmentLists(widget.postIds);
    setState(() {
      recruitmentPosts = recruitmentPosts;
      isLoading = false;
    });
  }

  Future<List<RecruitmentPost>> fetchRecruitmentLists(
      List<String> recruitmentPostIdList) async {
    List<RecruitmentPost> recruitmentPosts = [];
    for (int i = 0; i < recruitmentPostIdList.length; i++) {
      DocumentReference recruitmentRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(recruitmentPostIdList[i]);
      await recruitmentRef.get().then((recruitment) {
        if (recruitment.exists) {
          // 'post' をここで初期化
          RecruitmentPost post = RecruitmentPost(
            postId: recruitmentPostIdList[i],
            title: recruitment['title'],
            organizerPhotoURL: recruitment['organizer']['photoURL'] ?? "",
            organizerGroup:
                reverseGenderMap[recruitment['organizer']['organizerGroup']] ??
                    "不明",
            targetGroups:
                (recruitment['target']['targetGroups'] as List).isEmpty
                    ? ['誰でも']
                    : List<String>.from(recruitment['target']['targetGroups']
                        .map((group) => reverseGenderMap[group].toString())
                        .toList()),
            targetAgeMin: recruitment['target']['ageMin'].toString(),
            targetAgeMax: recruitment['target']['ageMax'].toString(),
            targetHasPhoto: recruitment['target']['hasPhoto'] ? '写真あり' : '写真なし',
            destinations: List<String>.from(recruitment['where']['destination']
                .map((destination) => destination.toString())
                .toList()),
            organizerName: recruitment['organizer']['organizerName'],
            organizerAge: calculateAge(
                    recruitment['organizer']['organizerBirthday'].toDate())
                .toString(),
            startDate: DateFormat('yyyy/MM/dd')
                .format(recruitment['when']['startDate'].toDate())
                .toString(),
            endDate: DateFormat('yyyy/MM/dd')
                .format(recruitment['when']['endDate'].toDate())
                .toString(),
            days: List<String>.from(recruitment['when']['dayOfWeek']
                .map((day) => reverseDayMap[day.toString()])
                .toList()),
          );
          // 'post' をリストに追加
          recruitmentPosts.add(post);
        } else {
          print("募集情報が見つかりません");
        }
      });
    }
    return recruitmentPosts;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (recruitmentPosts.isEmpty) {
      return Center(
          child: Text("募集がありません",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
    }

    return ListView(
      shrinkWrap: true,
      children: recruitmentPosts.map((post) {
        String ageRange;
        if (post.targetAgeMin == "null" && post.targetAgeMax == "null") {
          ageRange = '年齢制限なし';
        } else if (post.targetAgeMin == "null") {
          ageRange = '${post.targetAgeMax}歳以下';
        } else if (post.targetAgeMax == "null") {
          ageRange = '${post.targetAgeMin}歳以上';
        } else {
          ageRange = '${post.targetAgeMin}歳~${post.targetAgeMax}歳';
        }
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
                    '${post.organizerGroup}>${post.targetGroups.join("、")} ${ageRange} ${post.targetHasPhoto}'),
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
