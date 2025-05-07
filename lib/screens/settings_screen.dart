import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/component/header.dart';
import 'package:go_router/go_router.dart'; // go_routerをインポート

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: "設定"),
      body: Center(
          child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600, // 🔄 最大600px（スマホ幅に固定）
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 50.0, bottom: 10.0),
                child: Text(
                  'アカウント設定',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            buildButton(context, 'メールアドレスを変更する',
                isFirst: true, showDialog: false, isEmailChange: true), // 変更点
            buildButton(context, 'パスワードを変更する',
                showDialog: false, isPasswordChange: true),
            buildButton(context, 'ログアウト', isLogout: true),
            buildButton(context, 'アカウントを削除する', isLast: true, isDelete: true),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 50.0, bottom: 10.0),
                child: Text(
                  'サービス',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            buildButton(context, '利用規約',
                isTerms: true, isFirst: true, isLast: true, showDialog: false),
          ],
        ),
      )),
    );
  }

  Widget buildButton(BuildContext context, String text,
      {bool isFirst = false,
      bool isLast = false,
      bool isLogout = false,
      bool isDelete = false,
      bool showDialog = true,
      bool isTerms = false,
      bool isPasswordChange = false,
      bool isEmailChange = false}) {
    // 変更点
    BorderRadius borderRadius = BorderRadius.only(
      topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
      topRight: isFirst ? const Radius.circular(16) : Radius.zero,
      bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
      bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
    );

    return Container(
      width: 300,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: Colors.black),
      ),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () => {
            if (showDialog)
              {
                showConfirmationDialog(context, text, isLogout, isDelete),
              }
            else if (isPasswordChange)
              {
                context.go('/password-change'),
              }
            else if (isEmailChange)
              {
                context.go('/email-change'),
              }
            else if (isTerms)
              {
                context.push('/terms-of-use'),
              }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
              side: const BorderSide(color: Colors.black),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}

void showConfirmationDialog(
    BuildContext context, String title, bool isLogout, bool isDelete) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(isLogout
              ? 'ログアウトしますか？'
              : isDelete
                  ? 'アカウントを削除しますか？\n削除すると復元できません。'
                  : ''),
          actions: [
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: AppColor.warningColor,
                  foregroundColor: AppColor.subTextColor),
              child: Text(isLogout
                  ? 'ログアウト'
                  : isDelete
                      ? '削除'
                      : 'エラー'),
              onPressed: () {
                if (isLogout) {
                  // ログアウト処理
                  try {
                    FirebaseAuth.instance.signOut();
                    context.go('/travel'); // ログアウト後に/travelに遷移
                  } catch (e) {
                    print(e);
                  }
                } else if (isDelete) {
                  // アカウント削除処理
                  try {
                    deleteUser(context);
                    context.go('/travel'); // アカウント削除後に/travelに遷移
                  } catch (e) {
                    print(e);
                  }
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

Future<void> deleteUser(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  String userId = user.uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  await firestore.runTransaction((transaction) async {
    DocumentReference userRef = firestore.collection("users").doc(userId);

    // １フォロー、フォロワー関係を解消
    QuerySnapshot userSnapshot = await firestore.collection("users").get();
    for (QueryDocumentSnapshot userDoc in userSnapshot.docs) {
      transaction.update(userDoc.reference, {
        "followings": FieldValue.arrayRemove([userId]),
        "followers": FieldValue.arrayRemove([userId])
      });
    }

    // ２参加しているチャットルームから削除
    QuerySnapshot chatSnapshot = await firestore
        .collection("chatRooms")
        .where("participants", arrayContains: userId)
        .get();
    for (QueryDocumentSnapshot chatDoc in chatSnapshot.docs) {
      bool isGroup = chatDoc["group"];
      if (isGroup) {
        // グループチャットの場合は、"participants"から削除
        transaction.update(chatDoc.reference, {
          "participants": FieldValue.arrayRemove([userId])
        });
      } else {
        // グループチャットでない場合は、部屋を物理削除
        transaction.delete(chatDoc.reference);
      }
    }

    // ３投稿から削除
    List<String> participatedPostsIds = await userRef.get().then((doc) {
      if (doc.exists) {
        return List<String>.from(doc["participatedPosts"] ?? []);
      }
      return [];
    });
    for (String postId in participatedPostsIds) {
      DocumentReference postRef = firestore.collection("posts").doc(postId);
      DocumentSnapshot post = await postRef.get();
      String organizerId = post["organizer"]["organizerId"];
      if (organizerId == userId) {
        // 自分が主催者の場合は、投稿を論理削除
        transaction.update(postRef, {
          "isDeleted": true,
          "participants": FieldValue.arrayRemove([userId])
        });
      } else {
        // 自分が主催者でない場合は、参加者から削除
        transaction.update(postRef, {
          "participants": FieldValue.arrayRemove([userId])
        });
      }
    }
    // ４ユーザを論理削除
    transaction.update(userRef, {"isDeleted": true});
  });
  // ５FirebaseAuthからユーザを削除
  await user.delete();
}
