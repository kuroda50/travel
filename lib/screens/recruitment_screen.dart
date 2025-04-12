import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/functions/function.dart';
import '../component/login_prompt.dart';

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
      organizerId = "",
      organizerName = "",
      organizerAge = "",
      organizerGroup = "",
      description = "",
      organizerImageURL = "";

  List<String> memberTextList = [], memberImageURLList = [], memberIdList = [];
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
    'individual': '各自自腹',
    'hostPaysMore': '主催者が多めに出す',
    'hostPaysLess': '主催者が少なめに出す'
  };

  @override
  void initState() {
    super.initState();
    getPostData();
    _checkFavoriteStatus(widget.postId);
  }

  Future<void> getPostData() async {
    final docRef =
        FirebaseFirestore.instance.collection("posts").doc(widget.postId);
    final doc = await docRef.get();
    if (!doc.exists) return;
    var recruitment = doc.data() as Map<String, dynamic>;
    organizerId = recruitment['organizer']['organizerId'];
    DocumentSnapshot organizerSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(organizerId)
        .get();

    Map<String, dynamic>? organizerData =
        organizerSnapshot.data() as Map<String, dynamic>?;
    setState(() {
      title = doc['title'] ?? '未設定';
      tags = _convertListToString(doc['tags'] ?? []);
      area = doc['where']['area'] ?? '未定';
      destination = _convertListToString(doc['where']['destination'] ?? []);
      startDate = _formatDate(doc['when']['startDate']);
      endDate = _formatDate(doc['when']['endDate']);
      daysOfWeek = _convertListToString(doc['when']['dayOfWeek']
          .map((day) => reverseDayMap[day] ?? day)
          .toList());
      targetGroups = _convertListToString(doc['target']['targetGroups'] ?? []);
      age = _formatAge(doc['target']['ageMin'], doc['target']['ageMax']);
      hasPhoto = doc['target']['hasPhoto'] ? '写真あり' : 'どちらでも';
      budget =
          _formatBudget(doc['budget']['budgetMin'], doc['budget']['budgetMax']);
      budgetType =
          reversePaymentMethodMap[doc['budget']['budgetType']] ?? '未設定';
      region = doc['meetingPlace']['region'] ?? '未定';
      departure = doc['meetingPlace']['departure'] ?? '未定';
      description = doc['description'] ?? '未設定';
      organizerId = organizerId;
      organizerGroup =
          reverseGenderMap[doc['organizer']['organizerGroup']] ?? '未設定';

      organizerName = organizerData?['name'] ?? "不明";
      organizerAge = organizerData?['birthday'] != null
          ? calculateAge(organizerData!['birthday'].toDate()).toString()
          : "不明";
      organizerImageURL = organizerData?['iconURL'];

      memberIdList = doc['participants'].cast<String>();
      memberIdList.remove(doc['organizer']['organizerId']);
      for (String memberId in memberIdList) {
        _getMemberData(memberId);
      }
    });
  }

  Future<void> _getMemberData(String memberId) async {
    final memberRef =
        FirebaseFirestore.instance.collection("users").doc(memberId);
    final doc = await memberRef.get();
    if (doc.exists) {
      setState(() {
        memberTextList.add(
            '${doc['name']}、${calculateAge(doc['birthday'].toDate())}歳、${reverseGenderMap[doc['gender']] ?? doc['gender']}');
        memberImageURLList.add(doc['hasPhoto'] ? doc['iconURL'] : '');
      });
    }
  }

  String _convertListToString(List<dynamic> list) {
    return list
        .cast<String>()
        .map<String>((String value) => value.toString())
        .join('、');
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
    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return age;
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

  Future<String> findOrCreateRoom(String participantId, String postId) async {
    String organizerId = "", postTitle = "";
    final postRef = FirebaseFirestore.instance.collection("posts").doc(postId);
    final postSnapshot = await postRef.get();

    organizerId = postSnapshot["organizer"]["organizerId"];
    postTitle = postSnapshot["title"];

    CollectionReference chatRooms =
        FirebaseFirestore.instance.collection("chatRooms");
    String? existingRoomId = await findExistingRoom(participantId, organizerId);
    if (existingRoomId != null) {
      // 既存のルームが見つかった場合の処理
      final existingRoomRef = chatRooms.doc(existingRoomId);
      await existingRoomRef.update({
        "recruit": true, // recruitフィールドをtrueに設定
      });
      return existingRoomId; // 既存のルームIDを返す
    }

    // ルームがなければ新規作成
    String roomKey = generateRoomKey(participantId, organizerId);
    DocumentReference newRoomRef = chatRooms.doc(); // 自動生成ID

    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.set(newRoomRef, {
      "createdAt": FieldValue.serverTimestamp(),
      "group": false,
      "recruit": true,
      "postId": postId,
      "postTitle": postTitle,
      "participants": [participantId, organizerId],
      "roomKey": roomKey,
      "latestMessage": {
        "readBy": [],
        "sender": participantId,
        "text": "この旅に興味があります！",
        "timeStamp": FieldValue.serverTimestamp()
      }
    });
    DocumentReference firstMessageRef = newRoomRef.collection("messages").doc();
    batch.set(firstMessageRef, {
      "text": "この旅に興味があります!",
      "sender": participantId,
      "timeStamp": FieldValue.serverTimestamp(),
      "readBy": []
    });
    await batch.commit();

    await updateUserChatRooms(participantId, newRoomRef.id);
    await updateUserChatRooms(organizerId, newRoomRef.id);

    return newRoomRef.id;
  }

  Future<void> updateUserChatRooms(String userId, String roomId) async {
    final userRef = FirebaseFirestore.instance.collection("users").doc(userId);

    await userRef.update({
      "chatRooms": FieldValue.arrayUnion([roomId])
    });
  }

  Future<void> goMessageScreen() async {
    if (FirebaseAuth.instance.currentUser == null) {
      showLoginPrompt(context);
      return;
    }
    String participantId = FirebaseAuth.instance.currentUser!.uid;
    String roomId = await findOrCreateRoom(participantId, widget.postId);

    context.push('/message-room',
        extra: {"roomId": roomId, "currentUserId": participantId});
  }

  Future<void> _checkFavoriteStatus(String postId) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    favoritePosts = doc['favoritePosts'].cast<String>();

    setState(() {
      isFavorited = favoritePosts.contains(widget.postId);
    });
  }

  Future<void> _toggleFavorite() async {
    if (FirebaseAuth.instance.currentUser == null) {
      showLoginPrompt(context);
      return;
    }
    String userId = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      isFavorited = !isFavorited;
    });

    DocumentReference userRef =
        FirebaseFirestore.instance.collection("users").doc(userId);

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
                    padding: const EdgeInsets.only(right: 20),
                    child: TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Text("ログイン",
                          style: TextStyle(color: AppColor.mainTextColor)),
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
                    Text('タイトル: $title', style: const TextStyle(fontSize: 18)),
                    Text('タグ: $tags', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    const Text('どこへ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    ListTile(title: const Text('方面'), trailing: Text(area)),
                    ListTile(
                        title: const Text('行き先'), trailing: Text(destination)),
                    const SizedBox(height: 20),
                    const Text('いつ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    ListTile(
                        title: const Text('いつから'), trailing: Text(startDate)),
                    ListTile(
                        title: const Text('いつまで'), trailing: Text(endDate)),
                    ListTile(
                        title: const Text('曜日'), trailing: Text(daysOfWeek)),
                    const SizedBox(height: 20),
                    const Text('募集する人',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    ListTile(
                        title: const Text('性別、属性'),
                        trailing: Text(targetGroups)),
                    ListTile(title: const Text('年齢'), trailing: Text(age)),
                    ListTile(
                        title: const Text('写真付き'), trailing: Text(hasPhoto)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("参加メンバー",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16, right: 16, left: 16),
                child: Text("主催者"),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: organizerImageURL.isNotEmpty
                      ? NetworkImage(organizerImageURL)
                      : null,
                ),
                title: Text(
                    "$organizerName、$organizerAge歳、${reverseGenderMap[organizerGroup] ?? organizerGroup}"),
                onTap: () {
                  if (FirebaseAuth.instance.currentUser == null) {
                    showLoginPrompt(context);
                    return;
                  }
                  context.push('/profile/${organizerId}');
                },
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16, right: 16, left: 16),
                child: Text("参加者"),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: memberTextList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      backgroundImage: memberImageURLList[index].isNotEmpty
                          ? NetworkImage(memberImageURLList[index])
                          : null,
                    ),
                    title: Text(memberTextList[index]),
                    onTap: () {
                      if (FirebaseAuth.instance.currentUser == null) {
                        showLoginPrompt(context);
                        return;
                      }
                      context.push('/profile/${memberIdList[index]}');
                    },
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("お金について",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              ListTile(title: const Text('予算'), trailing: Text(budget)),
              ListTile(
                  title: const Text('お金の分け方'),
                  trailing:
                      Text(reversePaymentMethodMap[budgetType] ?? budgetType)),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("集合場所",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              ListTile(title: const Text('方面'), trailing: Text(region)),
              ListTile(title: const Text('出発地'), trailing: Text(departure)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFAF6),
                    border: Border.all(color: Colors.grey),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Text(description),
                ),
              ),
              // 現在のログインユーザーのIDと投稿の作成者ID(organizerId)が異なる場合のみ表示する処理
              if (FirebaseAuth.instance.currentUser != null)
                if (FirebaseAuth.instance.currentUser!.uid !=
                    organizerId) // ログインユーザーが投稿作成者と違うかをチェック
                  Padding(
                    padding: const EdgeInsets.all(16.0), // ボタン周りの余白設定
                    child: SizedBox(
                      width: double.infinity, // ボタンの横幅を画面いっぱいに広げる
                      child: ElevatedButton(
                        onPressed: () {
                          // ボタンタップ時の処理
                          goMessageScreen(); // チャット画面に遷移する関数を呼ぶ
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("話を聞きたい"),
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
          shape: const CircleBorder(),
          backgroundColor: AppColor.backgroundColor,
          foregroundColor: isFavorited ? Colors.pink : Colors.grey,
          child: Icon(isFavorited ? Icons.favorite : Icons.favorite_border),
        ),
      ),
    );
  }
}
