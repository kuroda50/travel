// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, deprecated_member_use, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/colors/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:travel/places/places.dart';
import 'package:travel/screens/message_room_screen.dart';
import 'travel_search.dart';

class RecruitmentPostScreen extends StatefulWidget {
  const RecruitmentPostScreen({super.key});

  @override
  _RecruitmentPostScreenState createState() => _RecruitmentPostScreenState();
}

class _RecruitmentPostScreenState extends State<RecruitmentPostScreen> {
  String selectedRegion = '入力してください';
  List<String> selectedDestinations = ['入力してください'];
  String selectedStartDate = '入力してください';
  String selectedEndDate = '入力してください';
  List<String> selectedDays = ['入力してください'];
  String selectedGenderAttributeHost = '入力してください';
  List<String> selectedGenderAttributeRecruit = ['入力してください'];
  String selectedPaymentMethod = 'こだわらない';
  String selectedAgeHost = 'こだわらない～こだわらない';
  String selectedAgeRecruit = 'こだわらない〜こだわらない';
  String selectedMeetingRegion = 'こだわらない';
  List<String> selectedDeparture = ['こだわらない']; //

  bool isPhotoCheckedHost = false;
  bool isPhotoCheckedRecruit = false;

  String selectedBudgetMin = '';
  String selectedBudgetMax = '';

  List<String> tags = [];
  TextEditingController tagController = TextEditingController();
  TextEditingController additionalTextController = TextEditingController();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  TravelSearch travelSearch = TravelSearch();

  @override
  void initState() {
    super.initState();
  }

  void resetPost() {
    setState(() {
      selectedRegion = '入力してください';
      selectedDestinations = ['入力してください'];
      selectedStartDate = '入力してください';
      selectedEndDate = '入力してください';
      selectedDays = ['入力してください'];
      selectedGenderAttributeHost = '入力してください';
      selectedGenderAttributeRecruit = ['入力してください'];
      selectedPaymentMethod = 'こだわらない';
      selectedAgeHost = 'こだわらない～こだわらない';
      selectedAgeRecruit = 'こだわらない～こだわらない';
      selectedMeetingRegion = 'こだわらない';
      selectedDeparture = ['こだわらない'];

      isPhotoCheckedHost = false;
      isPhotoCheckedRecruit = false;

      selectedBudgetMin = '';
      selectedBudgetMax = '';

      tags = [];
      titleController.clear();
      descriptionController.clear();
    });
  }

