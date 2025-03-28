// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel/component/header.dart';

class MessageRoomScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const MessageRoomScreen({
    super.key,
    this.extraData,
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
  String roomId = "", currentUserId = "";
  List<Map<String, dynamic>>? cachedParticipants;

  @override
  void initState() {
    super.initState();
    roomId = widget.extraData!["roomId"];
    currentUserId = widget.extraData!["currentUserId"];
    messagesCollection =
        FirebaseFirestore.instance.collection('chatRooms/$roomId/messages');
    chatRoomsCollection = FirebaseFirestore.instance.collection('chatRooms');
    usersCollection = FirebaseFirestore.instance.collection('users');
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final userSnapshot = await usersCollection.doc(userId).get();
    return userSnapshot.data() as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> fetchDocument(
      String collectionPath, String docId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(docId)
          .get();
      return snapshot.data();
    } catch (e) {
      print("Firestore取得エラー: $e");
      return null;
    }
  }

  /// Firestoreのドキュメントを更新する関数
  /// [collectionPath] - コレクションのパス
  /// [docId] - ドキュメントID
  /// [updates] - 更新内容
  Future<void> updateDocument(
      String collectionPath, String docId, Map<String, dynamic> updates) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(docId)
          .update(updates);
    } catch (e) {
      print("Firestore更新エラー: $e");
    }
  }

//ーーーーーーーーーー　UIの構築　ーーーーーーーーーー
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: chatRoomsCollection.doc(roomId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: Header(title: "メッセージ"),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final chatRoomData = snapshot.data!.data() as Map<String, dynamic>?;
        final isGroup = chatRoomData?['group'] == true;
        final participants =
            List<String>.from(chatRoomData?['participants'] ?? []);

        return Scaffold(
          appBar: Header(
            title: "メッセージ",
            actions: isGroup
                ? [
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'manageParticipants') {
                          showParticipantDialog(context, participants, roomId);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'manageParticipants',
                          child: Text("参加者を管理"),
                        ),
                      ],
                    ),
                  ]
                : null,
          ),
          body: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildMessageList(isGroup),
                    ),
                    // ここにボタンとリストを移動
                    buildJoinRequestButton(
                      roomId: roomId,
                      currentUserId: currentUserId,
                      chatRoomsCollection: chatRoomsCollection,
                    ),
                    buildJoinRequestList(
                      roomId: roomId,
                      currentUserId: currentUserId,
                      chatRoomsCollection: chatRoomsCollection,
                    ),
                  ],
                ),
              ),
              // 入力エリアを最後に配置
              _buildInputArea(),
            ],
          ),
        );
      },
    );
  }

