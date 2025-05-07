// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel/component/header.dart';
// import 'message_room_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

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
        body: Center(
            // ★中央寄せ
            child: ConstrainedBox(
          // ★maxWidth制限
          constraints: BoxConstraints(maxWidth: 600),
          child: FutureBuilder<DocumentSnapshot>(
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

              if (chatRooms.isEmpty) {
                return Center(child: Text('メッセージルームがありません'));
              }
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
                            child:
                                Text('エラーが発生しました: ${chatRoomSnapshot.error}'));
                      }
                      final chatRoomData = chatRoomSnapshot.data!.data()
                          as Map<String, dynamic>?;
                      if (chatRoomData == null) {
                        return SizedBox();
                      }
                      final Map<String, dynamic> latestMessage =
                          chatRoomData['latestMessage'] != null
                              ? Map<String, dynamic>.from(
                                  chatRoomData['latestMessage'])
                              : {};
                      final String lastMessageText =
                          latestMessage['text'] ?? '';
                      final Timestamp lastMessageTime =
                          latestMessage.containsKey('timeStamp')
                              ? (latestMessage['timeStamp'] as Timestamp)
                              : Timestamp.now();
                      final bool isGroup = chatRoomData['group'] ?? false;

                      // 自分ではない方のparticipant IDを取得
                      final List<dynamic> participants =
                          chatRoomData['participants'] ?? [];
                      final String partnerId = participants.firstWhere(
                          (id) => id != currentUserId,
                          orElse: () => '');

                      if (isGroup) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: null,
                            child: Icon(Icons.group),
                          ),
                          title: Text(chatRoomData['postTitle'] ?? 'グループチャット'),
                          subtitle: Text(lastMessageText),
                          trailing: Text(
                            DateFormat('yyyy/MM/dd HH:mm:ss')
                                .format(lastMessageTime.toDate()),
                            style: TextStyle(fontSize: 12),
                          ),
                          onTap: () {
                            context.push('/message-room', extra: {
                              "roomId": chatRoomId,
                              "currentUserId": currentUserId
                            });
                          },
                        );
                      } else {
                        // ② partnerIdが空の場合のフォールバックUI
                        if (partnerId.isEmpty) {
                          // partnerIdが見つからなかった場合の処理
                          return ListTile(
                            leading: CircleAvatar(
                              // 空の場合はデフォルトのアイコンを表示する
                              child: Icon(Icons.person),
                            ),
                            title: Text('情報なし'), // 取得できなかった旨表示
                            subtitle: Text(lastMessageText), // 最新メッセージをそのまま表示
                            trailing: Text(
                              DateFormat('yyyy/MM/dd HH:mm:ss')
                                  .format(lastMessageTime.toDate()),
                              style: TextStyle(fontSize: 12),
                            ),
                            onTap: () {
                              // partnerIdが無い場合、特に処理を行わない
                            },
                          );
                        }

                        // ③ partnerIdが存在する場合、通常通りユーザーデータを取得する
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(partnerId)
                              .get(), // partnerIdからユーザーデータ取得する非同期処理
                          builder: (context, partnerSnapshot) {
                            if (!partnerSnapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (partnerSnapshot.hasError) {
                              return Center(
                                  child: Text(
                                      'エラーが発生しました: ${partnerSnapshot.error}'));
                            }
                            final String partnerName =
                                (partnerSnapshot.data?.data()
                                        as Map<String, dynamic>?)?['name'] ??
                                    'Unknown';
                            final String partnerImageUrl =
                                (partnerSnapshot.data?.data()
                                        as Map<String, dynamic>?)?['iconURL'] ??
                                    '';

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
                                DateFormat('yyyy/MM/dd HH:mm:ss')
                                    .format(lastMessageTime.toDate()),
                                style: TextStyle(fontSize: 12),
                              ),
                              onTap: () {
                                context.push('/message-room', extra: {
                                  "roomId": chatRoomId,
                                  "currentUserId": currentUserId
                                });
                              },
                            );
                          },
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        )));
  }
}
