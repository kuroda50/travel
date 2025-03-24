import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel/component/header.dart';

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
  final ScrollController _scrollController = ScrollController(); // 追加
  late final CollectionReference messagesCollection;
  late final CollectionReference chatRoomsCollection;
  late final CollectionReference usersCollection;

  @override
  void initState() {
    super.initState();
    messagesCollection = FirebaseFirestore.instance
        .collection('chatRooms/${widget.roomId}/messages');
    chatRoomsCollection = FirebaseFirestore.instance.collection('chatRooms');
    usersCollection = FirebaseFirestore.instance.collection('users');
  }

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    final userSnapshot = await usersCollection.doc(userId).get();
    return userSnapshot.data() as Map<String, dynamic>?;
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: "メッセージ",
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
                String? lastDate;
                return ListView.builder(
                  controller: _scrollController, // 追加
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final messageText = messageData['text'];
                    final senderId = messageData['sender'];
                    final Timestamp? timeStamp =
                        messageData['timeStamp'] as Timestamp?;
                    final isSentByMe = senderId == widget.currentUserId;
                    final currentDate = timeStamp != null
                        ? DateFormat("yyyy/MM/dd").format(timeStamp.toDate())
                        : '';
                    final showDate = lastDate != currentDate;
                    lastDate = currentDate;

                    final readBy =
                        List<String>.from(messageData['readBy'] ?? []);
                    final isGroup = readBy.length > 1;
                    final readCount = readBy.length;

                    // メッセージを見たユーザーを更新
                    if (!isSentByMe) {
                      messagesCollection.doc(messageData.id).update({
                        'readBy': FieldValue.arrayUnion([widget.currentUserId])
                      });
                    }

                    return Column(
                      children: [
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              currentDate,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        if (isSentByMe)
                          _SentMessageWidget(
                            message: messageText,
                            timeStamp: timeStamp ?? Timestamp.now(),
                            readBy: readBy,
                            isGroup: isGroup,
                            readCount: readCount,
                          )
                        else
                          FutureBuilder<Map<String, dynamic>?>(
                            future: _getUserData(senderId),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              final userDataMap = userSnapshot.data;
                              final photoURL = userDataMap != null &&
                                      userDataMap.containsKey('photoURL')
                                  ? userDataMap['photoURL']
                                  : null;
                              return _ReceivedMessageWidget(
                                message: messageText,
                                photoURL: photoURL,
                                timeStamp: timeStamp ?? Timestamp.now(),
                                isRead: false, // 自分のメッセージではないので既読は表示しない
                                isGroup: isGroup,
                                readCount: readCount,
                              );
                            },
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Material(
            color: Colors.grey[200],
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        maxLines: null, // 複数行入力可能にする
                        autofocus: true, // ページを開いた際に自動的にフォーカスする
                        controller: _textEditingController,
                        decoration: const InputDecoration(
                          hintText: 'メッセージを入力',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.all(8),
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
                        final newMessage = {
                          'text': msg,
                          'sender': widget.currentUserId,
                          'timeStamp': FieldValue.serverTimestamp(),
                          'readBy': [],
                        };
                        await messagesCollection.add(newMessage);
                        await chatRoomsCollection.doc(widget.roomId).update({
                          'latestMessage': newMessage,
                        });
                        _textEditingController.clear();
                        _scrollToBottom(); // メッセージ送信後にスクロール
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _scrollController.dispose(); // 追加
    super.dispose();
  }
}

class _ReceivedMessageWidget extends StatelessWidget {
  final String message;
  final String? photoURL;
  final Timestamp timeStamp;
  final bool isRead;
  final bool isGroup;
  final int readCount;

  _ReceivedMessageWidget({
    required this.message,
    this.photoURL,
    required this.timeStamp,
    required this.isRead,
    required this.isGroup,
    required this.readCount,
  });

  final _timeFormatter = DateFormat("HH:mm");

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photoURL != null)
            CircleAvatar(
              backgroundImage: NetworkImage(photoURL!),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
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
              Row(
                children: [
                  Text(
                    _timeFormatter.format(timeStamp.toDate()),
                    style: const TextStyle(fontSize: 10),
                  ),
                  if (isRead)
                    Text(
                      isGroup ? ' 既読$readCount' : ' 既読',
                      style: const TextStyle(fontSize: 10, color: Colors.blue),
                    ),
                ],
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
  final Timestamp timeStamp;
  final List<String> readBy;
  final bool isGroup;
  final int readCount;

  _SentMessageWidget({
    required this.message,
    required this.timeStamp,
    required this.readBy,
    required this.isGroup,
    required this.readCount,
  });

  final _timeFormatter = DateFormat("HH:mm");

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
              const SizedBox(width: 5),
              Row(
                children: [
                  Text(
                    _timeFormatter.format(timeStamp.toDate()),
                    style: const TextStyle(fontSize: 10),
                  ),
                  if (readBy.isNotEmpty)
                    Text(
                      isGroup ? ' 既読$readCount' : ' 既読',
                      style: const TextStyle(fontSize: 10, color: Colors.blue),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
