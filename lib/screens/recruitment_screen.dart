import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel/colors/color.dart';

class RecruitmentScreen extends StatefulWidget {
  final String postId;
  const RecruitmentScreen({super.key, required this.postId});

  @override
  State<RecruitmentScreen> createState() => _RecruitmentScreenState();
}

class _RecruitmentScreenState extends State<RecruitmentScreen> {
  String title = "",
      tags = "",
      area = "未定",
      destination = "未定",
      startDate = "未定",
      endDate = "未定",
      daysOfWeek = "未定",
      targetGroups = "未定",
      age = "未定",
      hasPhoto = "",
      budget = "未定",
      budgetType = "未定",
      region = "未定",
      departure = "未定",
      organizerName = "",
      organizerAge = "",
      organizerGroup = "",
      description = "",
      organizerImageURL = "";

  List<String> memberTextList = [], memberImageURLList = [];
  bool isFavorited = false;
  List<String> favoritePosts = [];

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

  Map<String, String> reversePaymentMethodMap = {
    'null': 'こだわらない',
    'splitEvenly': '割り勘',
    'eachPays': '各自自腹',
    'hostPaysMore': '主催者が多めに出す',
    'hostPaysLess': '主催者が少な目に出す'
  };

  @override
  void initState() {
    super.initState();
    getPostData();
    _checkFavoriteStatus(widget.postId);
  }

