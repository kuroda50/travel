import 'package:flutter/material.dart';

class AccountCreateScreen extends StatefulWidget {
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<AccountCreateScreen> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // 背景色
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 緑のヘッダーを上部に配置
                  Container(
                    width: constraints.maxWidth > 400 ? 390 : constraints.maxWidth * 0.85,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                    ),
                    child: Center(
                      child: Text(
                        '仲間と集まる',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // 内部フォームの白い背景
                  Container(
                    width: constraints.maxWidth > 400 ? 390 : constraints.maxWidth * 0.85, // 横幅
                    padding: EdgeInsets.all(22), // 外側の余白
                    decoration: BoxDecoration(
                      color: Color(0xFFFBFAF8), // 内側背景色
                    ),
                    child: Container(
                      padding: EdgeInsets.all(19), // 内部の余白
                      decoration: BoxDecoration(
                        color: Colors.white, // 内部のフォーム部分
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 17),//内部の四角とプロ設の距離
                          Text('プロフィールを設定しましょう', style: TextStyle(fontSize: 16, color: Colors.black87)),
                          SizedBox(height: 17),//プロ設とあな名の距離
                          _buildTextField('あなたの名前', '山田 太郎'),
                          SizedBox(height: 70),//名前の四角と性別の丸との距離
                          _buildGenderSelection(),
                          SizedBox(height: 17),
                          _buildBirthDateFields(),
                          SizedBox(height: 17),
                          _buildTextField('電子メール', 'example@email.com', isEmail: true),
                          SizedBox(height: 17),
                          _buildTextField('パスワード', '', isPassword: true),
                          SizedBox(height: 17),
                          _buildTextField('パスワード（確認用）', '', isPassword: true),
                          SizedBox(height: 17),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: Text('会員になる', style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '会員になると利用規約に同意したものとみなされます',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder, {bool isEmail = false, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
        SizedBox(height: 4),
        TextField(
          obscureText: isPassword,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: placeholder,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio<String>(
              value: 'female',
              groupValue: _selectedGender,
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            Text('女性'),
          ],
        ),
        Row(
          children: [
            Radio<String>(
              value: 'male',
              groupValue: _selectedGender,
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            Text('男性'),
          ],
        ),
      ],
    );
  }

  Widget _buildBirthDateFields() {
    return Row(
      children: [
        Expanded(child: _buildTextField('年', '', isEmail: false)),
        SizedBox(width: 8),
        Expanded(child: _buildTextField('月', '', isEmail: false)),
        SizedBox(width: 8),
        Expanded(child: _buildTextField('日', '', isEmail: false)),
      ],
    );
  }
}