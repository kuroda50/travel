import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';
import 'package:travel/component/header.dart';

class AccountCreateScreen extends StatefulWidget {
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<AccountCreateScreen> {
  double widthFactor = 1; // フィールドの幅を調整する係数
  double headerHeight = 88; // ヘッダーの縦の大きさ
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender, _genderError, _birthdayError;
  bool isEmailUsed = false;
  DateTime? _birthday;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordCheckController =
      TextEditingController();

  @override
  void dispose() {
    // メモリリークを防ぐためにdispose()で破棄
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordCheckController.dispose();
    super.dispose();
  }

  void printTextField() {
    setState(() {
      _genderError = _selectedGender == null ? '性別を選択してください' : null;
      _birthdayError = (_selectedYear == null ||
              _selectedMonth == null ||
              _selectedDay == null)
          ? '誕生日を選択してください'
          : null;
    });
  }

  void signUp() async {
    try {
      if (_formKey.currentState!.validate() && _genderError == null) {
        _birthday = DateTime(_selectedYear!, _selectedMonth!, _selectedDay!);
        UserCredential credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        String uid = credential.user!.uid;
        await FirebaseFirestore.instance.collection("users").doc(uid).set({
          "photoURLs": [""],
          "hasPhoto": false,
          "name": _nameController.text,
          "gender": _selectedGender,
          "birthday": _birthday,
          "hobbies": [],
          "bio": "",
          "createdAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
          "following": [],
          "followers": [],
          "favoritePosts": [],
          "participatedPosts": [],
          "chatRooms": [],
        });
        context.go('/login');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        setState(() {
          isEmailUsed = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: "アカウント作成",
      ),
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
                    padding: EdgeInsets.all(22),
                    decoration: BoxDecoration(color: Color(0xFF)), //後ろ色
                    child: Container(
                        padding: EdgeInsets.all(19),
                        decoration: BoxDecoration(
                          color: Color(0xFFF9F7F5), //でかい四角の色
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Form(
                          key: _formKey,
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
                              _buildLabeledTextField('name', formWidth),
                              SizedBox(height: 17),
                              _buildGenderSelection(),
                              SizedBox(height: 17),
                              _buildBirthDateFields(formWidth),
                              SizedBox(height: 17),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '電子メール',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                ),
                              ),
                              _buildLabeledTextField(
                                'mail',
                                formWidth,
                              ),
                              SizedBox(height: 17),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'パスワード',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                ),
                              ),
                              _buildLabeledTextField(
                                'password',
                                formWidth,
                              ),
                              SizedBox(height: 17),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'パスワード（確認用）',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                ),
                              ),
                              _buildLabeledTextField(
                                'passwordCheck',
                                formWidth,
                              ),
                              SizedBox(height: 17),
                              ElevatedButton(
                                onPressed: () async {
                                  printTextField();
                                  signUp();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF559900),
                                ),
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
                                          context.push('/terms-of-use');
                                        },
                                    ),
                                    TextSpan(text: ' に同意したものとみなされます'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 各フィールドのパスワード表示状態を管理
  Map<String, bool> isObscuredMap = {
    'password': true,
    'passwordCheck': true,
  };

  Widget _buildLabeledTextField(String textFieldType, double width) {
    return SizedBox(
      width: width * 0.9,
      child: StatefulBuilder(
        builder: (context, setState) {
          return TextFormField(
            controller: textFieldType == 'name'
                ? _nameController
                : textFieldType == 'mail'
                    ? _emailController
                    : textFieldType == 'password'
                        ? _passwordController
                        : _passwordCheckController,
            obscureText: isObscuredMap[textFieldType] ?? false,
            keyboardType: textFieldType == 'mail'
                ? TextInputType.emailAddress
                : TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Color(0xFFE0E0E0)),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              suffixIcon: (textFieldType == 'password' ||
                      textFieldType == 'passwordCheck')
                  ? IconButton(
                      icon: Icon(
                        isObscuredMap[textFieldType]!
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isObscuredMap[textFieldType] =
                              !isObscuredMap[textFieldType]!;
                        });
                      },
                    )
                  : null,
            ),
            validator: (value) {
              switch (textFieldType) {
                case 'name':
                  if (value == null || value.isEmpty) {
                    return '名前を入力してください';
                  }
                  break;
                case 'mail':
                  if (value == null || value.isEmpty) {
                    return 'メールアドレスを入力してください';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return '有効なメールアドレスを入力してください';
                  } else if (isEmailUsed) {
                    return 'このメールアドレスは既に使用されています';
                  }
                  break;
                case 'password':
                  if (value == null || value.isEmpty) {
                    return 'パスワードを入力してください';
                  } else if (value.length < 6 &&
                      !RegExp(r'[a-z]').hasMatch(value) &&
                      !RegExp(r'[0-9]').hasMatch(value)) {
                    return 'パスワードは6文字以上で、\n小文字・数字を含めてください';
                  } else if (value.length < 6 &&
                      !RegExp(r'[A-Z]').hasMatch(value) &&
                      !RegExp(r'[0-9]').hasMatch(value)) {
                    return 'パスワードは6文字以上で、\n大文字・数字を含めてください';
                  } else if (value.length < 6 &&
                      !RegExp(r'[A-Z]').hasMatch(value) &&
                      !RegExp(r'[a-z]').hasMatch(value)) {
                    return 'パスワードは6文字以上で、\n大文字・小文字を含めてください';
                  } else if (value.length < 6 &&
                      !RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'パスワードは6文字以上で、\n大文字を含めてください';
                  } else if (value.length < 6 &&
                      !RegExp(r'[a-z]').hasMatch(value)) {
                    return 'パスワードは6文字以上で、\n小文字を含めてください';
                  } else if (value.length < 6 &&
                      !RegExp(r'[0-9]').hasMatch(value)) {
                    return 'パスワードは6文字以上で、\n数字を含めてください';
                  } else if (value.length < 6) {
                    return 'パスワードは6文字以上にしてください';
                  } else if (value.length < 6 &&
                      (!RegExp(r'[A-Z]').hasMatch(value) ||
                          !RegExp(r'[a-z]').hasMatch(value)) &&
                      !RegExp(r'[0-9]').hasMatch(value)) {
                    return 'パスワードは6文字以上で、\n大文字・小文字・数字を含めてください';
                  } else if (!RegExp(r'[A-Z]').hasMatch(value) &&
                      !RegExp(r'[a-z]').hasMatch(value)) {
                    return 'パスワードは大文字・小文字を含めてください';
                  } else if (!RegExp(r'[A-Z]').hasMatch(value) &&
                      !RegExp(r'[0-9]').hasMatch(value)) {
                    return 'パスワードは大文字・数字を含めてください';
                  } else if (!RegExp(r'[a-z]').hasMatch(value) &&
                      !RegExp(r'[0-9]').hasMatch(value)) {
                    return 'パスワードは小文字・数字を含めてください';
                  } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'パスワードは数字を含めてください';
                  } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'パスワードは大文字を含めてください';
                  } else if (!RegExp(r'[a-z]').hasMatch(value)) {
                    return 'パスワードは小文字を含めてください';
                  }

                  break;
                case 'passwordCheck':
                  if (value == null || value.isEmpty) {
                    return '確認用パスワードを入力してください';
                  } else if (value != _passwordController.text) {
                    return 'パスワードが一致しません';
                  }
                  break;
              }
              return null;
            },
          );
        },
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
        if (_genderError != null) // エラーメッセージを表示
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              _genderError!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

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
                    _birthdayError = null;
                  });
                },
              ),
            ),
          ],
        ),
        if (_birthdayError != null) // エラーメッセージを表示
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              _birthdayError!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        SizedBox(height: 8),
        Text(
          '誕生日は年齢の計算に使用され、他のユーザーには表示されません',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
