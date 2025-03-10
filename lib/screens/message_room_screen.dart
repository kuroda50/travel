import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageRoomScreen extends StatefulWidget {
  final String? roomId;
  final String? currentUserId;

  const MessageRoomScreen({
    super.key,
    this.roomId,
    this.currentUserId,
  });

  @override
  _MessageRoomScreenState createState() => _MessageRoomScreenState();
}

class _MessageRoomScreenState extends State<MessageRoomScreen> {
  final _textEditingController = TextEditingController();
  late final CollectionReference messagesCollection;
  late final CollectionReference usersCollection;

  @override
  void initState() {
    super.initState();
    messagesCollection = FirebaseFirestore.instance
        .collection('chatRooms/${widget.roomId}/messages');
    usersCollection = FirebaseFirestore.instance.collection('users');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メッセージルーム'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesCollection.orderBy('timeStamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final messageText = messageData['text'];
                    final senderId = messageData['sender'];
                    final isSentByMe = senderId == widget.currentUserId;
                    if (isSentByMe) {
                      return _SentMessageWidget(message: messageText);
                    } else {
                      return FutureBuilder<DocumentSnapshot>(
                        future: usersCollection.doc(senderId).get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final userData = userSnapshot.data!;
                          final photoURL = userData['photoURL'];
                          return _ReceivedMessageWidget(
                            message: messageText,
                            photoURL: photoURL,
                          );
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      cursorColor: Colors.black,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.black,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      size: 20,
                    ),
                    color: Colors.blue,
                    onPressed: () async {
                      var msg = _textEditingController.text.trim();
                      if (msg.isEmpty) {
                        return;
                      }
                      await messagesCollection.add({
                        'text': msg,
                        'sender': widget.currentUserId,
                        'timeStamp': FieldValue.serverTimestamp(),
                        'isRead': false,
                      });
                      _textEditingController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceivedMessageWidget extends StatelessWidget {
  final String message;
  final String photoURL;

  _ReceivedMessageWidget({required this.message, required this.photoURL});

  final _formatter = DateFormat("HH:mm");

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(photoURL),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  message,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                _formatter.format(DateTime.now()),
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SentMessageWidget extends StatelessWidget {
  final String message;

  _SentMessageWidget({required this.message});

  final _formatter = DateFormat("HH:mm");

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatter.format(DateTime.now()),
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                decoration: const BoxDecoration(
                  color: Colors.lightGreenAccent,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  message,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
