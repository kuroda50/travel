import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../functions/function.dart';
import '../component/login_prompt.dart';

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
  List<String> favoritePosts = [];

  // キャッシュ用のMap
  final Map<String, Map<String, dynamic>> _postCache = {};
  final Map<String, Map<String, dynamic>> _organizerCache = {};

  List<Map<String, dynamic>> cachesPosts = [];

  @override
  void initState() {
    super.initState();
    _getRecruitments();
  }

  void _getRecruitments() async {
    await getFavoirtePosts();
    recruitmentPosts = await fetchRecruitmentLists(widget.postIds);
    setState(() {
      recruitmentPosts = recruitmentPosts;
      isLoading = false;
    });
  }

  Future<void> getFavoirtePosts() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      favoritePosts = doc['favoritePosts'].cast<String>();
    });
  }

  // キャッシュを使う処理
  Future<List<RecruitmentPost>> fetchRecruitmentLists(
      List<String> recruitmentPostIdList) async {
    List<RecruitmentPost> recruitmentPosts = [];

    // まだキャッシュされてない投稿IDだけ抽出
    List<String> uncachedPostIds = recruitmentPostIdList
        .where((id) => !_postCache.containsKey(id))
        .toList();

    // 10件ずつ取得
    for (int i = 0; i < uncachedPostIds.length; i += 10) {
      List<String> batchIds = uncachedPostIds.sublist(
        i,
        i + 10 > uncachedPostIds.length ? uncachedPostIds.length : i + 10,
      );

      QuerySnapshot batchSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();

      for (var doc in batchSnapshot.docs) {
        _postCache[doc.id] = doc.data() as Map<String, dynamic>;
      }
    }

    // organizerIdリストアップ（キャッシュ未取得分のみ）
    Set<String> organizerIds = {};
    for (var id in recruitmentPostIdList) {
      var post = _postCache[id];
      if (post != null) {
        String organizerId = post['organizer']['organizerId'];
        if (!_organizerCache.containsKey(organizerId)) {
          organizerIds.add(organizerId);
        }
      }
    }

    // organizerを10件ずつ取得
    List<String> organizerIdList = organizerIds.toList();
    for (int i = 0; i < organizerIdList.length; i += 10) {
      List<String> batchOrganizerIds = organizerIdList.sublist(
        i,
        i + 10 > organizerIdList.length ? organizerIdList.length : i + 10,
      );

      QuerySnapshot organizerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: batchOrganizerIds)
          .get();

      for (var doc in organizerSnapshot.docs) {
        _organizerCache[doc.id] = doc.data() as Map<String, dynamic>;
      }
    }

    // キャッシュデータをRecruitmentPostに変換
    for (var postId in recruitmentPostIdList) {
      Map<String, dynamic>? recruitment = _postCache[postId];
      if (recruitment == null) continue;

      String organizerId = recruitment['organizer']['organizerId'];
      Map<String, dynamic>? organizerData = _organizerCache[organizerId];

      RecruitmentPost post = RecruitmentPost(
        postId: postId,
        title: recruitment['title'],
        targetGroups: (recruitment['target']['targetGroups'] as List).isEmpty
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
        organizerThumbnailURL: organizerData?['thumbnailURL'] ?? "",
        organizerGroup:
            reverseGenderMap[recruitment['organizer']['organizerGroup']] ??
                "不明",
        organizerName: organizerData?['name'] ?? "不明",
        organizerAge: organizerData?['birthday'] != null
            ? calculateAge(organizerData!['birthday'].toDate()).toString()
            : "不明",
        startDate: DateFormat('yyyy/MM/dd')
            .format(recruitment['when']['startDate'].toDate())
            .toString(),
        endDate: DateFormat('yyyy/MM/dd')
            .format(recruitment['when']['endDate'].toDate())
            .toString(),
        days: List<String>.from(recruitment['when']['dayOfWeek']
            .map((day) => reverseDayMap[day.toString()])
            .toList()),
        isBookmarked: favoritePosts.contains(postId),
      );
      recruitmentPosts.add(post);
    }

    return recruitmentPosts;
  }

  Future<void> _toggleFavorite(RecruitmentPost post) async {
    if (FirebaseAuth.instance.currentUser == null) {
      showLoginPrompt(context);
      return;
    }
    String userId = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      post.isBookmarked = !post.isBookmarked;
    });

    DocumentReference userRef =
        FirebaseFirestore.instance.collection("users").doc(userId);

    if (post.isBookmarked) {
      favoritePosts.add(post.postId);
    } else {
      favoritePosts.remove(post.postId);
    }

    await userRef.update({'favoritePosts': favoritePosts});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (recruitmentPosts.isEmpty) {
      return const Center(
        child: Text(
          "募集がありません",
        ),
      );
    }
    return ListView(
      shrinkWrap: true, // 親のスクロールビューに合わせる
      physics: const NeverScrollableScrollPhysics(), // 子のスクロールを無効化
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
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: post.organizerThumbnailURL.isNotEmpty
                  ? CachedNetworkImageProvider(post.organizerThumbnailURL)
                  : null, // URLが空の場合はnullを設定
              child: post.organizerThumbnailURL.isNotEmpty
                  ? null
                  : const Icon(Icons.person,
                      size: 40, color: Colors.grey), // 代替アイコン
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(post.title),
                Text(
                    '${post.organizerGroup}>${post.targetGroups.join("、")} ${ageRange} ${post.targetHasPhoto}'),
                Text(post.destinations
                    .map((destination) => destination)
                    .join('、')),
                Text('${post.organizerName}、${post.organizerAge}歳'),
                Text('${post.startDate}~${post.endDate} ${post.days.join('')}'),
              ],
            ),
            trailing: SizedBox(
              width: 60,
              height: 60,
              child: IconButton(
                icon: Icon(
                  post.isBookmarked ? Icons.favorite : Icons.favorite_border,
                  color: post.isBookmarked ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  _toggleFavorite(post);
                },
              ),
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
  List<String> targetGroups;
  String targetAgeMin;
  String targetAgeMax;
  String targetHasPhoto;
  List<String> destinations;
  String organizerThumbnailURL;
  String organizerGroup;
  String organizerName;
  String organizerAge;
  String startDate;
  String endDate;
  bool isBookmarked = false;
  List<String> days;

  RecruitmentPost({
    required this.postId,
    required this.title,
    required this.targetGroups,
    required this.targetAgeMin,
    required this.targetAgeMax,
    required this.targetHasPhoto,
    required this.destinations,
    required this.organizerThumbnailURL,
    required this.organizerGroup,
    required this.organizerName,
    required this.organizerAge,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.isBookmarked,
  });
}
