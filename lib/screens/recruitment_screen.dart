import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

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
      member2 = "",
      member3 = "",
      description = "";

  void initState() {
    super.initState();
    getPostData();
  }

  void getPostData() async {
    final docRef =
        FirebaseFirestore.instance.collection("posts").doc(widget.postId);
    await docRef.get().then((doc) {
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
      organizerAge = calculateAge(doc['organizer']['organizerAge']).toString();

      print("呼ばれたよ4");
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

      // member2 = member2;
      // member3 = member3;
      // description = description;
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('仲間と集まる'),
          backgroundColor: Color(0xFF559900), // ヘッダーの色を559900に変更
        ),
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
                    image: NetworkImage(
                        'https://static.wikia.nocookie.net/pokemon/images/2/29/Spr_6x_677.png/revision/latest/scale-to-width-down/250?cb=20161026045550'), // 画像URLをここに入力
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'どこへ',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.favorite_border),
                      ],
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
                ),
                title: Text("${organizerName}、${organizerAge}、${organizerGroup}"), // 変数を埋め込む
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                ),
                title: Text(member2), // 変数を埋め込む
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                ),
                title: Text(member3), // 変数を埋め込む
              ),
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
                      context.pop('/message');
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
      ),
    );
  }
}
