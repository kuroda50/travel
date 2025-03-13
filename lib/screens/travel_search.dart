import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // FilteringTextInputFormatter をインポート
import 'package:go_router/go_router.dart';
import 'package:travel/colors/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:travel/functions/function.dart';

class TravelSearch extends StatefulWidget {
  @override
  _TravelSearchState createState() => _TravelSearchState();
}

class _TravelSearchState extends State<TravelSearch> {
  String selectedRegion = 'こだわらない';
  List<String> selectedDestinations = ['こだわらない']; //
  String selectedStartDate = 'こだわらない';
  String selectedEndDate = 'こだわらない';
  List<String> selectedDays = ['こだわらない']; //
  List<String> selectedGenderAttributeHost = ['こだわらない']; //
  List<String> selectedGenderAttributeRecruit = ['こだわらない']; //
  List<String> selectedPaymentMethod = ['こだわらない']; //
  String selectedAgeHost = 'こだわらない〜こだわらない';
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

  int filteredPostsCount = 1571316;

  List<DocumentSnapshot> _allPosts = []; // Firestore から取得した全データ
  List<DocumentSnapshot> _filteredPosts = []; // フィルタ後のデータ
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchAllPosts();
  }

  Future<void> _fetchAllPosts() async {
    QuerySnapshot postsSnapshot =
        await FirebaseFirestore.instance.collection("posts").get();
    setState(() {
      _allPosts = postsSnapshot.docs;
      _filteredPosts = _allPosts; //初回はすべて表示
      filteredPostsCount = _filteredPosts.length;
    });
  }

  void _onSearchChanged() {
    print("検索を呼び出したよ");
    // 既存のタイマーがあればキャンセル
    _debounce?.cancel();

    _debounce = Timer(Duration(microseconds: 500), () {
      setState(() {
        _filteredPosts = _allPosts.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final area = data["where"]["area"];
          final destinations = List<String>.from(data["where"]["destination"]);
          final startDate = data["when"]["startDate"].toDate();
          final endDate = data["when"]["endDate"].toDate();
          final dayOfWeek = data["when"]["dayOfWeek"];
          final targetGroups = data["target"]["targetGroups"];
          final targetAgeMax = data["target"]["ageMax"];
          final targetAgeMin = data["target"]["ageMin"];
          final targetHasPhoto = data["target"]["hasPhoto"];
          final organizerGroup = data["organizer"]["organizerGroup"];
          final organizerAge =
              calculateAge(data["organizer"]["organizerBirthday"].toDate());
          final organizerHasPhoto = data["organizer"]["hasPhoto"];
          final budgetMin = data["budget"]["budgetMin"];
          final budgetMax = data["budget"]["budgetMax"];
          final budgetType = data["budget"]["budgetType"];
          final region = data["meetingPlace"]["region"];
          final departure = data["meetingPlace"]["departure"];
          final tagsData = data["tags"];
          final expire = data["expire"];
          print("エラーはないよ");

          final checkFilter = (selectedRegion == area ||
                  selectedRegion == "こだわらない") &&
              (matchesSearch(selectedDestinations, destinations) ||
                  selectedDestinations[0] == "こだわらない") &&
              (isOverlapping(parseDate(selectedStartDate, true),
                  parseDate(selectedEndDate, false), startDate, endDate)) &&
              (matchesSearch(selectedDays, dayOfWeek) ||
                  selectedDays[0] == 'こだわらない') &&
              (selectedGenderAttributeHost.contains(organizerGroup) ||
                  selectedGenderAttributeHost[0] == 'こだわらない') &&
              (matchesSearch(selectedGenderAttributeRecruit, targetGroups) ||
                  selectedGenderAttributeRecruit[0] == 'こだわらない') &&
              (selectedPaymentMethod.contains(budgetType) ||
                  selectedPaymentMethod[0] == 'こだわらない') &&
              (isAgeHostInRange(selectedAgeHost, organizerAge)) &&
              (isAgeRecruitInRange(
                  selectedAgeRecruit, targetAgeMin, targetAgeMax)) &&
              (selectedMeetingRegion == region ||
                  selectedMeetingRegion == "こだわらない") &&
              (selectedDeparture.contains(departure) ||
                  selectedDeparture[0] == "こだわらない") &&
              (organizerHasPhoto || !isPhotoCheckedHost) &&
              (targetHasPhoto || isPhotoCheckedRecruit) &&
              (isBudgetInRange(selectedBudgetMin, selectedBudgetMax, budgetMin,
                  budgetMax)) &&
              (matchesSearch(tags, tagsData) || tags.isEmpty) &&
              (!expire);

          return checkFilter;
        }).toList();
        filteredPostsCount = _filteredPosts.length;
      });
      print("PostId:${_filteredPosts[0].id}");
    });
  }

  //二つのリストの要素に同じものが一つでも含まれていたらtrueを返す
  bool matchesSearch(
      List<dynamic> conditions, List<dynamic> travelDestinations) {
    return conditions
        .toSet()
        .intersection(travelDestinations.toSet())
        .isNotEmpty;
  }

