import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "プロフィール編集",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const EditProfile(),
    );
  }
}

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfleState();
}

class _EditProfleState extends State<EditProfile> {
  DateTime? birthday;
  Gender? selectedGender;
  List<String> selectedHobbies = [];
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _hobbyTextController = TextEditingController();
  final TextEditingController _bioTextController = TextEditingController();

  Future<void> updateUserProfile(String userId, String name, String gender,
      DateTime birthday, List<String> hobbies, String bio) async {
    print(
        "name:$name, gender:$gender, birthday:${birthday.toIso8601String()}, hobbies:${hobbies[0]}, bio:$bio\n");
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "name": name,
      "gender": gender,
      "birthday": birthday,
      "hobbies": hobbies,
      "bio": bio,
      "upadatedAt": FieldValue.serverTimestamp()
    });
    print("更新しました\n");
  }

  String getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    // if (user != null)
    //   return user.uid;
    // else
    //   return "anonymous";
    return "HhaNFyI5x623En8ZtNtK";
  }

  void _updateGender(Gender gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  void updateBirthday(DateTime selectedDate) {
    setState(() {
      birthday = selectedDate;
    });
  }

  void _updateHobbbies(List<String> hobbies) {
    setState(() {
      selectedHobbies = hobbies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "旅へ行こう！",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "プロフィール編集",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Container(
                  width: 300,
                  child: TextField(
                    controller: _nameTextController,
                    decoration: InputDecoration(
                      labelText: 'あなたの名前',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Text("性別"),
                GenderSelectionWidget(onGenderChanged: _updateGender),
                SizedBox(
                  height: 16.0,
                ),
                DatePicker(onBirthdayChanged: updateBirthday),
                SizedBox(height: 8.0),
                Text("生年月日は年齢の計算に使用され、ほかのユーザには表示されません"),
                SizedBox(height: 16.0),
                HobbiesInputField(onHobbiesChanged: _updateHobbbies),
                SizedBox(height: 16.0),
                TextField(
                  controller: _bioTextController,
                  decoration: InputDecoration(
                    labelText: '自己紹介',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                      onPressed: () {
                        String name = _nameTextController.text;
                        String hobby = _hobbyTextController.text;
                        String bio = _bioTextController.text;

                        updateUserProfile(
                            getUserId(),
                            name,
                            selectedGender.toString(),
                            birthday!,
                            selectedHobbies,
                            bio);
                      },
                      child: Text("保存")),
                )
              ],
            ),
          ),
        ));
  }
}

class HobbiesInputField extends StatefulWidget {
  final Function(List<String>) onHobbiesChanged;
  const HobbiesInputField({super.key, required this.onHobbiesChanged});

  @override
  State<HobbiesInputField> createState() => _HobbiesInputFieldState();
}

class _HobbiesInputFieldState extends State<HobbiesInputField> {
  final TextEditingController _hobbiesController = TextEditingController();
  List<String> _hobbies = [];

  void handleSubmitted(String text) {
    if (text.trim().isNotEmpty) {
      setState(() {
        _hobbies.add(text.trim());
        _hobbiesController.clear();
      });
      widget.onHobbiesChanged(_hobbies);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _hobbiesController,
            decoration: InputDecoration(
                hintText: "ここに入力してEnterキーを押す", border: OutlineInputBorder()),
            onSubmitted: handleSubmitted,
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _hobbies.map((hobby) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(hobby, style: TextStyle(fontSize: 16)),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

class DatePicker extends StatefulWidget {
  final Function(DateTime) onBirthdayChanged;

  const DatePicker({super.key, required this.onBirthdayChanged});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  DateTime now = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: now.copyWith(year: now.year - 18),
        firstDate: now.copyWith(year: now.year - 100),
        lastDate: now.copyWith(year: now.year - 18));

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
      widget.onBirthdayChanged(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "生年月日",
              suffixIcon: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

enum Gender { male, female, unknown }

class GenderSelectionWidget extends StatefulWidget {
  final Function(Gender) onGenderChanged;

  const GenderSelectionWidget({super.key, required this.onGenderChanged});

  @override
  State<GenderSelectionWidget> createState() => _GenderSelectionWidgetState();
}

class _GenderSelectionWidgetState extends State<GenderSelectionWidget> {
  Gender? _selectedGender;
  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      children: [
        //女性ボタン
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.female, color: Colors.red),
              SizedBox(
                width: 4,
              ),
              Text("女性")
            ],
          ),
        ),
        //男性ボタン
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(
                Icons.male,
                color: Colors.blue,
              ),
              SizedBox(
                width: 4,
              ),
              Text("男性")
            ],
          ),
        )
      ],
      isSelected: [
        _selectedGender == Gender.female,
        _selectedGender == Gender.male,
      ],
      onPressed: (int index) {
        setState(() {
          if (index == 0)
            _selectedGender = Gender.female;
          else if (index == 1) 
            _selectedGender = Gender.male;

          widget.onGenderChanged(_selectedGender!);
        });
      },
    );
  }
}
