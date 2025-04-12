import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // go_routerをインポート
import 'package:travel/colors/color.dart';
import 'package:travel/component/header.dart'; // Headerウィジェットをインポート

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController hobbyController = TextEditingController();
  bool _isMale = true;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true; // ローディング状態を管理
  List<String> hobbies = [];
  String? _genderError;

  // Firebase Firestoreインスタンスを取得
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      setState(() {
        _nameController.text = data['name'] ?? '';
        hobbies = (data['hobbies'] as List<dynamic>).cast<String>();
        _bioController.text = data['bio'] ?? '';
        _isMale = data['gender'] == 'male';
        _selectedDate = (data['birthday'] != null)
            ? (data['birthday'] as Timestamp).toDate()
            : DateTime.now();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text;
    final bio = _bioController.text;

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final userRef = await _firestore.collection("users").doc(userId);
    try {
      // Firestoreに保存する
      await userRef.update({
        'name': name,
        'gender': _isMale ? 'male' : 'female',
        'birthday': _selectedDate,
        'hobbies': hobbies,
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp()
      });

      // 保存成功のメッセージ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('プロフィールが保存されました')),
      );

      // 状態を更新
      setState(() {
        _isLoading = false;
      });

      // 編集後のデータを遷移元に渡す
      context.pop({
        'name': name,
        'gender': _isMale ? 'male' : 'female',
        'birthday': _selectedDate,
        'hobbies': hobbies,
        'bio': bio,
      });
    } catch (e) {
      // 保存失敗のエラーメッセージ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存中にエラーが発生しました')),
      );
      print("Error saving profile: $e");
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性',
          style: TextStyle(fontSize: 13, color: Colors.black87),
        ),
        SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: ToggleButtons(
            isSelected: [_isMale, !_isMale],
            onPressed: (int index) {
              setState(() {
                _isMale = !_isMale;
                _genderError = null;
              });
            },
            borderRadius: BorderRadius.circular(7),
            selectedColor: Colors.white, // 選択時の文字色
            fillColor: Colors.green, // 選択時の背景色
            borderColor: Colors.black87, // 枠線の色
            borderWidth: 0.6, // 枠線の太さ
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.female, color: AppColor.warningColor),
                    SizedBox(width: 4),
                    Text('女性',
                        style: TextStyle(color: Colors.black87)), // Textの色も変更
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.male, color: Colors.blue),
                    SizedBox(width: 4),
                    Text('男性',
                        style: TextStyle(color: Colors.black87)), // Textの色も変更
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_genderError != null) // エラーメッセージを表示
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              _genderError!,
              style: TextStyle(color: AppColor.warningColor, fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: Header(title: "プロフィール編集"),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: Header(title: "プロフィール編集"), // ヘッダーを追加
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text('名前:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '名前を入力',
              ),
            ),
            SizedBox(height: 16),
            Text('性別:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            _buildGenderSelection(),
            SizedBox(height: 16),
            Text('誕生日:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                    text: "${_selectedDate.toLocal()}".split(' ')[0],
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '誕生日を選択',
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('趣味:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hobbyController,
                    decoration: InputDecoration(
                      hintText: '趣味を入力',
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          hobbies.add(value);
                          hobbyController.clear();
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (hobbyController.text.isNotEmpty) {
                      setState(() {
                        hobbies.add(hobbyController.text);
                        hobbyController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            Wrap(
              spacing: 8.0,
              children: hobbies
                  .map((hobby) => Chip(
                        label: Text(hobby),
                        deleteIcon: Icon(Icons.cancel), // バツマークのアイコン
                        onDeleted: () {
                          setState(() {
                            hobbies.remove(hobby); // タップされたタグをリストから削除
                          });
                        },
                      ))
                  .toList(),
            ),
            SizedBox(height: 16),
            Text('自己紹介:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '自己紹介を入力',
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.mainButtonColor,
                ),
                child: Text(
                  '保存',
                  style: TextStyle(color: AppColor.subTextColor), // テキストの色を白に変更
                )),
          ],
        ),
      ),
    );
  }
}
