import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // **コントローラーの定義**
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
   // **性別スイッチの初期値**
  bool _isMale = true;

  // **保存ボタンの処理**
  void _saveProfile() {
    final name = _nameController.text;
    final hobbies = _hobbiesController.text;
    final bio = _bioController.text;

    // ここでデータを保存する処理を実装できます。
    // 例えば、APIに送信する、ローカルストレージに保存するなど
    print('名前: $name');
    print('趣味: $hobbies');
    print('自己紹介: $bio');
    print('性別: ${_isMale ? "男性" : "女性"}');

    // 保存が完了した後の処理
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('プロフィールが保存されました')),
    );
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
            // 名前入力欄
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

            // 性別選択スイッチ
            Text('性別:', style: TextStyle(fontSize: 18)),
            Row(
              children: [
                Text('男性'),
                Switch(
                  value: _isMale,
                  onChanged: (bool value) {
                    setState(() {
                      _isMale = value;
                    });
                  },
                ),
                Text('女性'),
              ],
            ),
            SizedBox(height: 16),

            // 趣味の入力欄
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

            // 自己紹介の入力欄
            Text('自己紹介:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 4, // 複数行入力
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '自己紹介を入力',
              ),
            ),
            SizedBox(height: 24),

            // 保存ボタン
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