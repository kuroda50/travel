import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class RecruitmentPostScreen extends StatefulWidget {
  const RecruitmentPostScreen({super.key});

  @override
  _RecruitmentPostScreenState createState() => _RecruitmentPostScreenState();
}

class _RecruitmentPostScreenState extends State<RecruitmentPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String? _selectedArea;
  List<String> _selectedDestinations = [];
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedTargetGroups = []; // 複数選択可能に変更
  int? _ageMin;
  int? _ageMax;
  bool _hasPhoto = false;
  String? _selectedOrganizerGroup;
  String? _selectedBudgetType;
  int? _budgetMin;
  int? _budgetMax;
  String? _selectedMeetingRegion;
  String? _selectedMeetingDeparture;
  List<String> _tags = [];
  String? _selectedTag;

  final List<String> _areas = ['アジア', 'ヨーロッパ', '北中米', '南米', 'オセアニア・ハワイ', '日本', 'アフリカ・中東'];
  final Map<String, List<String>> destinationsByArea = {
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
      "ポーランド",
      "ボスニア・ヘルツェゴビナ",
      "ポルトガル",
      "北マケドニア",
      "モナコ",
      "モルドバ",
      "モンテネグロ",
      "ラトビア",
      "リトアニア",
      "リヒテンシュタイン",
      "ルーマニア",
      "ルクセンブルク",
      "ロシア",
    ],
    "アジア": [
      "インド",
      "インドネシア",
      "ウズベキスタン",
      "カザフスタン",
      "カンボジア",
      "キルギス",
      "シンガポール",
      "スリランカ",
      "タイ",
      "タジキスタン",
      "トルクメニスタン",
      "ネパール",
      "パキスタン",
      "バングラデシュ",
      "フィリピン",
      "ブータン",
      "ブルネイ",
      "ベトナム",
      "マレーシア",
      "ミャンマー",
      "モルディブ",
      "モンゴル",
      "ラオス",
      "韓国",
      "中国",
      "台湾",
      "日本",
      "香港",
      "マカオ",
    ],
    "北中米": [
      "アメリカ合衆国",
      "アンティグア・バーブーダ",
      "エルサルバドル",
      "カナダ",
      "キューバ",
      "グアテマラ",
      "グレナダ",
      "コスタリカ",
      "ジャマイカ",
      "セントクリストファー・ネーヴィス",
      "セントビンセント・グレナディーン",
      "セントルシア",
      "ドミニカ国",
      "ドミニカ共和国",
      "トリニダード・トバゴ",
      "ニカラグア",
      "ハイチ",
      "バハマ",
      "パナマ",
      "バルバドス",
      "ベリーズ",
      "ホンジュラス",
      "メキシコ",
    ],
    "南米": [
      "アルゼンチン",
      "ウルグアイ",
      "エクアドル",
      "ガイアナ",
      "コロンビア",
      "スリナム",
      "チリ",
      "パラグアイ",
      "ブラジル",
      "ベネズエラ",
      "ペルー",
      "ボリビア",
    ],
    "オセアニア・ハワイ": [
      "オーストラリア",
      "キリバス",
      "クック諸島",
      "サモア",
      "ソロモン諸島",
      "ツバル",
      "トンガ",
      "ナウル",
      "ニュージーランド",
      "バヌアツ",
      "パラオ",
      "パプアニューギニア",
      "フィジー",
      "マーシャル諸島",
      "ミクロネシア",
      "ハワイ",
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
      "沖縄県",
    ],
    "アフリカ・中東": [
      "アルジェリア",
      "アラブ首長国連邦",
      "イスラエル",
      "イラク",
      "イラン",
      "ウガンダ",
      "エジプト",
      "エチオピア",
      "ガーナ",
      "カタール",
      "カメルーン",
      "ガボン",
      "ガンビア",
      "ギニア",
      "ギニアビサウ",
      "ケニア",
      "コートジボワール",
      "コンゴ共和国",
      "コンゴ民主共和国",
      "サウジアラビア",
      "ザンビア",
      "シエラレオネ",
      "ジブチ",
      "ジンバブエ",
      "スーダン",
      "スワジランド",
      "セーシェル",
      "セネガル",
      "ソマリア",
      "タンザニア",
      "チャド",
      "中央アフリカ共和国",
      "チュニジア",
      "トーゴ",
      "ナイジェリア",
      "ナミビア",
      "ニジェール",
      "ブルキナファソ",
      "ブルンジ",
      "ベナン",
      "ボツワナ",
      "マダガスカル",
      "マラウイ",
      "マリ",
      "南アフリカ",
      "南スーダン",
      "モーリシャス",
      "モーリタニア",
      "モザンビーク",
      "モロッコ",
      "リビア",
      "リベリア",
      "ルワンダ",
      "レソト",
      "レバノン",
      "アフガニスタン",
      "イエメン",
      "オマーン",
      "クウェート",
      "シリア",
      "トルコ",
      "バーレーン",
      "ヨルダン",
      "レバノン",
    ],
  };
  final List<String> _targetGroups = ['男', '女', 'その他', 'グループ'];
  final Map<String, String> _targetGroupMap = {
    '男': 'male',
    '女': 'female',
    'その他': 'others',
    'グループ': 'group',
  };
  final List<String> _budgetTypes = ['splitEvenly', 'individual'];

  // 1. 曜日を選択するためのリストとマップを追加
  final List<String> _daysOfWeek = ['月', '火', '水', '木', '金', '土', '日'];
  final Map<String, String> _daysOfWeekMap = {
    '月': 'Mon',
    '火': 'Tue',
    '水': 'Wed',
    '木': 'Thu',
    '金': 'Fri',
    '土': 'Sat',
    '日': 'Sun',
  };
  List<String> _selectedDaysOfWeek = [];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // ユーザー情報を取得
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        final postData = {
          'tags': _tagsController.text.split(','),
          'where': {
            'area': _selectedArea,
            'destination': _selectedDestinations,
          },
          'when': {
          'startDate': _startDate != null ? Timestamp.fromDate(_startDate!) : null,
          'endDate': _endDate != null ? Timestamp.fromDate(_endDate!) : null,
          'dayOfWeek': _selectedDaysOfWeek,
          },
          'target': {
            'targetGroups': _selectedTargetGroups,
            'ageMin': _ageMin,
            'ageMax': _ageMax,
            'hasPhoto': _hasPhoto,
          },
          'organizer': {
            'organizerId': user.uid,
            'organizerGroup': _selectedOrganizerGroup,
            'organizerName': userData['name'],
            'organizerBirthday': userData['birthday'],
            'hasPhoto': userData['hasPhoto'],
            'photoURL': userData['photoURL'],
          },
          'budget': {
            'budgetMin': _budgetMin,
            'budgetMax': _budgetMax,
            'budgetType': _selectedBudgetType,
          },
          'meetingPlace': {
            'region': _selectedMeetingRegion,
            'departure': _selectedMeetingDeparture,
          },
          'title': _titleController.text,
          'description': _descriptionController.text,
          'createdAt': Timestamp.now(),
          'expire': false,
        };

        await FirebaseFirestore.instance.collection('posts').add(postData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投稿が完了しました')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ユーザー情報が取得できませんでした')),
        );
      }
    }
  }

  void _showAreaModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('方面',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                for (var area in _areas)
                  ListTile(
                    title: Text(area),
                    onTap: () {
                      setState(() {
                        _selectedArea = area;
                        _selectedDestinations = []; // エリア選択時に行き先をリセット
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDestinationModal(BuildContext context) {
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              for (var destination in destinationsByArea[_selectedArea] ?? [])
                CheckboxListTile(
                  title: Text(destination),
                  value: _selectedDestinations.contains(destination),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedDestinations.add(destination);
                      } else {
                        _selectedDestinations.remove(destination);
                      }
                    });
                  },
                ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  setState(() {}); // 状態を更新して選択された行き先を表示
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

  void _showTargetGroupModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('性別、属性',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    for (var group in _targetGroups)
                      CheckboxListTile(
                        title: Text(group),
                        value: _selectedTargetGroups.contains(_targetGroupMap[group]),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedTargetGroups.add(_targetGroupMap[group]!);
                            } else {
                              _selectedTargetGroups.remove(_targetGroupMap[group]);
                            }
                          });
                        },
                      ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      child: Text('OK'),
                      onPressed: () {
                        setState(() {}); // 状態を更新して選択された性別を表示
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showOrganizerGroupModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('性別、属性',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                for (var group in _targetGroups)
                  ListTile(
                    title: Text(group),
                    onTap: () {
                      setState(() {
                        _selectedOrganizerGroup = _targetGroupMap[group];
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

  void _showBudgetTypeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('お金の分け方',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                for (var type in _budgetTypes)
                  ListTile(
                    title: Text(type),
                    onTap: () {
                      setState(() {
                        _selectedBudgetType = type;
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

 void _showMeetingRegionModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('方面',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              for (var area in _areas)
                ListTile(
                  title: Text(area),
                  onTap: () {
                    setState(() {
                      _selectedMeetingRegion = area;
                      _selectedMeetingDeparture = null; // エリア選択時に行き先をリセット
                    });
                    Navigator.pop(context);
                    _showMeetingDepartureModal(context); // エリア選択後に行き先選択モーダルを表示
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

void _showMeetingDepartureModal(BuildContext context) {
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              for (var destination in destinationsByArea[_selectedMeetingRegion] ?? [])
                ListTile(
                  title: Text(destination),
                  onTap: () {
                    setState(() {
                      _selectedMeetingDeparture = destination;
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

  void _showAgeModal(BuildContext context, bool isTarget) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String ageMin = _ageMin?.toString() ?? '';
        String ageMax = _ageMax?.toString() ?? '';

        return AlertDialog(
          title: Text('年齢設定'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '最低年齢'),
                onChanged: (value) {
                  ageMin = value;
                },
                controller: TextEditingController(text: ageMin),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '最高年齢'),
                onChanged: (value) {
                  ageMax = value;
                },
                controller: TextEditingController(text: ageMax),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  _ageMin = int.tryParse(ageMin);
                  _ageMax = int.tryParse(ageMax);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, String label) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (label == 'いつから') {
          _startDate = picked;
        } else if (label == 'いつまで') {
          _endDate = picked;
        }
      });
    }
  }

  // 2. 曜日を選択するためのモーダルを変更
  void _showDayOfWeekModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('曜日',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    for (var day in _daysOfWeek)
                      CheckboxListTile(
                        title: Text(day),
                        value: _selectedDaysOfWeek.contains(_daysOfWeekMap[day]),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (!_selectedDaysOfWeek.contains(_daysOfWeekMap[day])) {
                                _selectedDaysOfWeek.add(_daysOfWeekMap[day]!);
                              }
                            } else {
                              _selectedDaysOfWeek.remove(_daysOfWeekMap[day]);
                            }
                          });
                        },
                      ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      child: Text('OK'),
                      onPressed: () {
                        setState(() {}); // 状態を更新して選択された曜日を表示
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 3. _buildFilterItem メソッド内の曜日選択を変更
  Widget _buildFilterItem(
    BuildContext context, String label, String? selectedValue,
    {bool isRegion = false,
    bool isDestination = false,
    bool isDate = false,
    bool isGenderAttribute = false,
    bool isHost = false,
    bool isAge = false,
    bool isCheckbox = false,
    bool isPaymentMethod = false,
    bool isMeetingRegion = false,
    bool isDeparture = false,
    bool isDayOfWeek = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0.0), // 上下に8.0の間隔を追加
    child: InkWell(
      onTap: () {
        if (isRegion) {
          _showAreaModal(context);
        } else if (isDestination) {
          _showDestinationModal(context);
        } else if (isDate) {
          _selectDate(context, label);
        } else if (isGenderAttribute) {
          if (isHost) {
            _showOrganizerGroupModal(context);
          } else {
            _showTargetGroupModal(context);
          }
        } else if (isAge) {
          _showAgeModal(context, !isHost);
        } else if (isCheckbox) {
          setState(() {
            _hasPhoto = !_hasPhoto;
          });
        } else if (isPaymentMethod) {
          _showBudgetTypeModal(context);
        } else if (isMeetingRegion) {
          _showMeetingRegionModal(context);
        } else if (isDeparture) {
          _showMeetingDepartureModal(context);
        } else if (isDayOfWeek) {
          _showDayOfWeekModal(context);
        }
      },
      child: Container(
        width: double.infinity, // ボタンの判定領域を右端から左端まで広げる
        padding: EdgeInsets.symmetric(vertical: 10.0), // 縦幅を小さくするためのパディング
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            if (isCheckbox)
              Checkbox(
                value: _hasPhoto,
                onChanged: (bool? value) {
                  setState(() {
                    _hasPhoto = value ?? false;
                  });
                },
              )
            else if (isDayOfWeek)
              Text(_selectedDaysOfWeek.isNotEmpty
                  ? _selectedDaysOfWeek.map((day) => _daysOfWeek.firstWhere((key) => _daysOfWeekMap[key] == day)).join(', ')
                  : '選択してください')
            else if (isDestination)
              Text(_selectedDestinations.isNotEmpty
                  ? _selectedDestinations.join(', ')
                  : '選択してください')
            else if (isGenderAttribute && !isHost)
              Text(_selectedTargetGroups.isNotEmpty
                  ? _selectedTargetGroups.map((group) => _targetGroups.firstWhere((key) => _targetGroupMap[key] == group)).join(', ')
                  : '選択してください')
            else
              Text(selectedValue ?? '選択してください'),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildBudgetFilterItem(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0), // 上下に8.0の間隔を追加
      child: InkWell(
        onTap: () {
          _showBudgetModal(context);
        },
        child: Container(
          width: double.infinity, // ボタンの判定領域を右端から左端まで広げる
          padding: EdgeInsets.symmetric(vertical: 10.0), // 縦幅を小さくするためのパディング
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Row(
                children: [
                  Text(_budgetMin != null ? '$_budgetMin 万円' : 'こだわらない'),
                  Text(' 〜 '),
                  Text(_budgetMax != null ? '$_budgetMax 万円' : 'こだわらない'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String budgetMin = _budgetMin?.toString() ?? '';
        String budgetMax = _budgetMax?.toString() ?? '';

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
                controller: TextEditingController(text: budgetMin),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '最高予算（万円）'),
                onChanged: (value) {
                  budgetMax = value;
                },
                controller: TextEditingController(text: budgetMax),
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
                  _budgetMin = int.tryParse(budgetMin);
                  _budgetMax = int.tryParse(budgetMax);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addTag() {
    if (_tagsController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagsController.text);
        _tagsController.clear();
      });
    }
  }

  void _toggleTagSelection(String tag) {
    setState(() {
      if (_selectedTag == tag) {
        _tags.remove(tag);
        _selectedTag = null;
      } else {
        _selectedTag = tag;
      }
    });
  }

  // 4. build メソッド内に曜日選択の項目を追加
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('募集投稿'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'タグ',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addTag,
                  ),
                ],
              ),
              SizedBox(height: 8), // タグ入力欄とタグ表示の間に間隔を追加
              Wrap(
                children: _tags.map((tag) {
                  final isSelected = _selectedTag == tag;
                  return GestureDetector(
                    onTap: () => _toggleTagSelection(tag),
                    child: Chip(
                      label: Text(tag),
                      backgroundColor: isSelected ? Colors.blue.shade100 : null,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: isSelected ? Colors.blue : Colors.grey,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              _buildSectionTitle('どこへ'),
              Padding(
                padding: const EdgeInsets.only(left: 10.0), // 字下げ10
                child: Column(
                  children: [
                    _buildFilterItem(context, '方面', _selectedArea,
                        isRegion: true),
                    _buildFilterItem(context, '行き先', _selectedDestinations.join(', '),
                        isDestination: true),
                  ],
                ),
              ),
              _buildSectionTitle('いつ'),
              Padding(
                padding: const EdgeInsets.only(left: 10.0), // 字下げ10
                child: Column(
                  children: [
                    _buildFilterItem(
                      context,
                      'いつから',
                      _startDate != null
                          ? DateFormat('yyyy/MM/dd').format(_startDate!)
                          : '',
                      isDate: true,
                    ),
                    _buildFilterItem(
                      context,
                      'いつまで',
                      _endDate != null
                          ? DateFormat('yyyy/MM/dd').format(_endDate!)
                          : '',
                      isDate: true,
                    ),
                    _buildFilterItem(
                      context,
                      '曜日',
                      null,
                      isDayOfWeek: true,
                    ),
                  ],
                ),
              ),
              _buildSectionTitle('主催者'),
              Padding(
                padding: const EdgeInsets.only(left: 10.0), // 字下げ10
                child: _buildFilterItem(
                    context, '性別、属性', _selectedOrganizerGroup,
                    isGenderAttribute: true, isHost: true),
              ),
              _buildSectionTitle('募集する人'),
              Padding(
                padding: const EdgeInsets.only(left: 10.0), // 字下げ10
                child: Column(
                  children: [
                    _buildFilterItem(context, '性別、属性', _selectedTargetGroups.join(', '),
                        isGenderAttribute: true, isHost: false),
                    _buildFilterItem(
                      context,
                      '年齢',
                      _ageMin != null || _ageMax != null
                          ? '${_ageMin != null ? '$_ageMin歳' : 'こだわらない'}〜${_ageMax != null ? '$_ageMax歳' : 'こだわらない'}'
                          : 'こだわらない〜こだわらない',
                      isAge: true,
                      isHost: false,
                    ),
                    _buildFilterItem(context, '写真付き', '',
                        isCheckbox: true, isHost: false),
                  ],
                ),
              ),
              _buildSectionTitle('お金について'),
              Padding(
                padding: const EdgeInsets.only(left: 10.0), // 字下げ10
                child: Column(
                  children: [
                    _buildBudgetFilterItem(context, '予算'),
                    _buildFilterItem(context, 'お金の分け方', _selectedBudgetType,
                        isPaymentMethod: true),
                  ],
                ),
              ),
              _buildSectionTitle('集合場所'),
              Padding(
                padding: const EdgeInsets.only(left: 10.0), // 字下げ10
                child: Column(
                  children: [
                    _buildFilterItem(context, '方面', _selectedMeetingRegion,
                        isMeetingRegion: true),
                    _buildFilterItem(context, '出発地', _selectedMeetingDeparture,
                        isDeparture: true),
                  ],
                ),
              ),
              _buildSectionTitle('タイトル'),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
                  }
                  return null;
                },
              ),
              _buildSectionTitle('本文'),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '本文',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '本文を入力してください';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('投稿'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}