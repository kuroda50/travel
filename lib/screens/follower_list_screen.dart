import 'package:flutter/material.dart';

class FollowerListScreen extends StatelessWidget {
  const FollowerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フォロワー'),
      ),
      body: const Center(
        child: Text('フォロワー'),
      ),
    );
  }
}
































































































// バックアップとして残しておく
// class User {
//   final String id;
//   final String name;
//   final String avatarUrl;

//   User({required this.id, required this.name, required this.avatarUrl});
// }

// class FollowerListScreen extends StatefulWidget {
//   const FollowerListScreen({super.key});

//   @override
//   _FollowerListScreenState createState() => _FollowerListScreenState();
// }

// class _FollowerListScreenState extends State<FollowerListScreen> {
//   late Future<List<User>> _followerList;

//   @override
//   void initState() {
//     super.initState();
//     _followerList = fetchFollowerList();
//   }

//   Future<List<User>> fetchFollowerList() async {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('followers').get();
//     return snapshot.docs.map((doc) {
//       return User(
//         id: doc.id,
//         name: doc['name'],
//         avatarUrl: doc['avatarUrl'],
//       );
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('フォロワー一覧'),
//       ),
//       body: FutureBuilder<List<User>>(
//         future: _followerList,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('フォロワーがいません'));
//           }
//           return ListView.builder(
//             itemCount: snapshot.data!.length,
//             itemBuilder: (context, index) {
//               final user = snapshot.data![index];
//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundImage: NetworkImage(user.avatarUrl),
//                 ),
//                 title: Text(user.name),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

