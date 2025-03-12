import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // FilteringTextInputFormatter をインポート
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/functions/function.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TravelSearch extends StatefulWidget {
  @override
  _TravelSearchState createState() => _TravelSearchState();
}

class _TravelSearchState extends State<TravelSearch> {
  String selectedRegion = 'こだわらない';
  String selectedDestination = 'こだわらない';
  String selectedStartDate = 'こだわらない';
  String selectedEndDate = 'こだわらない';
  String selectedGenderAttributeHost = 'こだわらない';
  String selectedGenderAttributeRecruit = 'こだわらない';
  String selectedPaymentMethod = '';
  String selectedAgeHost = 'こだわらない〜こだわらない';
  String selectedAgeRecruit = 'こだわらない〜こだわらない';
  String selectedMeetingRegion = '';
  String selectedDeparture = '';

  bool isPhotoCheckedHost = false;
  bool isPhotoCheckedRecruit = false;

  String selectedBudgetMin = '';
  String selectedBudgetMax = '';

  List<String> tags = [];
  TextEditingController tagController = TextEditingController();
  TextEditingController additionalTextController = TextEditingController();

  int filteredPeopleCount = 1571316;

  List<String> latestPostIds = [];
  List<RecruitmentPost> latestPosts = [];

  @override
  void initState() {
    super.initState();
    fetchLatestPosts();
  }

  Future<void> fetchLatestPosts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(4)
        .get();

