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

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    final userSnapshot = await usersCollection.doc(userId).get();
    return userSnapshot.data() as Map<String, dynamic>?;
  }

  /// 参加者一覧を取得するメソッド
  /// FirestoreのドキュメントIDを`userId`として利用
  Future<List<Map<String, dynamic>>> _getParticipants() async {
    // チャットルームのデータを取得
    final chatRoomSnapshot = await chatRoomsCollection.doc(roomId).get();
    final chatRoomData = chatRoomSnapshot.data() as Map<String, dynamic>?;

    // 参加者のIDリストを取得
    final participantIds = List<String>.from(chatRoomData?['participants'] ?? []);

    // 各参加者のデータを取得し、ドキュメントIDを`userId`として追加
    final participants = await Future.wait(participantIds.map((userId) async {
      final userSnapshot = await usersCollection.doc(userId).get();
      final userData = userSnapshot.data() as Map<String, dynamic>;
      userData['id'] = userSnapshot.id; // ドキュメントIDを`id`として追加
      return userData;
    }));

    return participants;
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

Future<void> _sendJoinRequest() async {
    await chatRoomsCollection.doc(roomId).update({
      'joinRequests': FieldValue.arrayUnion([currentUserId]) // 自分のIDを追加する
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("参加リクエスト送信完了！"))); // 結果通知
  }

  // --------------- join request 承認／否認処理追加 ---------------

  // /**
  //  * approveJoinRequest: 承認ボタン押下時の処理を行う関数
  //  * @param joinUserId: 承認対象の参加リクエスト送信者のユーザーID
  //  * @param postId: 紐づく投稿のID（投稿ドキュメントの参加者リストを更新するために使用）
  //  * @return Future<void>: 非同期処理を返す
  //  *
  //  * この関数は、投稿ドキュメントに参加リクエスト送信者を追加した上で、
  //  * チャットルームの joinRequests フィールドから対象ユーザーIDを削除する処理を行う
  //  */
  // 承認ボタン押下時の処理を行う関数
Future<void> approveJoinRequest(String joinUserId, String postId) async {
  try {
    // 投稿ドキュメントを取得して、groupChatRoomIdを取得する
    DocumentSnapshot postSnapshot = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
    String groupChatRoomId = postSnapshot['groupChatRoomId'];

    // groupChatRoomIdのチャットルームに参加者を追加する
    await FirebaseFirestore.instance.collection('chatRooms').doc(groupChatRoomId).update({
      'participants': FieldValue.arrayUnion([joinUserId])
    });

    // チャットルームのjoinRequestsからjoinUserIdを削除する
    await chatRoomsCollection.doc(roomId).update({
      'joinRequests': FieldValue.arrayRemove([joinUserId])
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("承認完了！ $joinUserId を参加者に追加"))
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("承認に失敗しました: $e"))
    );
  }
}

  // /**
  //  * denyJoinRequest: 否認ボタン押下時の処理を行う関数
  //  * @param joinUserId: 否認対象の参加リクエスト送信者のユーザーID
  //  * @return Future<void>: 非同期処理を返す
  //  *
  //  * この関数は、チャットルームの joinRequests フィールドから対象ユーザーIDを削除する
  //  */
  Future<void> denyJoinRequest(String joinUserId) async {
    // チャットルームの joinRequests から joinUserId を単純に削除する
    await chatRoomsCollection.doc(roomId).update({
      'joinRequests': FieldValue.arrayRemove([joinUserId]) // 否認リクエスト削除
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("否認完了！ $joinUserId のリクエストを取り消し")) // 結果通知
    );
  }

  /// キック確認ダイアログを表示
