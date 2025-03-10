import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_room_screen.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = 'userId111'; // 自分のユーザーID
    final CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: const Text('メッセージ'),
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
            return Center(child: Text('チャットルームが見つかりません'));
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
                  final String lastMessage = chatRoomData['lastMessage'];
                  final Timestamp lastMessageTime =
                  chatRoomData['lastMessageTime'];
                  final String partnerId = chatRoomData['partnerId'];

                  return FutureBuilder<DocumentSnapshot>(
                    future: usersCollection.doc(partnerId).get(),
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
                      final String partnerName = partnerData['name'];
                      final String partnerImageUrl = partnerData['imageUrl'];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(partnerImageUrl),
                        ),
                        title: Text(partnerName),
                        subtitle: Text(lastMessage),
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
