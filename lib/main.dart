import 'package:flutter/material.dart';

void main() {
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
  String? selectedYear, selectedMonth, selectedDay;

  @override
  void initState() {
    super.initState();
    selectedYear = "2007";
    selectedMonth = "1月";
    selectedDay = "1日";
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
                    // onChanged: ,
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
                GenderSelectionWidget(),
                //性別選択用のウィジェットを追加
                SizedBox(
                  height: 16.0,
                ),
                Text("誕生日"),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DropdownButton(
                      value: selectedYear,
                      onChanged: (newValue) {
                        setState(() {
                          selectedYear = newValue;
                        });
                      },
                      items: List.generate(2007 - 1933 + 1,
                              (index) => (2007 - index).toString())
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    DropdownButton(
                      value: selectedMonth,
                      onChanged: (newValue) {
                        setState(() {
                          selectedMonth = newValue;
                        });
                      },
                      items: List.generate(
                              12, (index) => (index + 1).toString() + "月")
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    DropdownButton(
                      value: selectedDay,
                      onChanged: (newValue) {
                        setState(() {
                          selectedDay = newValue;
                        });
                      },
                      items: List.generate(
                              31, (index) => (index + 1).toString() + "日")
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )
                  ],
                ),
                SizedBox(height: 8.0),
                Text("生年月日は年齢の計算に使用され、ほかのユーザには表示されません"),
                SizedBox(height: 16.0),
                TextField(
                  // onSubmitted: ,
                  decoration: InputDecoration(
                    labelText: '趣味',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  decoration: InputDecoration(
                    labelText: '自己紹介',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(onPressed: (() {}), child: Text("保存")),
                )
              ],
            ),
          ),
        ));
  }
}

enum Gender { male, female, unknown }

class GenderSelectionWidget extends StatefulWidget {
  const GenderSelectionWidget({super.key});

  @override
  State<GenderSelectionWidget> createState() => _GenderSelectionWidgetState();
}

class _GenderSelectionWidgetState extends State<GenderSelectionWidget> {
  Gender _selectedGender = Gender.female;
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
          else if (index == 1) _selectedGender = Gender.male;
        });
      },
    );
  }
}