void _showKickConfirmationDialog(Map<String, dynamic> participant) {
  final userId = participant['id']; // ドキュメントIDを取得
  final name = participant['name'] ?? '名前なし';

  if (userId == null) {
    print("userIdが取得できませんでした");
    return;
  }

  print("userId: $userId, currentUserId: $currentUserId");

  if (userId == currentUserId) {
    print("自分自身を追放することはできません");
    return;
  }

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
              try {
                // 1. chatRoomsコレクションのparticipantsから削除
                await chatRoomsCollection.doc(roomId).update({
                  'participants': FieldValue.arrayRemove([userId]),
                });

                // 2. postsコレクションのparticipantsから削除
                final chatRoomSnapshot =
                    await chatRoomsCollection.doc(roomId).get();
                final chatRoomData =
                    chatRoomSnapshot.data() as Map<String, dynamic>?;
                final postId = chatRoomData?['postId'];
                if (postId != null) {
                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .update({
                    'participants': FieldValue.arrayRemove([userId]),
                  });
                }

                // 3. usersコレクションのchatRoomsから現在のroomIdを削除
                await usersCollection.doc(userId).update({
                  'chatRooms': FieldValue.arrayRemove([roomId]),
                });

                // 4. キャッシュから削除
                cachedParticipants?.removeWhere((p) => p['id'] == userId);

                // UIを更新
                setState(() {});

                // ダイアログを閉じる
                Navigator.of(context).pop(); // 確認ダイアログを閉じる
                Navigator.of(context).pop(); // 参加者一覧ダイアログを閉じる
              } catch (e) {
                print("追放処理中にエラーが発生しました: $e");
              }
            },
            child: Text("追放"),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: chatRoomsCollection.doc(roomId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: Header(
              title: "メッセージ",
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final chatRoomData = snapshot.data!.data() as Map<String, dynamic>?;
        final isGroup = chatRoomData?['group'] == true;

        return Scaffold(
          appBar: Header(
            title: "メッセージ",
            actions: isGroup
                ? [
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () async {
                        // postsコレクションからorganizerIdを取得
                        final postId = chatRoomData?['postId'];
                        if (postId == null) {
                          print("postIdがnullです。chatRoomData: $chatRoomData");
                          return;
                        }

                        final postSnapshot = await FirebaseFirestore.instance
                            .collection('posts')
                            .doc(postId)
                            .get();

                        if (!postSnapshot.exists) {
                          print("postId: $postId に対応するドキュメントが存在しません");
                          return;
                        }

                        final postData = postSnapshot.data();

                        // postDataがnullまたはorganizerフィールドが存在しない場合のチェック
                        if (postData == null || !postData.containsKey('organizer')) {
                          print("organizerフィールドが見つかりません。postData: $postData");
                          return;
                        }

                        // organizerIdを取得
                        final organizer = postData['organizer'] as Map<String, dynamic>?;
                        if (organizer == null || !organizer.containsKey('organizerId')) {
                          print("organizerIdが見つかりません。organizer: $organizer");
                          return;
                        }

                        final organizerId = organizer['organizerId'];
                        print("organizerId: $organizerId");

                        // 参加者一覧を取得
                        final participants = await _getParticipants();

                        // ダイアログを表示
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
                                    final participant = participants[index];
                                    final name = participant['name'] ?? '名前なし';

                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: participant['photoURL'] != null
                                            ? NetworkImage(participant['photoURL'])
                                            : null,
                                        child: participant['photoURL'] == null
                                            ? Icon(Icons.person)
                                            : null,
                                      ),
                                      title: Text(name),
                                      onTap: organizerId == currentUserId // 主催者の場合
                                          ? () {
                                              // 主催者が他の参加者をタップした場合
                                              _showKickConfirmationDialog(participant);
                                            }
                                          : null, // 主催者以外はタップ不可
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("閉じる"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ]
                : null, // グループでない場合はボタンを表示しない
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
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final messageData = messages[index];
                        final messageText = messageData['text'];
                        final senderId = messageData['sender'];
                        final Timestamp? timeStamp =
                            messageData['timeStamp'] as Timestamp?;
                        final isSentByMe = senderId == currentUserId;
                        final currentDate = timeStamp != null
                            ? DateFormat("yyyy/MM/dd").format(timeStamp.toDate())
                            : '';
                        final showDate = lastDate != currentDate;
                        lastDate = currentDate;

                        final readBy =
                            List<String>.from(messageData['readBy'] ?? []);
                        final isGroup = readBy.length > 1;
                        final readCount = readBy.length;

                        if (!isSentByMe) {
                          messagesCollection.doc(messageData.id).update({
                            'readBy': FieldValue.arrayUnion([currentUserId])
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
                                    isRead: false,
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
              // build メソッド内のウィジェットツリーに、参加リクエストボタンを設置する部分
          // FutureBuilder を使ってチャットルーム情報を取得し、条件に合う場合のみ「参加したい」ボタンを表示する
          FutureBuilder<DocumentSnapshot>(
            future: chatRoomsCollection.doc(roomId).get(), // チャットルームの情報を非同期で取得
            builder: (context, chatRoomSnapshot) {
              if (!chatRoomSnapshot.hasData) return SizedBox(); // データ読み込み中は何も表示しない
              if (chatRoomSnapshot.hasError) return SizedBox(); // エラーの場合はボタン表示しない
              final chatRoomData =
                  chatRoomSnapshot.data!.data() as Map<String, dynamic>;
              // 募集投稿のみボタン表示する。recruitがtrueなら募集投稿
              if (chatRoomData['recruit'] != true) return SizedBox();
              // チャットルーム情報に含まれる投稿IDから、投稿ドキュメントを取得して主催者情報を確認する
              final String postId = chatRoomData['postId'] ?? "";
              // 主催者情報取得のFutureBuilder
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .get(),
                builder: (context, postSnapshot) {
                  if (!postSnapshot.hasData) return SizedBox();
                  if (postSnapshot.hasError) return SizedBox();
                  final postData =
                      (postSnapshot.data!.data() as Map<String, dynamic>);
                  // 投稿の主催者情報から organizerId を抽出
                  final String organizerId =
                      postData['organizer']?['organizerId'] ?? "";
                  // 現在のログインユーザーが主催者なら参加リクエストボタンを表示しない
                  if (organizerId == currentUserId) return SizedBox();
                  // 条件を満たした場合、参加リクエストボタンを表示する
                  return Padding(
                    padding: const EdgeInsets.all(8.0), // 周囲に余白を設定
                    child: SizedBox(
                      width: double.infinity, // 横幅いっぱいにボタンを広げる
                      child: ElevatedButton(
                        onPressed: _sendJoinRequest, // タップ時に参加リクエスト送信の関数を実行
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, // ボタンの背景色
                          foregroundColor: Colors.white,   // ボタンの文字色
                        ),
                        child: Text("参加したい"), // ボタン上のテキスト
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // --------------- host 向け join request 単一表示ウィジェット ---------------
          FutureBuilder<DocumentSnapshot>(
              future: chatRoomsCollection.doc(roomId).get(), // チャットルーム情報を取得
              builder: (context, chatRoomSnapshot) {
                if (!chatRoomSnapshot.hasData || chatRoomSnapshot.data == null) return SizedBox(); // データ未取得またはnullなら何も表示しない
                if (chatRoomSnapshot.hasError) return SizedBox();   // エラーなら何も表示しない
                final chatRoomData = (chatRoomSnapshot.data!.data() as Map<String, dynamic>?);
                if (chatRoomData == null) return SizedBox(); // データがnullなら何も表示しない
                // joinRequests 配列を取得（存在しなければ空リスト）
                final List<dynamic> joinRequests = chatRoomData['joinRequests'] ?? [];
                // チャットルームに紐づく投稿IDを取得
                final String postId = chatRoomData['postId'] ?? "";
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
                  builder: (context, postSnapshot) {
                    if (!postSnapshot.hasData || postSnapshot.data == null) return SizedBox(); // データ未取得またはnullなら何も表示しない
                    if (postSnapshot.hasError) return SizedBox();   // エラーなら何も表示しない
                    final postData = (postSnapshot.data!.data() as Map<String, dynamic>?);
                    if (postData == null) return SizedBox(); // データがnullなら何も表示しない
                    // 投稿の主催者情報から organizerId を抽出
                    final String organizerId = postData['organizer']?['organizerId'] ?? "";
                    // 現在のログインユーザーが主催者でなければ何も表示しない
                    if (currentUserId != organizerId) return SizedBox();
                    // 承認／否認すべきリクエストがなければ表示しない
                    if (joinRequests.isEmpty) return SizedBox();
                    // joinRequests 配列から単一のリクエスト (先頭の要素) を取得
                    final String requestUserId = joinRequests.first;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // セクションタイトル
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "参加リクエスト",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        // 単一リクエストの表示
                        ListTile(
                          leading: Icon(Icons.person), // ユーザーアイコン代用
                          title: Text("ユーザーID: $requestUserId"), // ユーザーID表示
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 承認ボタン
                              ElevatedButton(
                                onPressed: () => approveJoinRequest(requestUserId, postId),
                                child: Text("承認"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                              SizedBox(width: 8), // ボタン間に余白
                              // 否認ボタン
                              ElevatedButton(
                                onPressed: () => denyJoinRequest(requestUserId),
                                child: Text("否認"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
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
                            maxLines: null,
                            autofocus: true,
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
                              'sender': currentUserId,
                              'timeStamp': FieldValue.serverTimestamp(),
                              'readBy': [],
                            };
                            await messagesCollection.add(newMessage);
                            await chatRoomsCollection.doc(roomId).update({
                              'latestMessage': newMessage,
                            });
                            _textEditingController.clear();
                            _scrollToBottom();
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
      },
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