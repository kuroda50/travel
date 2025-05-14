import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/colors/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel/component/header.dart';
import 'dart:async';
import 'package:travel/places/places.dart';
import 'travel_search.dart';

class RecruitmentPostScreen extends StatefulWidget {
  const RecruitmentPostScreen({super.key});

  @override
  _RecruitmentPostScreenState createState() => _RecruitmentPostScreenState();
}

class _RecruitmentPostScreenState extends State<RecruitmentPostScreen> {
  String selectedRegion = '未定';
  List<String> selectedDestinations = ['未定'];
  String selectedStartDate = '未定';
  String selectedEndDate = '未定';
  List<String> selectedDays = ['未定'];
  String selectedGenderAttributeHost = '未定';
  List<String> selectedGenderAttributeRecruit = ['未定'];
  String selectedPaymentMethod = '未定';
  String selectedAgeHost = '未定～未定';
  String selectedAgeRecruit = '未定〜未定';
  String selectedMeetingRegion = '未定';
  List<String> selectedDeparture = ['未定']; //

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
      selectedRegion = '未定';
      selectedDestinations = ['未定'];
      selectedStartDate = '未定';
      selectedEndDate = '未定';
      selectedDays = ['未定'];
      selectedGenderAttributeHost = '未定';
      selectedGenderAttributeRecruit = ['未定'];
      selectedPaymentMethod = '未定';
      selectedAgeHost = '未定～未定';
      selectedAgeRecruit = '未定～未定';
      selectedMeetingRegion = '未定';
      selectedDeparture = ['未定'];

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
        appBar: const Header(title: "募集投稿"),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600, // 🔄 最大600px（スマホ幅に固定）
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: <Widget>[
                    const SizedBox(height: 16),
                    const Row(
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
                    const SizedBox(height: 16),
                    // タグ
                    _buildTaginput(),
                    // どこへ
                    _buildSectionTitle('どこへ(必須)'),
                    _buildFilterItem(context, '方面', selectedRegion,
                        isRegion: true),
                    _buildListFilterItem(context, '行き先', selectedDestinations,
                        isDestination: true),
                    // いつ
                    _buildSectionTitle('いつ(必須)'),
                    _buildFilterItem(context, 'いつから', selectedStartDate,
                        isDate: true),
                    _buildFilterItem(context, 'いつまで', selectedEndDate,
                        isDate: true),
                    _buildListFilterItem(context, '曜日選択', selectedDays,
                        isDay: true),
                    // 主催者
                    _buildSectionTitle('主催者(必須)'),
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
                    _buildBudgetFilterItem(
                        context, '予算', selectedBudgetMin, selectedBudgetMax),
                    _buildFilterItem(context, 'お金の分け方', selectedPaymentMethod,
                        isPaymentMethod: true),
                    // 集合場所
                    _buildSectionTitle('集合場所'),
                    _buildFilterItem(context, '方面', selectedMeetingRegion,
                        isMeetingRegion: true),
                    _buildListFilterItem(context, '出発地', selectedDeparture,
                        isDeparture: true),
                    // タイトル
                    _buildSectionTitle('タイトル(必須)'),
                    _buildTitleInput(),
                    // 本文
                    _buildSectionTitle('本文(必須)'),
                    _buildDescriptionInput(),
                    const SizedBox(height: 16),
                    // ボタン
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            resetPost();
                          },
                          child: const Text('リセット',
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
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: const Text('投稿',
                              style: TextStyle(color: Colors.white)),
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
        ))),
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
          _showAgeModal(context, isHost, (updatedAge) {
            setState(() {
              selectedAgeRecruit = updatedAge;
            });
          });
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
                    const Icon(Icons.expand_more),
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
        if (isDestination && selectedRegion != '未定') {
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
        } else if (isDeparture && selectedMeetingRegion != '未定') {
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
            const SizedBox(
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
                  const Icon(Icons.expand_more),
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
                decoration: const InputDecoration(
                  hintText: 'タグを入力',
                ),
                onSubmitted: (value) {
                  addTag();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                addTag();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
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
          decoration: const InputDecoration(
            hintText: 'タイトルを入力',
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      children: [
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            hintText: '本文を入力',
          ),
          maxLines: 5,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBudgetFilterItem(BuildContext context, String label,
      String selectedBudgetMin, String selectedBudgetMax) {
    return InkWell(
      onTap: () {
        _showBudgetModal(context, (updatedBudgetMin, updatedBudgetMax) {
          setState(() {
            selectedBudgetMin = updatedBudgetMin;
            selectedBudgetMax = updatedBudgetMax;
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
                  const Text(' 万円〜 '),
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
                  const Text(' 万円'),
                  const Icon(Icons.expand_more),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetModal(
      BuildContext context, Function(String, String) onBudgetSelected) {
    String budgetMin = selectedBudgetMin;
    String budgetMax = selectedBudgetMax;
    String errorMessage = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('予算設定'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '最低予算（万円）'),
                  onChanged: (value) {
                    budgetMin = value;
                  },
                  controller: TextEditingController(text: budgetMin),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '最高予算（万円）'),
                  onChanged: (value) {
                    budgetMax = value;
                  },
                  controller: TextEditingController(text: budgetMax),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                if (errorMessage.isNotEmpty) // エラーメッセージがあれば表示
                  Padding(
                    // PaddingでTextFieldとの間隔を調整
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('キャンセル'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  if (budgetMin.isNotEmpty &&
                      budgetMax.isNotEmpty &&
                      int.parse(budgetMin) > int.parse(budgetMax)) {
                    setState(() {
                      errorMessage = '最低予算は最高予算より低く設定してください';
                    });
                    return; // エラーがある場合は処理を中断
                  }
                  setState(() {
                    selectedBudgetMin = budgetMin;
                    selectedBudgetMax = budgetMax;
                  });
                  onBudgetSelected(selectedBudgetMin, selectedBudgetMax);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _showAgeModal(
      BuildContext context, bool isHost, Function(String) onAgeSelected) {
    String ageMin = isHost
        ? selectedAgeHost.split('〜')[0] == '未定'
            ? ''
            : selectedAgeHost.split('〜')[0]
        : selectedAgeRecruit.split('〜')[0] == '未定'
            ? ''
            : selectedAgeRecruit.split('〜')[0];
    String ageMax = isHost
        ? selectedAgeHost.split('〜')[1] == '未定'
            ? ''
            : selectedAgeHost.split('〜')[1]
        : selectedAgeRecruit.split('〜')[1] == '未定'
            ? ''
            : selectedAgeRecruit.split('〜')[1];
    String errorMessage = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('年齢設定'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  decoration: const InputDecoration(labelText: '最低年齢'),
                  maxLength: 3,
                  onChanged: (value) {
                    ageMin = value;
                  },
                  controller: TextEditingController(text: ageMin),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ], // 追加
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  decoration: const InputDecoration(labelText: '最高年齢'),
                  maxLength: 3,
                  onChanged: (value) {
                    ageMax = value;
                  },
                  controller: TextEditingController(text: ageMax),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ], // 追加
                ),
                if (errorMessage.isNotEmpty) // エラーメッセージがあれば表示
                  Padding(
                    // PaddingでTextFieldとの間隔を調整
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('キャンセル'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('OK'),
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
                    if (isHost) {
                      selectedAgeHost = ageMin.isEmpty && ageMax.isEmpty
                          ? '未定〜未定'
                          : '${ageMin.isEmpty ? '未定' : ageMin}〜${ageMax.isEmpty ? '未定' : ageMax}';
                    } else {
                      selectedAgeRecruit = ageMin.isEmpty && ageMax.isEmpty
                          ? '未定〜未定'
                          : '${ageMin.isEmpty ? '未定' : ageMin}〜${ageMax.isEmpty ? '未定' : ageMax}';
                    }
                  });
                  onAgeSelected(selectedAgeRecruit);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            padding: const EdgeInsets.all(16.0),
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
                          icon: const Icon(Icons.arrow_back)),
                      const Text('行き先',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (var destination in destinations)
                    CheckboxListTile(
                      title: Text(destination),
                      value: selectedDestinations.contains(destination),
                      onChanged: (bool? isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            if (selectedDestinations.contains('未定')) {
                              selectedDestinations.remove('未定');
                            }
                            selectedDestinations.add(destination);
                          } else {
                            selectedDestinations.remove(destination);
                            if (selectedDestinations.isEmpty) {
                              selectedDestinations.add('未定');
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back)),
                    const Text('曜日',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                for (var day in days)
                  CheckboxListTile(
                    title: Text(day),
                    value: selectedDays.contains(day),
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          if (selectedDays.contains('未定')) {
                            selectedDays.remove('未定');
                          }
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                          if (selectedDays.isEmpty) {
                            selectedDays.add('未定');
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back)),
                  const Text('主催者の性別、属性',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back)),
                    const Text('募集する人の性別、属性',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                for (var gender in genders)
                  CheckboxListTile(
                    title: Text(gender),
                    value: selectedGenderAttributeRecruit.contains(gender),
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          if (selectedGenderAttributeRecruit.contains('未定')) {
                            selectedGenderAttributeRecruit.remove('未定');
                          }
                          selectedGenderAttributeRecruit.add(gender);
                        } else {
                          selectedGenderAttributeRecruit.remove(gender);
                          if (selectedGenderAttributeRecruit.isEmpty) {
                            selectedGenderAttributeRecruit.add('未定');
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
      '未定',
      '割り勘',
      '各自自腹',
      '主催者が多めに出す',
      '主催者が少なめに出す'
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back)),
                  const Text('お金の分け方',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
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
            padding: const EdgeInsets.all(16.0),
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
                          icon: const Icon(Icons.arrow_back)),
                      const Text('出発地',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (var destination in destinations)
                    CheckboxListTile(
                      title: Text(destination),
                      value: selectedDeparture.contains(destination),
                      onChanged: (bool? isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            if (selectedDeparture.contains('未定')) {
                              selectedDeparture.remove('未定');
                            }
                            selectedDeparture.add(destination);
                          } else {
                            selectedDeparture.remove(destination);
                            if (selectedDeparture.isEmpty) {
                              selectedDeparture.add('未定');
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('方面',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              for (var region in destinationsByArea.keys)
                ListTile(
                  title: Text(region),
                  onTap: () {
                    setState(() {
                      selectedMeetingRegion = region;
                      selectedDeparture = ['未定'];
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('方面',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              for (var region in destinationsByArea.keys)
                ListTile(
                  title: Text(region),
                  onTap: () {
                    setState(() {
                      selectedRegion = region;
                      selectedDestinations = ['未定'];
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
    DateTime initialTime = _getInitialTime(label);
    DateTime? picked = await showCustomDatePicker(
        context, initialTime, label, "未定", selectedStartDate, selectedEndDate);
    _updateSelectedDate(label, picked);
  }

  DateTime _getInitialTime(String label) {
    if (label == 'いつから' && selectedStartDate != '未定') {
      return DateFormat("yyyy/MM/dd").parse(selectedStartDate);
    } else if (label == 'いつまで' && selectedEndDate != '未定') {
      return DateFormat("yyyy/MM/dd").parse(selectedEndDate);
    }
    return DateTime.now();
  }

  void _updateSelectedDate(String label, DateTime? picked) {
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
          selectedStartDate = '未定';
        } else if (label == 'いつまで') {
          selectedEndDate = '未定';
        }
      }
    });
  }

  // Firestoreに投稿する関数
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ユーザー情報が取得できませんでした')));
      return;
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    if (!_validateInputs()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("すべての必須項目を入力してください"), backgroundColor: Colors.red));
      return;
    }

    try {
      String roomId = await _createChatRoom(user.uid, userData);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('投稿が完了しました')));
      context.push('/message-room',
          extra: {"roomId": roomId, "currentUserId": user.uid});
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('投稿に失敗しました')));
    }
  }

// 入力チェック関数
  bool _validateInputs() {
    return selectedRegion != '未定' &&
        !selectedDestinations.contains('未定') &&
        selectedStartDate != '未定' &&
        selectedEndDate != '未定' &&
        !selectedDays.contains('未定') &&
        selectedGenderAttributeHost != '未定' &&
        titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty;
  }

// チャットルームを作成する関数
  Future<String> _createChatRoom(
      String userId, Map<String, dynamic> userData) async {
    DocumentReference chatRoomRef =
        FirebaseFirestore.instance.collection("chatRooms").doc();
    String roomId = chatRoomRef.id;

    final postData = _preparePostData(userId, userData, roomId);
    DocumentReference postRef =
        await FirebaseFirestore.instance.collection("posts").add(postData);
    String postId = postRef.id;

    final chatRoomData = {
      "postId": postId,
      "postTitle": titleController.text,
      "participants": [userId],
      "createdAt": Timestamp.now(),
      "group": true,
      "latestMessage": {
        "text": "",
        "sender": "",
        "timeStamp": DateTime.now(),
        "readBy": []
      }
    };

    await chatRoomRef.set(chatRoomData);
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      "chatRooms": FieldValue.arrayUnion([roomId]),
      "participatedPosts": FieldValue.arrayUnion([postId]),
    });

    return roomId;
  }

// 投稿データを準備する関数
  Map<String, dynamic> _preparePostData(
      String userId, Map<String, dynamic> userData, String roomId) {
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
      '未定': 'null',
      '割り勘': 'splitEvenly',
      '各自自腹': 'eachPays',
      '主催者が多めに出す': 'hostPaysMore',
      '主催者が少なめに出す': 'hostPaysLess'
    };

    return {
      "groupChatRoomId": roomId,
      "participants": [userId],
      "where": {"area": selectedRegion, "destination": selectedDestinations},
      "when": {
        "startDate": Timestamp.fromDate(
            DateFormat('yyyy/MM/dd').parse(selectedStartDate)),
        "endDate":
            Timestamp.fromDate(DateFormat('yyyy/MM/dd').parse(selectedEndDate)),
        "dayOfWeek": selectedDays.map((day) => dayMap[day]!).toList(),
      },
      "target": {
        "targetGroups": selectedGenderAttributeRecruit
            .where((gender) => gender != '未定')
            .map((gender) => genderMap[gender]!)
            .toList(),
        "ageMax": selectedAgeRecruit.split('〜')[1] == '未定'
            ? null
            : int.parse(selectedAgeRecruit.split('〜')[1]),
        "ageMin": selectedAgeRecruit.split('〜')[0] == '未定'
            ? null
            : int.parse(selectedAgeRecruit.split('〜')[0]),
        "hasPhoto": isPhotoCheckedRecruit,
      },
      "organizer": {
        "organizerId": userId,
        "organizerGroup": selectedGenderAttributeHost != '未定'
            ? genderMap[selectedGenderAttributeHost]!
            : null,
      },
      "budget": {
        "budgetMin":
            selectedBudgetMin.isEmpty ? null : int.parse(selectedBudgetMin),
        "budgetMax":
            selectedBudgetMax.isEmpty ? null : int.parse(selectedBudgetMax),
        "budgetType": selectedPaymentMethod != '未定'
            ? paymentMethodMap[selectedPaymentMethod]
            : null,
      },
      "meetingPlace": {
        "region": selectedMeetingRegion,
        "departure":
            selectedDeparture.isNotEmpty && selectedDeparture[0] != '未定'
                ? selectedDeparture[0]
                : null,
      },
      "title": titleController.text,
      "tags": tags,
      "description": descriptionController.text,
      "createdAt": Timestamp.now(),
      "expire": false,
      "isDeleted": false,
    };
  }
}
