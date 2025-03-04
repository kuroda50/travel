import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:travel/colors/color.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostWidget extends StatefulWidget {
  final String postId;
  const PostWidget({super.key, required this.postId});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  String title = "",
      hasPhoto = "",
      organizerName = "",
      organizerId = "",
      destination = "",
      day = "",
      startDate = "",
      endDate = "";
  int ageMax = 0, ageMin = 0, organizerAge = 0;
  bool isFavorite = false;
  List<String> destinations = [], daysOfWeek = [];

  @override
  void initState() {
    super.initState();
    getPost(widget.postId);
    checkFavorite(widget.postId);
  }

  void getPost(postId) {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    postRef.get().then((doc) {
      if (!doc.exists) return;
      title = doc['title'];
      destinations = List<String>.from(doc['where']['destination']);
      destination =
          destinations.map<String>((String day) => day.toString()).join('、');

      daysOfWeek = List<String>.from(doc['when']['dayOfWeek']);
      day = daysOfWeek.map<String>((String day) => day.toString()).join('、');

      startDate =
          DateFormat('yyyy/MM/dd').format(doc['when']['startDate'].toDate());
      endDate =
          DateFormat('yyyy/MM/dd').format(doc['when']['endDate'].toDate());

      ageMax = doc['target']['ageMax'];
      ageMin = doc['target']['ageMin'];
      if (doc['target']['hasPhoto'])
        hasPhoto = "写真あり";
      else
        hasPhoto = "写真なし";
      organizerId = doc['organizer']['organizerId'];
      final organizerRef =
          FirebaseFirestore.instance.collection('users').doc(organizerId);
      organizerRef.get().then((doc) {
        if (doc.exists) {
          organizerName = doc['name'];
          DateTime birthday = doc['birthday'].toDate();
          DateTime now = DateTime.now();
          organizerAge = now.year - birthday.year;
          // 誕生日がまだ来ていなければ1歳引く
          if (now.month < birthday.month ||
              (now.month == birthday.month && now.day < birthday.day)) {
            organizerAge--;
          }
        } else {
          print('No such user document!');
        }
        setState(() {
          title = title;
          destination = destination;
          daysOfWeek = daysOfWeek;
          day = day;
          startDate = startDate;
          endDate = endDate;
          ageMax = ageMax;
          ageMin = ageMin;
          hasPhoto = hasPhoto;
          organizerName = organizerName;
          organizerAge = organizerAge;
        });
      });
    });
  }

  void checkFavorite(postId) async{
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if(doc.exists){
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // プロフィール画像
          Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                // backgroundImage: AssetImage('assets/profile_placeholder.png'),
              ),
            ],
          ),
          SizedBox(width: 12),
          // テキスト情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.male, color: Colors.blue, size: 16),
                    Icon(Icons.female, color: Colors.red, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${ageMin}才〜${ageMax}才  ${hasPhoto}',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  '${destination}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${startDate} 〜 ${endDate} ${day}',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Text(
                  '${organizerName}, ${organizerAge}才',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.favorite,
            ),
            onPressed: () {
              print("押されたよ");
              if (FirebaseAuth.instance.currentUser == null) return;
              final userRef = FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid);
              // final userRef = FirebaseFirestore.instance
              //     .collection('users')
              //     .doc("gNdjPPD880hQ69IXSuAgIYFBX1c2");
              userRef.get().then((doc) {
                if (doc.exists) {
                  List<dynamic> favoritePosts =
                      doc['favoritePosts'] ?? []; //nullなら[]を代入
                  if (favoritePosts.contains(widget.postId)) {
                    //既にお気に入りなら削除する
                    userRef.update({
                      'favoritePosts': FieldValue.arrayRemove([widget.postId])
                    });
                  } else {
                    // お気に入りでなければ追加
                    userRef.update({
                      'favoritePosts': FieldValue.arrayUnion([widget.postId])
                    });
                  }
                }
              });
              setState(() {});
            },
          )
        ],
      ),
    );
  }
}
