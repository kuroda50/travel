import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel/component/header.dart';

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

  void initState() {
    super.initState();
    getPostData();
    _checkFavoriteStatus(widget.postId);
  }

  void getPostData() async {
    final docRef =
        FirebaseFirestore.instance.collection("posts").doc(widget.postId);
    await docRef.get().then((doc) async {
      if (!doc.exists) return;

      title = doc['title'];
      tags = doc['tags']
          .cast<String>()
          .map<String>((String value) => value.toString())
          .join('、');
      area = doc['where']['area'];
      destination = doc['where']['destination']
          .cast<String>()
          .map<String>((String value) => value.toString())
          .join('、');
      startDate =
          DateFormat('yyyy/MM/dd').format(doc['when']['startDate'].toDate());
      endDate =
          DateFormat('yyyy/MM/dd').format(doc['when']['endDate'].toDate());
      daysOfWeek = doc['when']['dayOfWeek']
          .cast<String>()
          .map<String>((String value) => value.toString())
          .join('、');
      targetGroups = doc['target']['targetGroups']
          .cast<String>()
          .map<String>((String value) => value.toString())
          .join('、');
      int? ageMin = doc['target']['ageMin'];
      int? ageMax = doc['target']['ageMax'];
      if (ageMin == null && ageMax == null) {
        age = '未設定';
      } else if (ageMin != null && ageMax == null) {
        age = '$ageMin歳以上';
      } else if (ageMin == null && ageMax != null) {
        age = '$ageMax歳以下';
      } else {
        age = '$ageMin歳～$ageMax歳';
      }
      hasPhoto = doc['target']['hasPhoto'] ? '写真あり' : 'どちらでも';
      int? budgetMin = doc['budget']['budgetMin'];
      int? budgetMax = doc['budget']['budgetMax'];
      if (budgetMin == null && budgetMax == null) {
        budget = '未設定';
      } else if (budgetMin != null && budgetMax == null) {
        budget = '$budgetMin万円以上';
      } else if (budgetMin == null && budgetMax != null) {
        budget = '$budgetMax万円以下';
      } else {
        budget = '$budgetMin万円～$budgetMax万円';
      }
      budgetType = doc['budget']['budgetType'];
      if (doc['meetingPlace']['region'] != null)
        region = doc['meetingPlace']['region'];
      if (doc['meetingPlace']['departure'] != null)
        departure = doc['meetingPlace']['departure'];
      description = doc['description'];

      organizerName = doc['organizer']['organizerName'];
      organizerGroup = doc['organizer']['organizerGroup'];
      organizerAge =
          calculateAge(doc['organizer']['organizerBirthday'].toDate())
              .toString();
      organizerImageURL = doc['organizer']['photoURL'];

      List<String> memberList = doc['participants'].cast<String>();
      for (int i = 0; i < memberList.length; i++) {
        DocumentReference memberRef =
            FirebaseFirestore.instance.collection("users").doc(memberList[i]);
        memberRef.get().then((doc) {
          if (doc.exists)
            memberTextList[i] =
                '${doc['name']}、${calculateAge(doc['birthday'])}歳、${doc['gender']}';
          memberImageURLList[i] = doc[memberList[i]]['hasPhto']
              ? doc[memberList[i]]['photoURLs'][0]
              : '';
        });
      }
    });

    setState(() {
      title = title;
      tags = tags;
      area = area;
      destination = destination;
      startDate = startDate;
      endDate = endDate;
      daysOfWeek = daysOfWeek;
      targetGroups = targetGroups;
      age = age;
      hasPhoto = hasPhoto;
      budget = budget;
      budgetType = budgetType;
      region = region;
      departure = departure;
      organizerName = organizerName;
      organizerGroup = organizerGroup;
      organizerAge = organizerAge;
      description = description;
      memberTextList = memberTextList;
      organizerImageURL = organizerImageURL;
    });
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

  Future<bool> _checkFavoriteStatus(String postId) async {
    if (FirebaseAuth.instance.currentUser == null)
      return false; //ログインしてなければfalseを返す
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    List<String> favoritePosts = doc['favoritePosts'].cast<String>();

    bool favorited = favoritePosts.contains(widget.postId);
    setState(() {
      isFavorited = favorited;
    });
    if (favorited) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _toggleFavorite() async {
    // お気に入り登録/解除処理
    print("呼ばれたよ");
    if (FirebaseAuth.instance.currentUser == null) return; //ログインしてなければ終わる

    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection("users").doc(userId);
    print("ここまで実行");
    userRef.get().then((doc) async {
      List<String> favoritePosts = doc['favoritePosts'].cast<String>();
      if (await _checkFavoriteStatus(widget.postId)) {
        favoritePosts.remove(widget.postId);
      } else {
        favoritePosts.add(widget.postId);
      }
      userRef.update({'favoritePosts': favoritePosts});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: Header(),
        backgroundColor: Colors.white, // 背景色を白に変更
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 画像部分
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(organizerImageURL), // 画像URLをここに入力
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'タイトル: $title', // 変数を埋め込む
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'タグ: $tags', // 変数を埋め込む
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'どこへ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      title: Text('方面'),
                      trailing: Text(area), // 変数を埋め込む
                    ),
                    ListTile(
                      title: Text('行き先'),
                      trailing: Text(destination), // 変数を埋め込む
                    ),
                    SizedBox(height: 20),
                    Text(
                      'いつ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      title: Text('いつから'),
                      trailing: Text(startDate), // 変数を埋め込む
                    ),
                    ListTile(
                      title: Text('いつまで'),
                      trailing: Text(endDate), // 変数を埋め込む
                    ),
                    ListTile(
                      title: Text('曜日'),
                      trailing: Text(daysOfWeek), // 変数を埋め込む
                    ),
                    SizedBox(height: 20),
                    Text(
                      '募集する人',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      title: Text('性別、属性'),
                      trailing: Text(targetGroups), // 変数を埋め込む
                    ),
                    ListTile(
                      title: Text('年齢'),
                      trailing: Text(age), // 変数を埋め込む
                    ),
                    ListTile(
                      title: Text('写真付き'),
                      trailing: Text(hasPhoto), // 変数を埋め込む
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "参加メンバー", // 変数を埋め込む
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
                child: Text(
                  "主催者", // 変数を埋め込む
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage: NetworkImage(organizerImageURL)),
                title: Text(
                    "${organizerName}、${organizerAge}歳、${organizerGroup}"), // 変数を埋め込む
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: memberTextList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                      ),
                      title: Text(memberTextList[index]), // 変数を埋め込む
                    );
                  }),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "お金について", // 変数を埋め込む
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: Text('予算'),
                trailing: Text(budget), // 変数を埋め込む
              ),
              ListTile(
                title: Text('お金の分け方'),
                trailing: Text(budgetType), // 変数を埋め込む
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "集合場所", // 変数を埋め込む
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: Text('方面'),
                trailing: Text(region), // 変数を埋め込む
              ),
              ListTile(
                title: Text('出発地'),
                trailing: Text(departure), // 変数を埋め込む
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFBFAF6),
                    border: Border.all(color: Colors.grey),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    description, // 変数を埋め込む
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // ボタンが押されたときの処理
                      context.push('/message');
                    },
                    child: Text("話を聞きたい"), // 変数を埋め込む
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // ボタンの背景色
                      foregroundColor: Colors.white, // ボタンのテキスト色
                    ),
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
