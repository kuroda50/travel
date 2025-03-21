// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel/component/header.dart';
import 'message_room_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: Header(
        title: "メッセージ一覧",
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: usersCollection.doc(currentUserId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }
          final userData = snapshot.data!;
          final userMap = userData.data() as Map<String, dynamic>?;

          if (userMap == null || !userMap.containsKey('chatRooms')) {
            return Center(child: Text('メッセージルームがありません'));
          }

          final List<dynamic> chatRooms = userMap['chatRooms'];

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoomId = chatRooms[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('chatRooms')
                    .doc(chatRoomId)
                    .get(),
                builder: (context, chatRoomSnapshot) {
                  if (!chatRoomSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (chatRoomSnapshot.hasError) {
                    return Center(
                        child: Text('エラーが発生しました: ${chatRoomSnapshot.error}'));
                  }
                  final chatRoomData = chatRoomSnapshot.data!;
                  final Map<String, dynamic> latestMessage =
                      Map<String, dynamic>.from(chatRoomData['latestMessage']);
                  final String lastMessageText = latestMessage['text'];
                  final Timestamp lastMessageTime =
                      latestMessage.containsKey('timeStamp')
                          ? (latestMessage['timeStamp'] as Timestamp)
                          : Timestamp.now();
                  final String senderId = latestMessage['sender'];

                  return FutureBuilder<DocumentSnapshot>(
                    future: usersCollection.doc(senderId).get(),
                    builder: (context, partnerSnapshot) {
                      if (!partnerSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (partnerSnapshot.hasError) {
                        return Center(
                            child:
                                Text('エラーが発生しました: ${partnerSnapshot.error}'));
                      }
                      final partnerData = partnerSnapshot.data!;
                      final partnerDataMap =
                          partnerData.data() as Map<String, dynamic>?;
                      final String partnerName = partnerDataMap != null &&
                              partnerDataMap.containsKey('name')
                          ? partnerDataMap['name']
                          : 'Unknown';
                      final String partnerImageUrl = partnerDataMap != null &&
                              partnerDataMap.containsKey('imageUrl')
                          ? partnerDataMap['imageUrl']
                          : '';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: partnerImageUrl.isNotEmpty
                              ? NetworkImage(partnerImageUrl)
                              : null,
                          child: partnerImageUrl.isEmpty
                              ? Icon(Icons.person)
                              : null,
                        ),
                        title: Text(partnerName),
                        subtitle: Text(lastMessageText),
                        trailing: Text(
                          lastMessageTime.toDate().toString(),
                          style: TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessageRoomScreen(
                                roomId: chatRoomId,
                                currentUserId: currentUserId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
