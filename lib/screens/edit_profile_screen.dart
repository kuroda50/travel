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
  // **性別の初期値**
  bool _isMale = true;
  // **誕生日の初期値**
  DateTime _selectedDate = DateTime.now();

  // **保存ボタンの処理**
  void _saveProfile() {
    final name = _nameController.text;
    final hobbies = _hobbiesController.text;
    final bio = _bioController.text;

    // ここでデータを保存する処理を実装できます。
    print('名前: $name');
    print('趣味: $hobbies');
    print('自己紹介: $bio');
    print('性別: ${_isMale ? "男性" : "女性"}');
    print('誕生日: ${_selectedDate.toLocal()}'); // 誕生日の表示

    // 保存が完了した後の処理
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('プロフィールが保存されました')),
    );
  }

  // 日付選択ダイアログを開く関数
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900), // 1900年から選択可能
      lastDate: DateTime.now(), // 現在の日付まで選択可能
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // 誕生日を更新
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

            // 性別選択ボタン（男性、女性）
            Text('性別:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isMale = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isMale ? Colors.blue : Colors.grey, // 選択中の色
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
                    backgroundColor: !_isMale ? Colors.pink : Colors.grey, // 選択中の色
                  ),
                  child: Text('女性'),
                ),
              ],
            ),
            SizedBox(height: 16),

            // 誕生日選択
            Text('誕生日:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context), // 日付選択を開始
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                    text: "${_selectedDate.toLocal()}".split(' ')[0], // YYYY-MM-DDの形式で表示
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '誕生日を選択',
                  ),
                ),
              ),
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