  Future<void> getPostData() async {
    final docRef = FirebaseFirestore.instance.collection("posts").doc(widget.postId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    setState(() {
      title = doc['title'];
      tags = _convertListToString(doc['tags']);
      area = doc['where']['area'];
      destination = _convertListToString(doc['where']['destination']);
      startDate = _formatDate(doc['when']['startDate']);
      endDate = _formatDate(doc['when']['endDate']);
      daysOfWeek = _convertListToString(doc['when']['dayOfWeek'].map((day) => reverseDayMap[day] ?? day).toList());
      targetGroups = _convertListToString(doc['target']['targetGroups'].map((group) => reverseGenderMap[group] ?? group).toList());
      age = _formatAge(doc['target']['ageMin'], doc['target']['ageMax']);
      hasPhoto = doc['target']['hasPhoto'] ? '写真あり' : 'どちらでも';
      budget = _formatBudget(doc['budget']['budgetMin'], doc['budget']['budgetMax']);
      budgetType = reversePaymentMethodMap[doc['budget']['budgetType']] ?? doc['budget']['budgetType'];
      region = doc['meetingPlace']['region'] ?? "未定";
      departure = doc['meetingPlace']['departure'] ?? "未定";
      description = doc['description'];
      organizerName = doc['organizer']['organizerName'];
      organizerGroup = reverseGenderMap[doc['organizer']['organizerGroup']] ?? doc['organizer']['organizerGroup'];
      organizerAge = calculateAge(doc['organizer']['organizerBirthday'].toDate()).toString();
      organizerImageURL = doc['organizer']['photoURL'];

      List<String> memberList = doc['participants'].cast<String>();
      memberList.remove(doc['organizer']['organizerId']);
      for (String memberId in memberList) {
        _getMemberData(memberId);
      }
    });
  }

  Future<void> _getMemberData(String memberId) async {
    final memberRef = FirebaseFirestore.instance.collection("users").doc(memberId);
    final doc = await memberRef.get();
    if (doc.exists) {
      setState(() {
        memberTextList.add('${doc['name']}、${calculateAge(doc['birthday'].toDate())}歳、${reverseGenderMap[doc['gender']] ?? doc['gender']}');
        memberImageURLList.add(doc['hasPhoto'] ? doc['photoURLs'][0] : '');
      });
    }
  }

  String _convertListToString(List<dynamic> list) {
    return list.cast<String>().map<String>((String value) => value.toString()).join('、');
  }

  String _formatDate(Timestamp timestamp) {
    return DateFormat('yyyy/MM/dd').format(timestamp.toDate());
  }

  String _formatAge(int? ageMin, int? ageMax) {
    if (ageMin == null && ageMax == null) {
      return '未設定';
    } else if (ageMin != null && ageMax == null) {
      return '$ageMin歳以上';
    } else if (ageMin == null && ageMax != null) {
      return '$ageMax歳以下';
    } else {
      return '$ageMin歳～$ageMax歳';
    }
  }

  String _formatBudget(int? budgetMin, int? budgetMax) {
    if (budgetMin == null && budgetMax == null) {
      return '未設定';
    } else if (budgetMin != null && budgetMax == null) {
      return '$budgetMin万円以上';
    } else if (budgetMin == null && budgetMax != null) {
      return '$budgetMax万円以下';
    } else {
      return '$budgetMin万円～$budgetMax万円';
    }
  }

  int calculateAge(DateTime birth) {
    DateTime today = DateTime.now();
    int age = today.year - birth.year;
    if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return age;
  }

  Future<void> _checkFavoriteStatus(String postId) async {
    if (FirebaseAuth.instance.currentUser == null) return;
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    favoritePosts = doc['favoritePosts'].cast<String>();

    setState(() {
      isFavorited = favoritePosts.contains(widget.postId);
    });
  }

  Future<void> _toggleFavorite() async {
    if (FirebaseAuth.instance.currentUser == null) return;

    setState(() {
      isFavorited = !isFavorited;
    });

    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef = FirebaseFirestore.instance.collection("users").doc(userId);

    if (isFavorited) {
      favoritePosts.add(widget.postId);
    } else {
      favoritePosts.remove(widget.postId);
    }

    await userRef.update({'favoritePosts': favoritePosts});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            '募集',
            style: TextStyle(
              fontSize: 20,
              color: AppColor.subTextColor,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
          backgroundColor: AppColor.mainButtonColor,
          actions: FirebaseAuth.instance.currentUser == null
              ? [
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: Text("ログイン", style: TextStyle(color: AppColor.mainTextColor)),
                    ),
                  )
                ]
              : null,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (organizerImageURL.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(organizerImageURL),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('タイトル: $title', style: TextStyle(fontSize: 18)),
                    Text('タグ: $tags', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    Text('どこへ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ListTile(title: Text('方面'), trailing: Text(area)),
                    ListTile(title: Text('行き先'), trailing: Text(destination)),
                    SizedBox(height: 20),
                    Text('いつ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ListTile(title: Text('いつから'), trailing: Text(startDate)),
                    ListTile(title: Text('いつまで'), trailing: Text(endDate)),
                    ListTile(title: Text('曜日'), trailing: Text(daysOfWeek)),
                    SizedBox(height: 20),
                    Text('募集する人', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ListTile(title: Text('性別、属性'), trailing: Text(targetGroups)),
                    ListTile(title: Text('年齢'), trailing: Text(age)),
                    ListTile(title: Text('写真付き'), trailing: Text(hasPhoto)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("参加メンバー", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
                child: Text("主催者"),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: organizerImageURL.isNotEmpty ? NetworkImage(organizerImageURL) : null,
                ),
                title: Text("$organizerName、$organizerAge歳、${reverseGenderMap[organizerGroup] ?? organizerGroup}"),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
                child: Text("参加者"),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: memberTextList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      backgroundImage: memberImageURLList[index].isNotEmpty ? NetworkImage(memberImageURLList[index]) : null,
                    ),
                    title: Text(memberTextList[index]),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("お金について", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              ListTile(title: Text('予算'), trailing: Text(budget)),
              ListTile(title: Text('お金の分け方'), trailing: Text(reversePaymentMethodMap[budgetType] ?? budgetType)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("集合場所", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              ListTile(title: Text('方面'), trailing: Text(region)),
              ListTile(title: Text('出発地'), trailing: Text(departure)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFBFAF6),
                    border: Border.all(color: Colors.grey),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Text(description),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/message');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("話を聞きたい"),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _toggleFavorite();
          },
          backgroundColor: isFavorited ? Colors.red : Colors.grey,
          child: Icon(isFavorited ? Icons.favorite : Icons.favorite_border),
        ),
      ),
    );
  }
}