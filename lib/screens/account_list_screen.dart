import 'package:flutter/material.dart';
import 'package:travel/models/filter_params.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountListScreen extends StatefulWidget {
  final FilterParams filterParams;
  const AccountListScreen({super.key, required this.filterParams});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  List<String> userIds = [];

  Future<List<String>> fetchFilteredUserId(
      List<String> hobbies, String gender, int ageMin, int ageMax) async {
    DateTime today = DateTime.now();
    DateTime minBirthDate =
        DateTime(today.year - ageMax - 1, today.month, today.day + 1);
    DateTime maxBirthDate =
        DateTime(today.year - ageMin, today.month, today.day);
    print("呼ばれたよ");
    await FirebaseFirestore.instance
        .collection("users")
        .where('gender', isEqualTo: gender)
        .where("birthday", isGreaterThanOrEqualTo: minBirthDate)
        .where("birthday", isLessThanOrEqualTo: maxBirthDate)
        .get()
        .then((querySnapshot) {
      print("スナップショットを取得しました");
      for (var docSnapshot in querySnapshot.docs) {
        List<String> userHobbies =
            List<String>.from(docSnapshot["hobbies"] ?? []);
        if (userHobbies.any((hobby) => hobbies.contains(hobby))) {
          //一つでもhobbyを含んでいたら
          userIds.add(docSnapshot.id);
        }
      }
    });
    setState(() {
      userIds = userIds;
    });
    print("全部しました${userIds[0]},${userIds.length}");
    return userIds;
  }

  @override
  void initState() {
    super.initState();
    fetchFilteredUserId(widget.filterParams.hobbies, widget.filterParams.gender,
        widget.filterParams.ageMin, widget.filterParams.ageMax);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント一覧'),
      ),
      body: Center(
        child: ListView.builder(
            itemCount: userIds.length,
            itemBuilder: (context, index) {
              return SizedBox(
                height: 100,
                child: Center(
                  child: Text("ユーザID：${userIds[index]}"),
                ),
              );
            }),
      ),
    );
  }
}
