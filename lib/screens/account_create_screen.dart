import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';
import 'package:flutter/gestures.dart'; // gestures ライブラリをインポート
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountCreateScreen extends StatefulWidget {
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<AccountCreateScreen> {
  String? _selectedGender;
  double widthFactor = 1;
  double headerHeight = 88;
  String emailAddress = "";
  String password = "";
  String passwordCheck = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.subBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double formWidth = constraints.maxWidth > 400
              ? 390
              : constraints.maxWidth * widthFactor;

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
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: formWidth,
                    padding: EdgeInsets.all(22),
                    decoration: BoxDecoration(color: Color(0xFF)), //後ろ色
                    child: Container(
                      padding: EdgeInsets.all(19),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9F7F5), //でかい四角の色
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 17),
                          Text('プロフィールを設定しましょう',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87)),
                          SizedBox(height: 17),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '名前',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            ),
                          ),
                          _buildLabeledTextField('あなたの名前', '山田 太郎', formWidth),
                          SizedBox(height: 17),
                          _buildGenderSelection(),
                          SizedBox(height: 17),
                          _buildBirthDateFields(formWidth),
                          SizedBox(height: 17),
                          _buildLabeledTextField(
                              '電子メール', 'example@email.com', formWidth,
                              isEmail: true),
                          SizedBox(height: 17),
                          _buildLabeledTextField(
                              'パスワード', 'example@email.com', formWidth,
                              isPassword: true),
                          SizedBox(height: 17),
                          _buildLabeledTextField(
                              'パスワード（確認用）', 'XXXXXXXX', formWidth,
                              isPasswordCheck: true),
                          SizedBox(height: 17),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                if (password == passwordCheck) {
                                  UserCredential credential = await FirebaseAuth
                                      .instance
                                      .createUserWithEmailAndPassword(
                                    email: emailAddress,
                                    password: password,
                                  );context.go(
                                  '/login'); //Navigator.pushNamed(context, '/terms-of-use');
                            
                                }
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'weak-password') {
                                  print('The password provided is too weak.');
                                } else if (e.code == 'email-already-in-use') {
                                  print(
                                      'The account already exists for that email.');
                                }
                              } catch (e) {
                                print(e);
                              }
                           },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF559900)),
                            child: Text('会員になる',
                                style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                  fontSize: 10, color: Colors.black87),
                              children: [
                                TextSpan(text: '会員になると '),
                                TextSpan(
                                  text: '利用規約',
                                  style: TextStyle(
                                    color: Colors.lightBlue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.black,
                                    decorationThickness: 1.5,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context.go('/terms-of-use');
                                      // Navigator.pushNamed(context, '/\\');
                                    },
                                ),
                                TextSpan(text: ' に同意したものとみなされます'),
                              ],
                            ),
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

  Widget _buildLabeledTextField(String label, String placeholder, double width,
      {bool isEmail = false,
      bool isPassword = false,
      bool isPasswordCheck = false}) {
    return SizedBox(
      width: width * 0.9,
      child: TextField(
        onChanged: (text) {
          setState(() {
            if (isEmail == true) {
              emailAddress = text;
              print("emailaddress:${emailAddress}");
              print("password:${password}");
            } else if (isPassword == true) {
              password = text;
              print("emailaddress:${emailAddress}");
              print("password:${password}");
            } else if (isPasswordCheck == true) {
              passwordCheck = text;
              print("emailaddress:${emailAddress}");
              print("password:${password}");
              print("passwordCheck:${passwordCheck}");
            }
            ;
          });
        },
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFFE0E0E0)), //あな名、電メ、パス、パス確の色
          hintText: placeholder,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        ),
      ),
    );
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
            isSelected: [
              _selectedGender == 'female',
              _selectedGender == 'male'
            ],
            onPressed: (int index) {
              setState(() {
                _selectedGender = index == 0 ? 'female' : 'male';
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
                    Icon(Icons.female, color: Colors.red),
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
      ],
    );
  }
<<<<<<< Updated upstream
<<<<<<< Updated upstream
=======
=======
>>>>>>> Stashed changes

  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedDay;

  List<int> _generateYears() {
    List<int> years = [];
    for (int i = 2007; i >= 1933; i--) {
      years.add(i);
    }
    return years;
  }

  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return 29; // うるう年
      } else {
        return 28;
      }
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    } else {
      return 31;
    }
  }

  Widget _buildBirthDateFields(double width) {
    List<int> years = _generateYears();
    List<int> months = List.generate(12, (index) => index + 1);
    int daysInMonth = 31; // デフォルトは31日
    if (_selectedYear != null && _selectedMonth != null) {
      daysInMonth = _getDaysInMonth(_selectedYear!, _selectedMonth!);
    }
    List<int> days = List.generate(daysInMonth, (index) => index + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '誕生日',
          style: TextStyle(fontSize: 13, color: Colors.black87),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            //// 年
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '年',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
                items: years.map((year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedYear = newValue;
                    // 年が変わったら、日をリセット（うるう年を再計算するため）
                    _selectedDay = null;
                  });
                },
              ),
            ),
            SizedBox(width: 8),

            // 月
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedMonth,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '月',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
                items: months.map((month) {
                  return DropdownMenuItem<int>(
                    value: month,
                    child: Text(month.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedMonth = newValue;
                    // 月が変わったら、日をリセット（日数を再計算するため）
                    _selectedDay = null;
                  });
                },
              ),
            ),
            SizedBox(width: 8),

            // 日
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedDay,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '日',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
                items: days.map((day) {
                  return DropdownMenuItem<int>(
                    value: day,
                    child: Text(day.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedDay = newValue;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          '生年月日は年齢の計算に使用され、他のユーザーには表示されません',
          style: TextStyle(fontSize: 12, color: Color(0xFFE0E0E0)),
        ),
      ],
    );
  }
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
}