  void addTag() {
    setState(() {
      tags.add(tagController.text);
      tagController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "募集投稿",
            style: TextStyle(
              fontSize: 20,
              color: AppColor.subTextColor,
            ),
          ),
          backgroundColor: AppColor.mainButtonColor,
          actions: FirebaseAuth.instance.currentUser == null
              ? [
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: TextButton(
                      onPressed: () {
                        context.push('/login');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: Text("ログイン",
                          style: TextStyle(color: AppColor.mainTextColor)),
                    ),
                  )
                ]
              : null,
          leading: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: Icon(Icons.arrow_back)),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: <Widget>[
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 145), // 左側のパディングを調整
                          child: Text(
                            '募集概要',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // タグ
                    _buildTaginput(),
                    // どこへ
                    _buildSectionTitle('どこへ'),
                    _buildFilterItem(context, '方面', selectedRegion,
                        isRegion: true),
                    _buildListFilterItem(context, '行き先', selectedDestinations,
                        isDestination: true),
                    // いつ
                    _buildSectionTitle('いつ'),
                    _buildFilterItem(context, 'いつから', selectedStartDate,
                        isDate: true),
                    _buildFilterItem(context, 'いつまで', selectedEndDate,
                        isDate: true),
                    _buildListFilterItem(context, '曜日選択', selectedDays,
                        isDay: true),
                    // 主催者
                    _buildSectionTitle('主催者'),
                    _buildFilterItem(
                        context, '性別、属性', selectedGenderAttributeHost,
                        isGenderAttribute1: true),
                    // 募集する人
                    _buildSectionTitle('募集する人'),
                    _buildListFilterItem(
                        context, '性別、属性', selectedGenderAttributeRecruit,
                        isGenderAttribute2: true),
                    _buildFilterItem(context, '年齢', selectedAgeRecruit,
                        isAge: true, isHost: false),
                    _buildFilterItem(context, '写真付き', '',
                        isCheckbox: true, isHost: false),
                    // お金について
                    _buildSectionTitle('お金について'),
                    _buildBudgetFilterItem(context, '予算'),
                    _buildFilterItem(context, 'お金の分け方', selectedPaymentMethod,
                        isPaymentMethod: true),
                    // 集合場所
                    _buildSectionTitle('集合場所'),
                    _buildFilterItem(context, '方面', selectedMeetingRegion,
                        isMeetingRegion: true),
                    _buildListFilterItem(context, '出発地', selectedDeparture,
                        isDeparture: true),
                    // タイトル
                    _buildSectionTitle('タイトル'),
                    _buildTitleInput(),
                    // 本文
                    _buildSectionTitle('本文'),
                    _buildDescriptionInput(),
                    SizedBox(height: 16),
                    // ボタン
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            resetPost();
                          },
                          child: Text('リセット',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColor.mainButtonColor, // ボタンの色を緑に設定
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await _postToFirestore();
                          },
                          icon: Icon(Icons.send, color: Colors.white),
                          label:
                              Text('投稿', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.mainButtonColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterItem(
    BuildContext context,
    String label,
    String value, {
    bool isRegion = false,
    bool isDate = false,
    bool isCheckbox = false,
    bool isHost = true,
    bool isAge = false,
    bool isMeetingRegion = false,
    bool isPaymentMethod = false,
    bool isGenderAttribute1 = false,
  }) {
    return InkWell(
      onTap: () {
        if (isRegion) {
          _showRegionModal(context);
        } else if (isDate) {
          // _selectDate(context, label);
          selectDate(context, label);
        } else if (isCheckbox) {
          setState(() {
            if (isHost) {
              isPhotoCheckedHost = !isPhotoCheckedHost;
            } else {
              isPhotoCheckedRecruit = !isPhotoCheckedRecruit;
            }
          });
        } else if (isAge) {
          _showAgeModal(context, isHost);
        } else if (isMeetingRegion) {
          _showMeetingRegionModal(context);
        } else if (isPaymentMethod) {
          _showPaymentMethodModal(context, (updatedPaymentMethod) {
            setState(() {
              selectedPaymentMethod = updatedPaymentMethod;
            });
          });
        } else if (isGenderAttribute1) {
          _showGenderAttributeModal1(context, (updatedGender) {
            setState(() {
              selectedGenderAttributeHost = updatedGender;
            });
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(label),
            ),
            if (isCheckbox)
              Icon(
                isHost
                    ? (isPhotoCheckedHost
                        ? Icons.check_box
                        : Icons.check_box_outline_blank)
                    : (isPhotoCheckedRecruit
                        ? Icons.check_box
                        : Icons.check_box_outline_blank),
                color: (isHost ? isPhotoCheckedHost : isPhotoCheckedRecruit)
                    ? Colors.blue
                    : Colors.grey,
              )
            else
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      value,
                    ),
                    Icon(Icons.expand_more),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListFilterItem(
    BuildContext context,
    String label,
    List<String> values, {
    bool isDestination = false,
    bool isDay = false,
    bool isGenderAttribute2 = false,
    bool isDeparture = false,
  }) {
    return InkWell(
      onTap: () {
        if (isDestination && selectedRegion != '入力してください') {
          _showDestinationModal(context, selectedRegion, (updatedDestination) {
            setState(() {
              values.clear();
              values.addAll(updatedDestination);
            });
          });
        } else if (isDay) {
          _showDaysModal(context, (updatedDays) {
            setState(() {
              values.clear();
              values.addAll(updatedDays);
            });
          });
        } else if (isGenderAttribute2) {
          _showGenderAttributeModal2(context, (updatedGender) {
            setState(() {
              values.clear();
              values.addAll(updatedGender);
            });
          });
        } else if (isDeparture && selectedMeetingRegion != 'こだわらない') {
          _showDepartureModal(context, selectedMeetingRegion,
              (updatedDeparture) {
            setState(() {
              values.clear();
              values.addAll(updatedDeparture);
            });
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(label),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      values.join('、'),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Icon(Icons.expand_more),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaginput() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: tagController,
                decoration: InputDecoration(
                  hintText: 'タグを入力',
                ),
                onSubmitted: (value) {
                  addTag();
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                addTag();
              },
            ),
          ],
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8.0,
          children: tags
              .map(
                (tag) => Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() {
                      tags.remove(tag);
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTitleInput() {
    return Column(
      children: [
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: 'タイトルを入力',
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      children: [
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            hintText: '本文を入力',
          ),
          maxLines: 5,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBudgetFilterItem(BuildContext context, String label) {
    return InkWell(
      onTap: () {
        _showBudgetModal(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(label),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: Text(selectedBudgetMin),
                    ),
                  ),
                  Text(' 万円〜 '),
                  Container(
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: Text(selectedBudgetMax),
                    ),
                  ),
                  Text(' 万円'),
                  Icon(Icons.expand_more),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String budgetMin = selectedBudgetMin;
        String budgetMax = selectedBudgetMax;

        return AlertDialog(
          title: Text('予算設定'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '最低予算（万円）'),
                onChanged: (value) {
                  budgetMin = value;
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '最高予算（万円）'),
                onChanged: (value) {
                  budgetMax = value;
                },
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
                setState(() {
                  selectedBudgetMin = budgetMin;
                  selectedBudgetMax = budgetMax;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAgeModal(BuildContext context, bool isHost) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String ageMin = isHost
            ? selectedAgeHost.split('〜')[0] == 'こだわらない'
                ? ''
                : selectedAgeHost.split('〜')[0]
            : selectedAgeRecruit.split('〜')[0] == 'こだわらない'
                ? ''
                : selectedAgeRecruit.split('〜')[0];
        String ageMax = isHost
            ? selectedAgeHost.split('〜')[1] == 'こだわらない'
                ? ''
                : selectedAgeHost.split('〜')[1]
            : selectedAgeRecruit.split('〜')[1] == 'こだわらない'
                ? ''
                : selectedAgeRecruit.split('〜')[1];

        return AlertDialog(
          title: Text('年齢設定'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(labelText: '最低年齢'),
                onChanged: (value) {
                  ageMin = value;
                },
                controller: TextEditingController(text: ageMin),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // 追加
              ),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(labelText: '最高年齢'),
                onChanged: (value) {
                  ageMax = value;
                },
                controller: TextEditingController(text: ageMax),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // 追加
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
                setState(() {
                  if (isHost) {
                    selectedAgeHost = ageMin.isEmpty && ageMax.isEmpty
                        ? 'こだわらない〜こだわらない'
                        : '${ageMin.isEmpty ? 'こだわらない' : ageMin}〜${ageMax.isEmpty ? 'こだわらない' : ageMax}';
                  } else {
                    selectedAgeRecruit = ageMin.isEmpty && ageMax.isEmpty
                        ? 'こだわらない〜こだわらない'
                        : '${ageMin.isEmpty ? 'こだわらない' : ageMin}〜${ageMax.isEmpty ? 'こだわらない' : ageMax}';
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showDestinationModal(BuildContext context, String region,
      Function(List<String>) onDestinationSelected) {
    List<String> destinations = destinationsByArea[region] ?? [];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back)),
                      Text('行き先',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  for (var destination in destinations)
                    CheckboxListTile(
                      title: Text(destination),
                      value: selectedDestinations.contains(destination),
                      onChanged: (bool? isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            if (selectedDestinations.contains('入力してください')) {
                              selectedDestinations.remove('入力してください');
                            }
                            selectedDestinations.add(destination);
                          } else {
                            selectedDestinations.remove(destination);
                            if (selectedDestinations.isEmpty) {
                              selectedDestinations.add('入力してください');
                            }
                          }
                        });
                        onDestinationSelected(List.from(selectedDestinations));
                      },
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showDaysModal(
      BuildContext context, Function(List<String>) onDaysSelected) {
    // 曜日の並び順を定義
    List<String> days = ['月', '火', '水', '木', '金', '土', '日'];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back)),
                    Text('曜日',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                for (var day in days)
                  CheckboxListTile(
                    title: Text(day),
                    value: selectedDays.contains(day),
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          if (selectedDays.contains('入力してください')) {
                            selectedDays.remove('入力してください');
                          }
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                          if (selectedDays.isEmpty) {
                            selectedDays.add('入力してください');
                          }
                        }
                      });
                      // days のインデックスを基準にソート
                      selectedDays.sort(
                          (a, b) => days.indexOf(a).compareTo(days.indexOf(b)));
                      onDaysSelected(List.from(selectedDays));
                    },
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showGenderAttributeModal1(
      BuildContext context, Function(String) onGenderSelected) {
    List<String> genders = ['男性', '女性', '家族', 'グループ'];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back)),
                  Text('主催者の性別、属性',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 16),
              for (var gender in genders)
                ListTile(
                  title: Text(gender),
                  onTap: () {
                    setState(() {
                      selectedGenderAttributeHost = gender;
                    });
                    onGenderSelected(gender);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showGenderAttributeModal2(
      BuildContext context, Function(List<String>) onGenderSelected) {
    List<String> genders = ['男性', '女性', '家族', 'グループ'];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back)),
                    Text('募集する人の性別、属性',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                for (var gender in genders)
                  CheckboxListTile(
                    title: Text(gender),
                    value: selectedGenderAttributeRecruit.contains(gender),
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          if (selectedGenderAttributeRecruit
                              .contains('入力してください')) {
                            selectedGenderAttributeRecruit.remove('入力してください');
                          }
                          selectedGenderAttributeRecruit.add(gender);
                        } else {
                          selectedGenderAttributeRecruit.remove(gender);
                          if (selectedGenderAttributeRecruit.isEmpty) {
                            selectedGenderAttributeRecruit.add('入力してください');
                          }
                        }
                        selectedGenderAttributeRecruit.sort((a, b) =>
                            genders.indexOf(a).compareTo(genders.indexOf(b)));
                        onGenderSelected(
                            List.from(selectedGenderAttributeRecruit));
                      });
                    },
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showPaymentMethodModal(
      BuildContext context, Function(String) onPaymentMethodSelected) {
    List<String> paymentMethods = [
      'こだわらない',
      '割り勘',
      '各自自腹',
      '主催者が多めに出す',
      '主催者が少な目に出す'
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back)),
                  Text('お金の分け方',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 16),
              for (var paymentMethod in paymentMethods)
                ListTile(
                  title: Text(paymentMethod),
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = paymentMethod;
                    });
                    onPaymentMethodSelected(paymentMethod);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDepartureModal(BuildContext context, String region,
      Function(List<String>) onDepartureSelected) {
    List<String> destinations = destinationsByArea[region] ?? [];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedDestinations = selectedDestinations;
                            });
                          },
                          icon: Icon(Icons.arrow_back)),
                      Text('出発地',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  for (var destination in destinations)
                    CheckboxListTile(
                      title: Text(destination),
                      value: selectedDeparture.contains(destination),
                      onChanged: (bool? isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            if (selectedDeparture.contains('こだわらない')) {
                              selectedDeparture.remove('こだわらない');
                            }
                            selectedDeparture.add(destination);
                          } else {
                            selectedDeparture.remove(destination);
                            if (selectedDeparture.isEmpty) {
                              selectedDeparture.add('こだわらない');
                            }
                          }
                        });
                        onDepartureSelected(List.from(selectedDeparture));
                      },
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showMeetingRegionModal(BuildContext context) {
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
              for (var region in destinationsByArea.keys)
                ListTile(
                  title: Text(region),
                  onTap: () {
                    setState(() {
                      selectedMeetingRegion = region;
                      selectedDeparture = ['こだわらない'];
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showRegionModal(BuildContext context) {
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
              for (var region in destinationsByArea.keys)
                ListTile(
                  title: Text(region),
                  onTap: () {
                    setState(() {
                      selectedRegion = region;
                      selectedDestinations = ['入力してください'];
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> selectDate(BuildContext context, String label) async {
    DateTime initialTime = DateTime.now();
    if (label == 'いつから' && selectedStartDate != '入力してください') {
      initialTime = DateFormat("yyyy/MM/dd").parse(selectedStartDate);
    } else if (label == 'いつまで' && selectedEndDate != '入力してください') {
      initialTime = DateFormat("yyyy/MM/dd").parse(selectedEndDate);
    }
    DateTime? picked = await showCustomDatePicker(
        context, initialTime, label, selectedStartDate, selectedEndDate);
    setState(() {
      if (picked != null) {
        String formattedDate = DateFormat('yyyy/MM/dd').format(picked);
        if (label == 'いつから') {
          selectedStartDate = formattedDate;
        } else if (label == 'いつまで') {
          selectedEndDate = formattedDate;
        }
      } else {
        if (label == 'いつから') {
          selectedStartDate = '入力してください';
        } else if (label == 'いつまで') {
          selectedEndDate = '入力してください';
        }
      }
    });
  }

  Future<void> _selectDate(BuildContext context, String label) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blueAccent, // アクセントカラー
            colorScheme: ColorScheme.light(primary: Colors.blueAccent),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent, // ボタンの色
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        String formattedDate = DateFormat('yyyy/MM/dd').format(picked);
        if (label == 'いつから') {
          selectedStartDate = formattedDate;
        } else if (label == 'いつまで') {
          selectedEndDate = formattedDate;
        }
      });
    }
  }

  Future<void> _postToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.push('/login');
      return;
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ユーザー情報が取得できませんでした')),
      );
      return;
    }

    final userData = userDoc.data() as Map<String, dynamic>;

    Map<String, String> genderMap = {
      '男性': 'male',
      '女性': 'female',
      '家族': 'family',
      'グループ': 'group'
    };

    Map<String, String> dayMap = {
      '月': 'Mon',
      '火': 'Tue',
      '水': 'Wed',
      '木': 'Thu',
      '金': 'Fri',
      '土': 'Sat',
      '日': 'Sun'
    };

    Map<String, String> paymentMethodMap = {
      'こだわらない': 'null',
      '割り勘': 'splitEvenly',
      '各自自腹': 'eachPays',
      '主催者が多めに出す': 'hostPaysMore',
      '主催者が少な目に出す': 'hostPaysLess'
    };

    // 入力チェック
    if (selectedRegion == '入力してください' ||
        selectedDestinations.contains('入力してください') ||
        selectedStartDate == '入力してください' ||
        selectedEndDate == '入力してください' ||
        selectedDays.contains('入力してください') ||
        selectedGenderAttributeRecruit.contains('入力してください') ||
        selectedGenderAttributeHost.contains('入力してください') ||
        selectedPaymentMethod == '入力してください' ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        tags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("すべての必須項目を入力してください"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ユニークなroomIdを生成
    DocumentReference chatRoomRef =
        FirebaseFirestore.instance.collection("chatRooms").doc();
    String roomId = chatRoomRef.id;

    final postData = {
      "groupChatRoomId": roomId, // ユニークなroomIdを設定
      "participants": [user.uid],
      "where": {
        "area": selectedRegion,
        "destination": selectedDestinations,
      },
      "when": {
        "startDate": Timestamp.fromDate(
            DateFormat('yyyy/MM/dd').parse(selectedStartDate)),
        "endDate":
            Timestamp.fromDate(DateFormat('yyyy/MM/dd').parse(selectedEndDate)),
        "dayOfWeek": selectedDays.map((day) => dayMap[day]!).toList(),
      },
      "target": {
        "targetGroups": selectedGenderAttributeRecruit
            .where((gender) => gender != 'こだわらない')
            .map((gender) => genderMap[gender]!)
            .toList(),
        "ageMax": selectedAgeRecruit.split('〜')[1] == 'こだわらない'
            ? null
            : int.parse(selectedAgeRecruit.split('〜')[1]),
        "ageMin": selectedAgeRecruit.split('〜')[0] == 'こだわらない'
            ? null
            : int.parse(selectedAgeRecruit.split('〜')[0]),
        "hasPhoto": isPhotoCheckedRecruit,
      },
      "organizer": {
        "organizerId": user.uid,
        "organizerGroup": selectedGenderAttributeHost != 'こだわらない'
            ? genderMap[selectedGenderAttributeHost]!
            : null,
        "organizerName": userData['name'],
        "organizerBirthday": userData['birthday'].toDate(),
        "hasPhoto": userData['hasPhoto'],
        "photoURL":
            (userData['photoURLs'] != null && userData['photoURLs'].isNotEmpty)
                ? userData['photoURLs'][0]
                : '',
      },
      "budget": {
        "budgetMin":
            selectedBudgetMin.isEmpty ? null : int.parse(selectedBudgetMin),
        "budgetMax":
            selectedBudgetMax.isEmpty ? null : int.parse(selectedBudgetMax),
        "budgetType": selectedPaymentMethod != 'こだわらない'
            ? paymentMethodMap[selectedPaymentMethod]
            : null,
      },
      "meetingPlace": {
        "region": selectedMeetingRegion,
        "departure":
            selectedDeparture.isNotEmpty && selectedDeparture[0] != 'こだわらない'
                ? selectedDeparture[0]
                : null,
      },
      "title": titleController.text,
      "tags": tags,
      "description": descriptionController.text,
      "createdAt": Timestamp.now(),
      "expire": false,
    };

    try {
      DocumentReference postRef =
          await FirebaseFirestore.instance.collection("posts").add(postData);
      String postId = postRef.id;

      final chatRoomData = {
        "postId": postId,
        "participants": [user.uid],
        "createdAt": Timestamp.now(),
        "latestMessage": {
          "text": "",
          "sender": "",
          "timeStamp": Timestamp.now(),
          "readBy": [],
        }
      };

      await chatRoomRef.set(chatRoomData);

      // ユーザーのchatRoomsとparticipatedPostsを更新
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        "chatRooms": FieldValue.arrayUnion([roomId]),
        "participatedPosts": FieldValue.arrayUnion([postId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('投稿が完了しました')),
      );

      // チャット画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessageRoomScreen(
            roomId: roomId,
            currentUserId: user.uid,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('投稿に失敗しました')),
      );
    }
  }
}
