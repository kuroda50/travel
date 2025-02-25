import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';

class AccountCreateScreen extends StatefulWidget {
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<AccountCreateScreen> {
  String? _selectedGender;
  double widthFactor = 1; // フィールドの幅を調整する係数
  double headerHeight = 88; // ヘッダーの縦の大きさ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.subBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double formWidth = constraints.maxWidth > 400 ? 390 : constraints.maxWidth * widthFactor;
          
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: formWidth,
                    height: headerHeight,
                    decoration: BoxDecoration(
                      color: Color(0xFF559900),
                    ),
                    child: Center(
                      child: Text(
                        '仲間と集まる',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: formWidth,
                    padding: EdgeInsets.all(22),
                    decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                    child: Container(
                      padding: EdgeInsets.all(19),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9F7F5),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 17),
                          Text('プロフィールを設定しましょう', style: TextStyle(fontSize: 16, color: Colors.black87)),
                          SizedBox(height: 17),
                          _buildTextField('あなたの名前', '山田 太郎', formWidth),
                          SizedBox(height: 17),
                          _buildGenderSelection(),
                          SizedBox(height: 17),
                          _buildBirthDateFields(formWidth),
                          SizedBox(height: 17),
                          _buildTextField('電子メール', 'example@email.com', formWidth, isEmail: true),
                          SizedBox(height: 17),
                          _buildTextField('パスワード', '', formWidth, isPassword: true),
                          SizedBox(height: 17),
                          _buildTextField('パスワード（確認用）', '', formWidth, isPassword: true),
                          SizedBox(height: 17),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF559900)),
                            child: Text('会員になる', style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '会員になると利用規約に同意したものとみなされます',
                            style: TextStyle(fontSize: 10, color: Color(0xFFE0E0E0)),
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

  Widget _buildTextField(String label, String placeholder, double width, {bool isEmail = false, bool isPassword = false}) {
    return SizedBox(
      width: width * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.black87)),
          SizedBox(height: 17),
          TextField(
            obscureText: isPassword,
            keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: placeholder,
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildGenderSelection() {
    return Align(
      alignment: Alignment.centerLeft, // 左寄せ
      child: ToggleButtons(
        isSelected: [_selectedGender == 'female', _selectedGender == 'male'],
        onPressed: (int index) {
          setState(() {
            _selectedGender = index == 0 ? 'female' : 'male';
          });
        },
        borderRadius: BorderRadius.circular(8), // 角の丸み
        selectedColor: Colors.white, // 選択時の文字色
        fillColor: Colors.green, // 選択時の背景色
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.female, color: Colors.red),
                SizedBox(width: 4),
                Text('女性'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.male, color: Colors.blue),
                SizedBox(width: 4),
                Text('男性'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthDateFields(double width) {
    return Row(
      children: [
        Expanded(child: _buildTextField('年', '', width * 0.3)),
        SizedBox(width: 8),
        Expanded(child: _buildTextField('月', '', width * 0.3)),
        SizedBox(width: 8),
        Expanded(child: _buildTextField('日', '', width * 0.3)),
      ],
    );
  }
}
