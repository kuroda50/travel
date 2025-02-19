import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> followingList = [];
  Future<void> fetchFollowingList() async {
    final db = FirebaseFirestore.instance;
    DocumentSnapshot docRef =
        await db.collection("users").doc("HhaNFyI5x623En8ZtNtK").get();
    if (docRef.exists) {
      setState(() {
        followingList = docRef["following"];
      });
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(title: Text("フォロー一覧")),
          body: ListView.builder(
              itemCount: followingList.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 50,
                  child: ListTile(
                    onTap: () {
                      print("${followingList[index]} が押されました");
                    },
                    title: Center(
                      child: Text(followingList[index]),
                    ),
                  ),
                );
              }),
        ));
  }
}