// (検索開始日 <= 募集終了日) かつ (検索終了日 >= 募集開始日)ならtrue
  bool isOverlapping(DateTime searchStart, DateTime searchEnd,
      DateTime postStart, DateTime postEnd) {
    return searchStart.isBefore(postEnd) && searchEnd.isAfter(postStart);
  }

  DateTime parseDate(String dateStr, bool isStart) {
    if (dateStr == 'こだわらない') {
      return isStart ? DateTime(2000, 1, 1) : DateTime(2100, 12, 31);
    } else {
      return DateFormat("yyyy/MM/dd").parse(dateStr);
    }
  }

  bool isAgeHostInRange(String selectedAge, int Age) {
    List<String> ageRange = selectedAge.split('〜');

    int minAge = ageRange[0] == 'こだわらない' ? 0 : int.parse(ageRange[0]); // 最小年齢
    int maxAge = ageRange[1] == 'こだわらない' ? 100 : int.parse(ageRange[1]); // 最大年齢

    return Age >= minAge && Age <= maxAge;
  }

  bool isAgeRecruitInRange(
      String selectedAge, int? targetAgeMin, int? targetAgeMax) {
    List<String> ageRange = selectedAge.split('〜');
    int selectedAgeMin =
        ageRange[0] == 'こだわらない' ? 0 : int.parse(ageRange[0]); // 最小年齢
    int selectedAgeMax =
        ageRange[1] == 'こだわらない' ? 100 : int.parse(ageRange[1]); // 最大年齢

    targetAgeMin = targetAgeMin ?? 0;
    targetAgeMax = targetAgeMax ?? 100;

    return selectedAgeMax >= targetAgeMin && selectedAgeMin <= targetAgeMax;
  }

  bool isBudgetInRange(String selectedBudgetMin, String selectedBudgetMax,
      int? budgetMin, int? budgetMax) {
    int selectedBudgetMinInt =
        selectedBudgetMin == '' ? 0 : int.parse(selectedBudgetMin);
    int selectedBudgetMaxInt =
        selectedBudgetMax == '' ? 10000 : int.parse(selectedBudgetMax);

    budgetMin = budgetMin ?? 0;
    budgetMax = budgetMax ?? 10000;

    return (selectedBudgetMaxInt >= budgetMin &&
        selectedBudgetMinInt <= budgetMax);
  }

  void resetFilter() {
    setState(() {
      selectedRegion = 'こだわらない';
      selectedDestinations = ['こだわらない'];
      selectedStartDate = 'こだわらない';
      selectedEndDate = 'こだわらない';
      selectedDays = ['こだわらない'];
      selectedGenderAttributeHost = ['こだわらない'];
      selectedGenderAttributeRecruit = ['こだわらない'];
      selectedPaymentMethod = ['こだわらない'];
      selectedAgeHost = 'こだわらない〜こだわらない';
      selectedAgeRecruit = 'こだわらない〜こだわらない';
      selectedMeetingRegion = 'こだわらない';
      selectedDeparture = ['こだわらない'];

      isPhotoCheckedHost = false;
      isPhotoCheckedRecruit = false;

      selectedBudgetMin = '';
      selectedBudgetMax = '';

      tags = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "募集検索",
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
                            '検索条件',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
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
                    _buildListFilterItem(
                        context, '性別、属性', selectedGenderAttributeHost,
                        isGenderAttribute: true, isHost: true),
                    _buildFilterItem(context, '年齢', selectedAgeHost,
                        isAge: true, isHost: true),
                    _buildFilterItem(context, '写真付き', '',
                        isCheckbox: true, isHost: true),
                    // 募集する人
                    _buildSectionTitle('募集する人'),
                    _buildListFilterItem(
                        context, '性別、属性', selectedGenderAttributeRecruit,
                        isGenderAttribute: true, isHost: false),
                    _buildFilterItem(context, '年齢', selectedAgeRecruit,
                        isAge: true, isHost: false),
                    _buildFilterItem(context, '写真付き', '',
                        isCheckbox: true, isHost: false),
                    // お金について
                    _buildSectionTitle('お金について'),
                    _buildBudgetFilterItem(context, '予算'),
                    _buildListFilterItem(
                        context, 'お金の分け方', selectedPaymentMethod,
                        isPaymentMethod: true),
                    // 集合場所
                    _buildSectionTitle('集合場所'),
                    _buildFilterItem(context, '方面', selectedMeetingRegion,
                        isMeetingRegion: true),
                    _buildListFilterItem(context, '出発地', selectedDeparture,
                        isDeparture: true),
                    // タグ
                    _buildSectionTitle('タグ'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tagController,
                            decoration: InputDecoration(
                              hintText: 'タグを入力',
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  tags.add(value);
                                  tagController.clear();
                                });
                                _onSearchChanged();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            if (tagController.text.isNotEmpty) {
                              setState(() {
                                tags.add(tagController.text);
                                tagController.clear();
                              });
                              _onSearchChanged();
                            }
                          },
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8.0,
                      children:
                          tags.map((tag) => Chip(label: Text(tag))).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.search),
                        Text(
                          '$filteredPostsCount個に絞り込み中',
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
                          child: Text('リセット',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColor.mainButtonColor, // ボタンの色を緑に設定
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.push('/recruitment-list',
                                extra: _filteredPosts);
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterItem(BuildContext context, String label, String value,
      {bool isRegion = false,
      bool isDate = false,
      bool isCheckbox = false,
      bool isHost = true,
      bool isAge = false,
      bool isMeetingRegion = false}) {
    return InkWell(
      onTap: () {
        if (isRegion) {
          _showRegionModal(context);
        } else if (isDate) {
          _selectDate(context, label);
        } else if (isCheckbox) {
          setState(() {
            if (isHost) {
              isPhotoCheckedHost = !isPhotoCheckedHost;
            } else {
              isPhotoCheckedRecruit = !isPhotoCheckedRecruit;
            }
            _onSearchChanged();
          });
        } else if (isAge) {
          _showAgeModal(context, isHost);
        } else if (isMeetingRegion) {
          _showMeetingRegionModal(context);
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
    bool isHost = true,
    bool isGenderAttribute = false,
    bool isPaymentMethod = false,
    bool isDeparture = false,
  }) {
    return InkWell(
      onTap: () {
        if (isDestination && selectedRegion != 'こだわらない') {
          _showDestinationModal(context, selectedRegion, (updatedDestination) {
            setState(() {
              values.clear();
              values.addAll(updatedDestination);
            });
            _onSearchChanged();
          });
        } else if (isDay) {
          _showDaysModal(context, (updatedDays) {
            setState(() {
              values.clear();
              values.addAll(updatedDays);
            });
            _onSearchChanged();
          });
        } else if (isGenderAttribute) {
          _showGenderAttributeModal(context, isHost, (updatedGender) {
            setState(() {
              values.clear();
              values.addAll(updatedGender);
            });
            _onSearchChanged();
          });
        } else if (isPaymentMethod) {
          _showPaymentMethodModal(context, (updatedPaymentMethod) {
            setState(() {
              values.clear();
              values.addAll(updatedPaymentMethod);
            });
            _onSearchChanged();
          });
        } else if (isDeparture && selectedMeetingRegion != 'こだわらない') {
          _showDepartureModal(context, selectedMeetingRegion,
              (updatedDeparture) {
            setState(() {
              values.clear();
              values.addAll(updatedDeparture);
            });
            _onSearchChanged();
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
                _onSearchChanged();
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
                _onSearchChanged();
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
                            if (selectedDestinations.contains('こだわらない')) {
                              selectedDestinations.remove('こだわらない');
                            }
                            selectedDestinations.add(destination);
                          } else {
                            selectedDestinations.remove(destination);
                            if (selectedDestinations.isEmpty) {
                              selectedDestinations.add('こだわらない');
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
                          if (selectedDays.contains('こだわらない')) {
                            selectedDays.remove('こだわらない');
                          }
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                          if (selectedDays.isEmpty) {
                            selectedDays.add('こだわらない');
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

  void _showGenderAttributeModal(BuildContext context, bool isHost,
      Function(List<String>) onGenderSelected) {
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
                          setState(() {
                            if (isHost) {
                              selectedGenderAttributeHost =
                                  selectedGenderAttributeHost;
                            } else {
                              selectedGenderAttributeRecruit =
                                  selectedGenderAttributeRecruit;
                            }
                          });
                        },
                        icon: Icon(Icons.arrow_back)),
                    Text('性別、属性',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                for (var gender in genders)
                  CheckboxListTile(
                    title: Text(gender),
                    value: isHost
                        ? selectedGenderAttributeHost.contains(gender)
                        : selectedGenderAttributeRecruit.contains(gender),
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isHost) {
                          //主催者の場合
                          if (isChecked == true) {
                            if (selectedGenderAttributeHost
                                .contains('こだわらない')) {
                              selectedGenderAttributeHost.remove('こだわらない');
                            }
                            selectedGenderAttributeHost.add(gender);
                          } else {
                            selectedGenderAttributeHost.remove(gender);
                            if (selectedGenderAttributeHost.isEmpty) {
                              selectedGenderAttributeHost.add('こだわらない');
                            }
                          }
                          // ソート
                          selectedGenderAttributeHost.sort((a, b) =>
                              genders.indexOf(a).compareTo(genders.indexOf(b)));
                          onGenderSelected(
                              List.from(selectedGenderAttributeHost));
                        } else {
                          //参加者の場合
                          if (isChecked == true) {
                            if (selectedGenderAttributeRecruit
                                .contains('こだわらない')) {
                              selectedGenderAttributeRecruit.remove('こだわらない');
                            }
                            selectedGenderAttributeRecruit.add(gender);
                          } else {
                            selectedGenderAttributeRecruit.remove(gender);
                            if (selectedGenderAttributeRecruit.isEmpty) {
                              selectedGenderAttributeRecruit.add('こだわらない');
                            }
                          }
                          // ソート
                          selectedGenderAttributeRecruit.sort((a, b) =>
                              genders.indexOf(a).compareTo(genders.indexOf(b)));
                          onGenderSelected(
                              List.from(selectedGenderAttributeRecruit));
                        }
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
      BuildContext context, Function(List<String>) onPaymentMethodSelected) {
    List<String> paymentMethods = ['割り勘', '各自自腹', '主催者が多めに出す', '主催者が少な目に出す'];
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
                    Text('お金の分け方',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                for (var paymentMethod in paymentMethods)
                  CheckboxListTile(
                    title: Text(paymentMethod),
                    value: selectedPaymentMethod.contains(paymentMethod),
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          if (selectedPaymentMethod.contains('こだわらない')) {
                            selectedPaymentMethod.remove('こだわらない');
                          }
                          selectedPaymentMethod.add(paymentMethod);
                        } else {
                          selectedPaymentMethod.remove(paymentMethod);
                          if (selectedPaymentMethod.isEmpty) {
                            selectedPaymentMethod.add('こだわらない');
                          }
                        }
                      });
                      selectedPaymentMethod.sort((a, b) => paymentMethods
                          .indexOf(a)
                          .compareTo(paymentMethods.indexOf(b)));
                      onPaymentMethodSelected(List.from(selectedPaymentMethod));
                    },
                  ),
              ],
            ),
          );
        });
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
                    _onSearchChanged();
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
                      selectedDestinations = ['こだわらない'];
                    });
                    Navigator.pop(context);
                    _onSearchChanged();
                  },
                ),
            ],
          ),
        );
      },
    );
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
      _onSearchChanged();
    }
  }
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 0.0, bottom: 4.0),
    child: Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