//　ーーーーーーーーーー　以下は関数　ーーーーーーーーーー

  @override
  void dispose() {
    _textEditingController.dispose();
    _scrollController.dispose(); // 追加
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// 参加リクエストを送信する関数
  Future<void> sendJoinRequest() async {
    try {
      // Firestoreのデータを更新してリクエストを送信
      await chatRoomsCollection.doc(roomId).update({
        'joinRequests': FieldValue.arrayUnion([currentUserId]),
        'recruit': false,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("参加リクエスト送信完了！")),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("リクエスト送信に失敗しました")),
      );
    }
  }

  /// 参加リクエストを処理する関数
  Future<void> handleJoinRequest({
    required String action, // "approve" or "deny"
    required String joinUserId,
    required String roomId,
    String? postId,
  }) async {
    try {
      if (action == "approve" && postId != null) {
        final postData = await fetchDocument('posts', postId);
        final groupChatRoomId = postData?['groupChatRoomId'];

        if (groupChatRoomId != null) {
          // 参加者を追加
          await updateDocument('chatRooms', groupChatRoomId, {
            'participants': FieldValue.arrayUnion([joinUserId]),
          });
          await updateDocument('posts', postId, {
            'participants': FieldValue.arrayUnion([joinUserId]),
          });
          await updateDocument('users', joinUserId, {
            'participatedPosts': FieldValue.arrayUnion([postId]), // postIdを追加
            'chatRooms':
                FieldValue.arrayUnion([groupChatRoomId]), // groupChatRoomIdを追加
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("リクエストを承認しました！")),
          );
        }
      } else if (action == "deny") {
        await updateDocument('chatRooms', roomId, {
          'recruit': true,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("リクエストを拒否しました")),
        );
      }
      await updateDocument('chatRooms', roomId, {
        'joinRequests': FieldValue.arrayRemove([joinUserId]),
      });

      setState(() {});
    } catch (e) {
      print("$action リクエスト処理エラー: $e");
    }
  }

  /// 参加者を追放する関数
  Future<void> kickParticipant(String userId, String roomId) async {
    try {
      await updateDocument('chatRooms', roomId, {
        'participants': FieldValue.arrayRemove([userId]),
      });
      final chatRoomData = await fetchDocument('chatRooms', roomId);
      final postId = chatRoomData?['postId'];
      if (postId != null) {
        await updateDocument('posts', postId, {
          'participants': FieldValue.arrayRemove([userId]),
        });
      }
      await updateDocument('users', userId, {
        'chatRooms': FieldValue.arrayRemove([roomId]),
      });
    } catch (e) {
      print("キック処理エラー: $e");
    }
  }

  /// キックダイアログを表示する関数
  void showKickDialog(
      BuildContext context, String userId, String name, String roomId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("確認"),
          content: Text("$name を追放しますか？"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("キャンセル"),
            ),
            TextButton(
              onPressed: () async {
                await kickParticipant(userId, roomId);
                Navigator.of(context).pop();
              },
              child: Text("追放"),
            ),
          ],
        );
      },
    );
  }

  /// 参加リクエストボタンを生成する関数
  Widget buildJoinRequestButton({
    required String roomId,
    required String currentUserId,
    required CollectionReference chatRoomsCollection,
  }) {
    return FutureBuilder<DocumentSnapshot>(
      future: chatRoomsCollection.doc(roomId).get(), // チャットルーム情報を取得
      builder: (context, chatRoomSnapshot) {
        if (!chatRoomSnapshot.hasData || chatRoomSnapshot.hasError)
          return SizedBox(); // データがない場合やエラー時は何も表示しない

        final chatRoomData =
            chatRoomSnapshot.data!.data() as Map<String, dynamic>;
        if (chatRoomData['recruit'] != true)
          return SizedBox(); // 募集投稿でない場合は何も表示しない

        final String postId = chatRoomData['postId'] ?? ""; // 投稿IDを取得
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .get(), // 投稿情報を取得
          builder: (context, postSnapshot) {
            if (!postSnapshot.hasData || postSnapshot.hasError)
              return SizedBox(); // データがない場合やエラー時は何も表示しない
            if (postSnapshot.data!.data() == null) {
              return SizedBox();
            }
            final postData =
                postSnapshot.data!.data() as Map<String, dynamic>; //ここでエラーが起きる
            final String organizerId =
                postData['organizer']?['organizerId'] ?? ""; // 主催者IDを取得

            if (organizerId == currentUserId)
              return SizedBox(); // 主催者の場合はボタンを表示しない

            // 条件を満たした場合に参加リクエストボタンを表示
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: sendJoinRequest, // 参加リクエスト送信関数を実行
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("参加したい"),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// リクエストリストを生成する関数
  Widget buildJoinRequestList({
    required String roomId,
    required String currentUserId,
    required CollectionReference chatRoomsCollection,
  }) {
    return FutureBuilder<DocumentSnapshot>(
      future: chatRoomsCollection.doc(roomId).get(),
      builder: (context, chatRoomSnapshot) {
        if (!chatRoomSnapshot.hasData || chatRoomSnapshot.hasError)
          return SizedBox();

        final chatRoomData =
            chatRoomSnapshot.data!.data() as Map<String, dynamic>;
        final List<dynamic> joinRequests = chatRoomData['joinRequests'] ?? [];
        final String postId = chatRoomData['postId'] ?? "";

        if (joinRequests.isEmpty) return SizedBox(); // リクエストがない場合は何も表示しない

        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('posts').doc(postId).get(),
          builder: (context, postSnapshot) {
            if (!postSnapshot.hasData || postSnapshot.hasError)
              return SizedBox();

            final postData = postSnapshot.data!.data() as Map<String, dynamic>;
            final String organizerId =
                postData['organizer']?['organizerId'] ?? "";

            if (currentUserId != organizerId)
              return SizedBox(); // 主催者でない場合は表示しない

            final String requestUserId = joinRequests.first; // 最初のリクエストを取得

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "参加リクエスト",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text("ユーザーID: $requestUserId"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => handleJoinRequest(
                          action: "approve",
                          joinUserId: requestUserId,
                          roomId: roomId,
                          postId: postId,
                        ),
                        child: Text("承認"),
                      ),
                      ElevatedButton(
                        onPressed: () => handleJoinRequest(
                          action: "deny",
                          joinUserId: requestUserId,
                          roomId: roomId,
                        ),
                        child: Text("否認"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 入力エリアを構築する関数
  Widget _buildInputArea() {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'メッセージを入力',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, size: 20),
                color: Colors.blue,
                onPressed: _sendMessage, // メッセージ送信処理を関数化
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// メッセージリストを構築する関数
  Widget _buildMessageList(bool isGroup) {
    return StreamBuilder<QuerySnapshot>(
      stream: messagesCollection.orderBy('timeStamp').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;
        String? lastDate; // 前のメッセージの日付を追跡する変数

        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageData = messages[index];
            final Timestamp? timeStamp = messageData['timeStamp'] as Timestamp?;
            final currentDate = timeStamp != null
                ? DateFormat("yyyy/MM/dd").format(timeStamp.toDate())
                : '';

            // 日付が異なる場合のみ日付を表示
            final showDate = lastDate != currentDate;
            lastDate = currentDate;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDate)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        currentDate,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),
                _buildMessageItem(messageData, isGroup),
              ],
            );
          },
        );
      },
    );
  }

  /// メッセージアイテムの構築と既読処理の関数
  Widget _buildMessageItem(QueryDocumentSnapshot messageData, bool isGroup) {
    final messageText = messageData['text'];
    final senderId = messageData['sender'];
    final Timestamp? timeStamp = messageData['timeStamp'] as Timestamp?;
    final isSentByMe = senderId == currentUserId;
    final readBy = List<String>.from(messageData['readBy'] ?? []);
    final readCount = readBy.length;

    // 既読処理をイベントに移動
    void markAsRead() {
      if (!isSentByMe) {
        messagesCollection.doc(messageData.id).update({
          'readBy': FieldValue.arrayUnion([currentUserId]),
        });
      }
    }

    return GestureDetector(
      onTap: markAsRead, // タップ時に既読処理を実行
      child: Column(
        children: [
          if (timeStamp != null)
            buildMessageWidget(
              message: messageText,
              timeStamp: timeStamp,
              isSentByMe: isSentByMe,
              isGroup: isGroup, // isGroupを使用
              readCount: readCount,
              isRead: readBy.isNotEmpty,
            ),
        ],
      ),
    );
  }

  /// メッセージを送信する関数
  Future<void> _sendMessage() async {
    final msg = _textEditingController.text.trim();
    if (msg.isEmpty) return;

    final newMessage = {
      'text': msg,
      'sender': currentUserId,
      'timeStamp': FieldValue.serverTimestamp(),
      'readBy': [],
    };

    try {
      await messagesCollection.add(newMessage);
      await chatRoomsCollection.doc(roomId).update({
        'latestMessage': newMessage,
      });
      _textEditingController.clear();
      _scrollToBottom();
    } catch (e) {
      debugPrint("メッセージ送信エラー: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("メッセージ送信に失敗しました")),
      );
    }
  }

  /// メッセージウィジェットを生成する関数
  Widget buildMessageWidget({
    required String message,
    required Timestamp timeStamp,
    required bool isSentByMe,
    String? photoURL,
    bool isRead = false,
    bool isGroup = false,
    int readCount = 0,
  }) {
    final _timeFormatter = DateFormat("HH:mm");

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment:
            isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isSentByMe)
            photoURL != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(photoURL),
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
          if (!isSentByMe) const SizedBox(width: 5),
          Column(
            crossAxisAlignment:
                isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                decoration: BoxDecoration(
                  color: isSentByMe ? Colors.lightGreenAccent : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(message),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  // メッセージの送信時間を表示
                  Text(
                    _timeFormatter.format(timeStamp.toDate()),
                    style: const TextStyle(fontSize: 10),
                  ),
                  // 自分のメッセージの場合のみ既読情報を表示
                  if (isSentByMe)
                    if (isGroup) // グループの場合は既読数を表示
                      Text(
                        ' 既読$readCount',
                        style:
                            const TextStyle(fontSize: 10, color: Colors.blue),
                      )
                    else if (isRead) // 個別チャットの場合は「既読」を表示
                      Text(
                        ' 既読',
                        style:
                            const TextStyle(fontSize: 10, color: Colors.blue),
                      ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 参加者一覧を表示するダイアログを表示する関数
  void showParticipantDialog(
      BuildContext context, List<String> participants, String roomId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("参加者一覧"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final userId = participants[index];
                return FutureBuilder<Map<String, dynamic>?>(
                  future: getUserData(userId),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return ListTile(
                        title: Text("読み込み中..."),
                      );
                    }
                    final userData = userSnapshot.data!;
                    final name = userData['name'] ?? '名前なし';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: userData['photoURL'] != null
                            ? NetworkImage(userData['photoURL'])
                            : null,
                        child: userData['photoURL'] == null
                            ? Icon(Icons.person)
                            : null,
                      ),
                      title: Text(name),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () =>
                            showKickDialog(context, userId, name, roomId),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("閉じる"),
            ),
          ],
        );
      },
    );
  }
}
