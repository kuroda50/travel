import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isMale = true;
  DateTime _selectedDate = DateTime.now();

  // Firebase Firestoreインスタンスを取得
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _saveProfile() async {
    final name = _nameController.text;
    final hobbies = _hobbiesController.text;
    final bio = _bioController.text;

    try {
      // Firestoreに保存する
      await _firestore.collection('users').add({
        'name': name,
        'gender': _isMale ? '男性' : '女性',
        'birthdate': _selectedDate,
        'hobbies': hobbies,
        'bio': bio,
      });

      // 保存成功のメッセージ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('プロフィールが保存されました')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("プロフィール編集"),
      ),
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
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isMale = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isMale ? Colors.blue : Colors.grey,
                  ),
                  child: Text('男性'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isMale = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isMale ? Colors.pink : Colors.grey,
                  ),
                  child: Text('女性'),
                ),
              ],
            ),
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
            TextField(
              controller: _hobbiesController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '趣味を入力',
              ),
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
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}