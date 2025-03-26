import 'dart:async';

import 'package:flutter/services.dart'; // FilteringTextInputFormatter をインポート
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/component/header.dart';
import '../colors/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel/functions/function.dart';

class SameHobbyScreen extends StatefulWidget {
  const SameHobbyScreen({super.key});

  @override
  _SameHobbyScreenState createState() => _SameHobbyScreenState();
}

class _SameHobbyScreenState extends State<SameHobbyScreen> {
  final TextEditingController _hobbyController = TextEditingController();
  String ageValue = "こだわらない～こだわらない", genderValue = "誰でも";
  List<String> hobbies = [];
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<DocumentSnapshot> _filteredUsers = [];
  List<DocumentSnapshot> _allUsers = [];
  int filteredUsersCount = 0;
  late Timer _timer;
  Timer? _debounce;

  // final List<String> _imageUrls = [
  //   'https://source.unsplash.com/random/800x600?nature',
  //   'https://source.unsplash.com/random/800x600?city',
  //   'https://source.unsplash.com/random/800x600?technology',
  // ];

  final List<String> _images = [
    'assets/images/baseball.jpg',
    'assets/images/comic.jpeg',
    'assets/images/golf.jpg',
    'assets/images/rice.jpg',
    'assets/images/cycling.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection("users").get();
    setState(() {
      _allUsers = usersSnapshot.docs;
      _filteredUsers = _allUsers; //初回はすべて表示
      filteredUsersCount = _filteredUsers.length;
    });
  }