    latestPostIds = querySnapshot.docs.map((doc) => doc.id).toList();
    latestPosts = await getRecruitmentList(latestPostIds);
    setState(() {});
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
                        // IconButton(
                        //   icon: Icon(Icons.close),
                        //   onPressed: () {
                        //     context.go('/travel'); // '/travel' へ遷移
                        //   },
                        // ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildSectionTitle('どこへ'),
                    _buildFilterItem(context, '方面', selectedRegion,
                        isRegion: true),
                    _buildFilterItem(context, '行き先', selectedDestination,
                        isDestination: true),
                    _buildSectionTitle('いつ'),
                    _buildFilterItem(context, 'いつから', selectedStartDate,
                        isDate: true),
                    _buildFilterItem(context, 'いつまで', selectedEndDate,
                        isDate: true),
                    _buildSectionTitle('主催者'),
                    _buildFilterItem(
                        context, '性別、属性', selectedGenderAttributeHost,
                        isGenderAttribute: true, isHost: true),
                    _buildFilterItem(context, '年齢', selectedAgeHost,
                        isAge: true, isHost: true),
                    _buildFilterItem(context, '写真付き', '',
                        isCheckbox: true, isHost: true),
                    _buildSectionTitle('募集する人'),
                    _buildFilterItem(
                        context, '性別、属性', selectedGenderAttributeRecruit,
                        isGenderAttribute: true, isHost: false),
                    _buildFilterItem(context, '年齢', selectedAgeRecruit,
                        isAge: true, isHost: false),
                    _buildFilterItem(context, '写真付き', '',
                        isCheckbox: true, isHost: false),
                    _buildSectionTitle('お金について'),
                    _buildBudgetFilterItem(context, '予算'),
                    _buildFilterItem(context, 'お金の分け方', selectedPaymentMethod,
                        isPaymentMethod: true),
                    _buildSectionTitle('集合場所'),
                    _buildFilterItem(context, '方面', selectedMeetingRegion,
                        isMeetingRegion: true),
                    _buildFilterItem(context, '出発地', selectedDeparture,
                        isDeparture: true),
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
                          '$filteredPeopleCount人に絞り込み中',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {},
                          child: Text('リセット',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColor.mainButtonColor, // ボタンの色を緑に設定
                          ),
                        ),
                        ElevatedButton.icon(
                          // ElevatedButton.icon を使用
                          onPressed: () {},
                          icon: Icon(Icons.search,
                              color: Colors.white), // 虫眼鏡アイコンを追加
                          label: Text('この条件で検索',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColor.mainButtonColor, // ボタンの色を緑に設定
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
      bool isDestination = false,
      bool isDate = false,
      bool isCheckbox = false,
      bool isHost = true,
      bool isGenderAttribute = false,
      bool isPaymentMethod = false,
      bool isAge = false,
      bool isMeetingRegion = false,
      bool isDeparture = false,
      bool isBudget = false}) {
    return InkWell(
      onTap: isBudget
          ? null
          : () {
              if (isRegion) {
                _showRegionModal(context);
              } else if (isDestination && selectedRegion != 'こだわらない') {
                _showDestinationModal(context, selectedRegion);
              } else if (isDate) {
                _selectDate(context, label);
              } else if (isCheckbox) {
                setState(() {
                  if (isHost) {
                    isPhotoCheckedHost = !isPhotoCheckedHost;
                  } else {
                    isPhotoCheckedRecruit = !isPhotoCheckedRecruit;
                  }
                });
              } else if (isGenderAttribute) {
                _showGenderAttributeModal(context, isHost);
              } else if (isPaymentMethod) {
                _showPaymentMethodModal(context);
              } else if (isAge) {
                _showAgeModal(context, isHost);
              } else if (isMeetingRegion) {
                _showMeetingRegionModal(context);
              } else if (isDeparture && selectedMeetingRegion.isNotEmpty) {
                _showDepartureModal(context, selectedMeetingRegion);
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
                    Text(value),
                    Icon(Icons.expand_more),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestPostsSection() {
    //3の時出た
    return Column(
      children: latestPosts.map((post) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: (post.organizerPhotoURL != null &&
                      post.organizerPhotoURL.isNotEmpty)
                  ? NetworkImage(post.organizerPhotoURL)
                  : null,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(post.title ?? 'タイトルなし'),
                Text('${post.organizerGroup ?? 'グループ不明'} > '
                    '${post.targetGroups ?? '対象不明'} '
                    '${post.targetAgeMin ?? '年齢不明'}歳~${post.targetAgeMax ?? '年齢不明'}歳 '
                    '${post.targetHasPhoto ?? '不明'}'),
                Text(post.destinations?.join('、') ?? '目的地なし'),
                Text(
                    '${post.organizerName ?? '主催者不明'}、${post.organizerAge ?? '年齢不明'}歳'),
                Text('${post.startDate ?? '開始日不明'}~${post.endDate ?? '終了日不明'} '
                    '${post.days?.join('') ?? '日程不明'}')
              ],
            ),
            onTap: () {
              context.push('/recruitment', extra: post.postId);
            },
          ),
        );
      }).toList(),
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
                  Text(' 円〜 '),
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
                  Text(' 円'),
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
                decoration: InputDecoration(labelText: '最低予算（円）'),
                onChanged: (value) {
                  budgetMin = value;
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '最高予算（円）'),
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
                      selectedDeparture = 'こだわらない';
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

  void _showDepartureModal(BuildContext context, String region) {
    List<String> destinations = destinationsByArea[region] ?? [];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('出発地',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                for (var destination in destinations)
                  ListTile(
                    title: Text(destination),
                    onTap: () {
                      setState(() {
                        selectedDestination = destination;
                      });
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGenderAttributeModal(BuildContext context, bool isHost) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '性別、属性',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('男性'),
                onTap: () {
                  setState(() {
                    if (isHost) {
                      selectedGenderAttributeHost = '男性';
                    } else {
                      selectedGenderAttributeRecruit = '男性';
                    }
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('女性'),
                onTap: () {
                  setState(() {
                    if (isHost) {
                      selectedGenderAttributeHost = '女性';
                    } else {
                      selectedGenderAttributeRecruit = '女性';
                    }
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('家族'),
                onTap: () {
                  setState(() {
                    if (isHost) {
                      selectedGenderAttributeHost = '家族';
                    } else {
                      selectedGenderAttributeRecruit = '家族';
                    }
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('グループ'),
                onTap: () {
                  setState(() {
                    if (isHost) {
                      selectedGenderAttributeHost = 'グループ';
                    } else {
                      selectedGenderAttributeRecruit = 'グループ';
                    }
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
                      selectedDestination = 'こだわらない';
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

  void _showDestinationModal(BuildContext context, String region) {
    List<String> destinations = destinationsByArea[region] ?? [];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('行き先',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                for (var destination in destinations)
                  ListTile(
                    title: Text(destination),
                    onTap: () {
                      setState(() {
                        selectedDestination = destination;
                      });
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentMethodModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'お金の分け方',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('割り勘'),
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = '割り勘';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('各自自腹'),
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = '各自自腹';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('主催者が多めに出す'),
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = '主催者が多めに出す';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('主催者が少な目に出す'),
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = '主催者が少な目に出す';
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
    "アイスランド", "アイルランド", "アゼルバイジャン", "アルバニア", "アルメニア", "アンドラ", "イギリス", "イタリア", "ウクライナ",
    "エストニア", "オーストリア", "オランダ", "ギリシャ", "クロアチア", "コソボ", "サンマリノ", "ジョージア", "スイス",
    "スウェーデン", "スペイン", "スロバキア", "スロベニア", "セルビア", "タジキスタン", "チェコ", "デンマーク",
    "ドイツ", "ノルウェー", "ハンガリー", "フィンランド", "フランス", "ブルガリア", "ベラルーシ", "ベルギー",
    "ボスニア・ヘルツェゴビナ", "ポルトガル", "ポーランド", "マケドニア", "マルタ", "モナコ", "モルドバ",
    "モンテネグロ", "ラトビア", "リトアニア", "リヒテンシュタイン", "ルクセンブルク", "ルーマニア", "ロシア"
  ],
  "北中米": [
    "アメリカ", "カナダ", "メキシコ", "バハマ", "バルバドス", "キューバ", "ドミニカ共和国", "ハイチ", "ジャマイカ",
    "セントクリストファー・ネイビス", "セントルシア", "セントビンセント・グレナディーン", "トリニダード・トバゴ",
    "アンティグア・バーブーダ", "ベリーズ", "コスタリカ", "エルサルバドル", "グアテマラ",
    "ホンジュラス", "ニカラグア", "パナマ"
  ],
  "南米": [
    "アルゼンチン", "ボリビア", "ブラジル", "チリ", "コロンビア",
    "エクアドル", "ガイアナ", "パラグアイ", "ペルー", "スリナム", "ウルグアイ", "ベネズエラ"
  ],
  "オセアニア・ハワイ": [
    "オーストラリア", "ニュージーランド", "フィジー", "パプアニューギニア", "サモア",
    "ソロモン諸島", "トンガ", "バヌアツ", "ハワイ"
  ],
  "アジア": [
    "アフガニスタン", "バングラデシュ", "ブータン", "ブルネイ", "カンボジア", "中国", "インド",
    "インドネシア", "イラン", "イラク", "イスラエル",  "ヨルダン", "カザフスタン",
    "韓国", "クウェート", "キルギス", "ラオス", "レバノン", "マレーシア", "モルディブ",
    "モンゴル", "ミャンマー", "ネパール", "オマーン", "パキスタン", "フィリピン", "カタール",
    "サウジアラビア", "シンガポール", "スリランカ", "シリア", "タジキスタン", "タイ",
    "トルクメニスタン", "アラブ首長国連邦", "ウズベキスタン", "ベトナム", "イエメン"
  ],
  "日本": [
    "北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県",
    "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県",
    "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県",
    "三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県",
    "鳥取県", "島根県", "岡山県", "広島県", "山口県",
    "徳島県", "香川県", "愛媛県", "高知県",
    "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"
  ],
  "アフリカ・中東": [
    "アルジェリア", "アンゴラ", "ベナン", "ボツワナ", "ブルキナファソ", "ブルンジ", "カメルーン",
    "カーボベルデ", "中央アフリカ共和国", "チャド", "コモロ", "コンゴ共和国", "コンゴ民主共和国",
    "ジブチ", "エジプト", "赤道ギニア", "エリトリア", "エスワティニ", "エチオピア", "ガボン",
    "ガンビア", "ガーナ", "ギニア", "ギニアビサウ", "コートジボワール", "ケニア", "レソト",
    "リベリア", "リビア", "マダガスカル", "マラウイ", "マリ", "モーリタニア", "モーリシャス",
    "モロッコ", "モザンビーク", "ナミビア", "ニジェール", "ナイジェリア", "ルワンダ",
    "サントメ・プリンシペ", "セネガル", "セーシェル", "シエラレオネ", "ソマリア", "南アフリカ",
    "南スーダン", "スーダン", "タンザニア", "トーゴ", "チュニジア", "ウガンダ", "ザンビア", "ジンバブエ",
    "アラブ首長国連邦", "サウジアラビア", "イエメン", "オマーン", "カタール", "バーレーン",
    "クウェート", "イスラエル", "ヨルダン", "レバノン", "シリア", "イラク", "イラン"
  ]
};