const Map<String, List<String>> destinationsByArea = {
  "ヨーロッパ": [
    "アイスランド",
    "アイルランド",
    "アゼルバイジャン",
    "アルバニア",
    "アルメニア",
    "アンドラ",
    "イギリス",
    "イタリア",
    "ウクライナ",
    "エストニア",
    "オーストリア",
    "オランダ",
    "ギリシャ",
    "クロアチア",
    "コソボ",
    "サンマリノ",
    "ジョージア",
    "スイス",
    "スウェーデン",
    "スペイン",
    "スロバキア",
    "スロベニア",
    "セルビア",
    "タジキスタン",
    "チェコ",
    "デンマーク",
    "ドイツ",
    "ノルウェー",
    "ハンガリー",
    "フィンランド",
    "フランス",
    "ブルガリア",
    "ベラルーシ",
    "ベルギー",
    "ボスニア・ヘルツェゴビナ",
    "ポルトガル",
    "ポーランド",
    "マケドニア",
    "マルタ",
    "モナコ",
    "モルドバ",
    "モンテネグロ",
    "ラトビア",
    "リトアニア",
    "リヒテンシュタイン",
    "ルクセンブルク",
    "ルーマニア",
    "ロシア"
  ],
  "北中米": [
    "アメリカ",
    "カナダ",
    "メキシコ",
    "バハマ",
    "バルバドス",
    "キューバ",
    "ドミニカ共和国",
    "ハイチ",
    "ジャマイカ",
    "セントクリストファー・ネイビス",
    "セントルシア",
    "セントビンセント・グレナディーン",
    "トリニダード・トバゴ",
    "アンティグア・バーブーダ",
    "ベリーズ",
    "コスタリカ",
    "エルサルバドル",
    "グアテマラ",
    "ホンジュラス",
    "ニカラグア",
    "パナマ"
  ],
  "南米": [
    "アルゼンチン",
    "ボリビア",
    "ブラジル",
    "チリ",
    "コロンビア",
    "エクアドル",
    "ガイアナ",
    "パラグアイ",
    "ペルー",
    "スリナム",
    "ウルグアイ",
    "ベネズエラ"
  ],
  "オセアニア・ハワイ": [
    "オーストラリア",
    "ニュージーランド",
    "フィジー",
    "パプアニューギニア",
    "サモア",
    "ソロモン諸島",
    "トンガ",
    "バヌアツ",
    "ハワイ"
  ],
  "アジア": [
    "アフガニスタン",
    "バングラデシュ",
    "ブータン",
    "ブルネイ",
    "カンボジア",
    "中国",
    "インド",
    "インドネシア",
    "イラン",
    "イラク",
    "イスラエル",
    "ヨルダン",
    "カザフスタン",
    "韓国",
    "クウェート",
    "キルギス",
    "ラオス",
    "レバノン",
    "マレーシア",
    "モルディブ",
    "モンゴル",
    "ミャンマー",
    "ネパール",
    "オマーン",
    "パキスタン",
    "フィリピン",
    "カタール",
    "サウジアラビア",
    "シンガポール",
    "スリランカ",
    "シリア",
    "タジキスタン",
    "タイ",
    "トルクメニスタン",
    "アラブ首長国連邦",
    "ウズベキスタン",
    "ベトナム",
    "イエメン"
  ],
  "日本": [
    "北海道",
    "青森県",
    "岩手県",
    "宮城県",
    "秋田県",
    "山形県",
    "福島県",
    "茨城県",
    "栃木県",
    "群馬県",
    "埼玉県",
    "千葉県",
    "東京都",
    "神奈川県",
    "新潟県",
    "富山県",
    "石川県",
    "福井県",
    "山梨県",
    "長野県",
    "岐阜県",
    "静岡県",
    "愛知県",
    "三重県",
    "滋賀県",
    "京都府",
    "大阪府",
    "兵庫県",
    "奈良県",
    "和歌山県",
    "鳥取県",
    "島根県",
    "岡山県",
    "広島県",
    "山口県",
    "徳島県",
    "香川県",
    "愛媛県",
    "高知県",
    "福岡県",
    "佐賀県",
    "長崎県",
    "熊本県",
    "大分県",
    "宮崎県",
    "鹿児島県",
    "沖縄県"
  ],
  "アフリカ・中東": [
    "アルジェリア",
    "アンゴラ",
    "ベナン",
    "ボツワナ",
    "ブルキナファソ",
    "ブルンジ",
    "カメルーン",
    "カーボベルデ",
    "中央アフリカ共和国",
    "チャド",
    "コモロ",
    "コンゴ共和国",
    "コンゴ民主共和国",
    "ジブチ",
    "エジプト",
    "赤道ギニア",
    "エリトリア",
    "エスワティニ",
    "エチオピア",
    "ガボン",
    "ガンビア",
    "ガーナ",
    "ギニア",
    "ギニアビサウ",
    "コートジボワール",
    "ケニア",
    "レソト",
    "リベリア",
    "リビア",
    "マダガスカル",
    "マラウイ",
    "マリ",
    "モーリタニア",
    "モーリシャス",
    "モロッコ",
    "モザンビーク",
    "ナミビア",
    "ニジェール",
    "ナイジェリア",
    "ルワンダ",
    "サントメ・プリンシペ",
    "セネガル",
    "セーシェル",
    "シエラレオネ",
    "ソマリア",
    "南アフリカ",
    "南スーダン",
    "スーダン",
    "タンザニア",
    "トーゴ",
    "チュニジア",
    "ウガンダ",
    "ザンビア",
    "ジンバブエ",
    "アラブ首長国連邦",
    "サウジアラビア",
    "イエメン",
    "オマーン",
    "カタール",
    "バーレーン",
    "クウェート",
    "イスラエル",
    "ヨルダン",
    "レバノン",
    "シリア",
    "イラク",
    "イラン"
  ]
};