  void _onSearchChanged() {
    // 既存のタイマーがあればキャンセル
    _debounce?.cancel();

    _debounce = Timer(Duration(microseconds: 500), () {
      setState(() {
        _filteredUsers = _allUsers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final gender = data["gender"];
          final age = calculateAge(data["birthday"].toDate());
          final hobbiesData = List<String>.from(data["hobbies"]);

          final checkFilter =
              (convertGender(genderValue) == gender || genderValue == "誰でも") &&
                  (isAgeInRange(ageValue, age)) &&
                  (matchesSearch(hobbies, hobbiesData) || hobbies.isEmpty);

          return checkFilter;
        }).toList();
        filteredUsersCount = _filteredUsers.length;
      });
    });
  }

  String convertGender(String gender) {
    Map<String, String> genderMap = {
      '男性': 'male',
      '女性': 'female',
      '誰でも': 'unknown'
    };
    return genderMap[gender]!;
  }

  //二つのリストの要素に同じものが一つでも含まれていたらtrueを返す
  bool matchesSearch(
      List<dynamic> conditions, List<dynamic> travelDestinations) {
    return conditions
        .toSet()
        .intersection(travelDestinations.toSet())
        .isNotEmpty;
  }

  bool isAgeInRange(String selectedAge, int Age) {
    List<String> ageRange = selectedAge.split('～');

    int minAge = ageRange[0] == 'こだわらない' ? 0 : int.parse(ageRange[0]); // 最小年齢
    int maxAge =
        ageRange[1] == 'こだわらない' ? 1000 : int.parse(ageRange[1]); // 最大年齢

    return Age >= minAge && Age <= maxAge;
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showAgeModal(BuildContext context, Function(String) onAgeSelected) {
    String ageMin =
        ageValue.split('～')[0] == 'こだわらない' ? '' : ageValue.split('～')[0];
    String ageMax =
        ageValue.split('～')[1] == 'こだわらない' ? '' : ageValue.split('～')[1];
    String errorMessage = ''; // エラーメッセージを格納する変数
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // StatefulBuilderを追加
          builder: (BuildContext context, StateSetter setState) {
            // setStateを追加
            return AlertDialog(
              title: Text('年齢設定'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: false),
                    decoration: InputDecoration(labelText: '最低年齢'),
                    maxLength: 3,
                    onChanged: (value) {
                      ageMin = value;
                    },
                    controller: TextEditingController(text: ageMin),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: false),
                    decoration: InputDecoration(labelText: '最高年齢'),
                    maxLength: 3,
                    onChanged: (value) {
                      ageMax = value;
                    },
                    controller: TextEditingController(text: ageMax),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  if (errorMessage.isNotEmpty) // エラーメッセージがあれば表示
                    Padding(
                      // PaddingでTextFieldとの間隔を調整
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('キャンセル'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    if (ageMin.isNotEmpty &&
                        ageMax.isNotEmpty &&
                        int.parse(ageMin) > int.parse(ageMax)) {
                      setState(() {
                        errorMessage = '最低年齢は最高年齢より低く設定してください';
                      });
                      return; // エラーがある場合は処理を中断
                    }
                    setState(() {
                      ageValue = ageMin.isEmpty && ageMax.isEmpty
                          ? 'こだわらない～こだわらない'
                          : '${ageMin.isEmpty ? 'こだわらない' : ageMin}～${ageMax.isEmpty ? 'こだわらない' : ageMax}';
                    });
                    onAgeSelected(ageValue);
                    _onSearchChanged();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showGenderModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('方面',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              for (var gender in ["男性", "女性", "誰でも"])
                ListTile(
                  title: Text(gender),
                  onTap: () {
                    setState(() {
                      genderValue = gender;
                    });
                    _onSearchChanged();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void addHobbies() {
    setState(() {
      hobbies.add(_hobbyController.text);
      _hobbyController.clear();
    });
  }

  Widget _buildhobbiesinput() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _hobbyController,
                decoration: InputDecoration(
                  hintText: '趣味を入力',
                ),
                onSubmitted: (value) {
                  addHobbies();
                  _onSearchChanged();
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                addHobbies();
                _onSearchChanged();
              },
            ),
          ],
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8.0,
          children: hobbies
              .map(
                (tag) => Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() {
                      hobbies.remove(tag);
                    });
                    _onSearchChanged();
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // void _search() {
  //   GoRouter.of(context).push(
  //     '/account-list',
  //     extra: {
  //       'hobby': _hobbyController.text,
  //       'gender': _selectedGender,
  //       'startAge': _startAge,
  //       'endAge': _endAge,
  //     },
  //   );
  // }

  Future<void> resetFilter() async {
    setState(() {
      ageValue = "こだわらない～こだわらない";
      genderValue = "誰でも";
      hobbies = [];
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(title: "同じ趣味の人を探す"),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                  child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _images.length,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
                        return Image.asset(
                          _images[index],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  // SizedBox(
                  //   height: 200,
                  //   child: PageView.builder(
                  //     controller: _pageController,
                  //     itemCount: _imageUrls.length,
                  //     onPageChanged: (index) =>
                  //         setState(() => _currentPage = index),
                  //     itemBuilder: (context, index) {
                  //       return Image.network(
                  //         _imageUrls[index],
                  //         fit: BoxFit.cover,
                  //       );
                  //     },
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "探す人",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _showGenderModal(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text("性別"),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  genderValue,
                                ),
                                Icon(Icons.expand_more),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _showAgeModal(context, (updatedAge) {
                        setState(() {
                          ageValue = updatedAge;
                        });
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text("年齢"),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  ageValue,
                                ),
                                Icon(Icons.expand_more),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildhobbiesinput(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.search),
                      Text(
                        '$filteredUsersCount人に絞り込み中',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          resetFilter();
                          _onSearchChanged();
                        },
                        child:
                            Text('リセット', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColor.mainButtonColor, // ボタンの色を緑に設定
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          List<String> userIds = [];
                          for (int i = 0; i < filteredUsersCount; i++) {
                            userIds.add(_filteredUsers[i].id);
                          }
                          context.push('/account-list', extra: userIds);
                        },
                        icon: Icon(Icons.search, color: Colors.white),
                        label: Text('この条件で検索',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.mainButtonColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ))
            ],
          ),
        ));
  }
}

class User {
  String userId;
  String gender;
  int age;
  List<String> hobbies;

  User({
    required this.userId,
    required this.gender,
    required this.age,
    required this.hobbies,
  });
}
