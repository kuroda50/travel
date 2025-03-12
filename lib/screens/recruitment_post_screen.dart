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
  String? _selectedDestination;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedTargetGroup;
  int? _ageMin;
  int? _ageMax;
  bool _hasPhoto = false;
  String? _selectedOrganizerGroup;
  String? _selectedBudgetType;
  int? _budgetMin;
  int? _budgetMax;
  String? _selectedMeetingRegion;
  String? _selectedMeetingDeparture;

  // プレースホルダーのリスト
  final List<String> _areas = ['アジア', 'ヨーロッパ', '北米'];
  final List<String> _destinations = ['台湾', '中国', '日本'];
  final List<String> _targetGroups = ['female', 'male'];
  final List<String> _budgetTypes = ['splitEvenly', 'individual'];
  final List<String> _meetingRegions = ['日本', '韓国', '中国'];
  final List<String> _meetingDepartures = ['福岡県', '東京都', '大阪府'];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final postData = {
          'tags': _tagsController.text.split(','),
          'where': {
            'area': _selectedArea,
            'destination': _selectedDestination,
          },
          'when': {
            'startDate': _startDate?.toIso8601String(),
            'endDate': _endDate?.toIso8601String(),
          },
          'target': {
            'targetGroups': _selectedTargetGroup,
            'ageMin': _ageMin,
            'ageMax': _ageMax,
            'hasPhoto': _hasPhoto,
          },
          'organizer': {
            'organizerId': user.uid,
            'organizerGroup': _selectedOrganizerGroup,
            'organizerName': user.displayName,
            'organizerBirthday': '2005-02-24', // ここは適宜変更してください
            'hasPhoto': true,
            'photoURL': user.photoURL,
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
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                for (var destination in _destinations)
                  ListTile(
                    title: Text(destination),
                    onTap: () {
                      setState(() {
                        _selectedDestination = destination;
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

  void _showTargetGroupModal(BuildContext context) {
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
                        _selectedTargetGroup = group;
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
                        _selectedOrganizerGroup = group;
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
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                for (var region in _meetingRegions)
                  ListTile(
                    title: Text(region),
                    onTap: () {
                      setState(() {
                        _selectedMeetingRegion = region;
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
                Text('行先',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                for (var departure in _meetingDepartures)
                  ListTile(
                    title: Text(departure),
                    onTap: () {
                      setState(() {
                        _selectedMeetingDeparture = departure;
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
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        String ageMin = isTarget
            ? (_ageMin?.toString() ?? '')
            : (_ageMin?.toString() ?? '');
        String ageMax = isTarget
            ? (_ageMax?.toString() ?? '')
            : (_ageMax?.toString() ?? '');

        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('年齢設定',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(labelText: '最低年齢'),
                onChanged: (value) {
                  ageMin = value;
                },
                controller: TextEditingController(text: ageMin),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(labelText: '最高年齢'),
                onChanged: (value) {
                  ageMax = value;
                },
                controller: TextEditingController(text: ageMax),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
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
      bool isDeparture = false}) {
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
                  Text(_budgetMin != null ? '$_budgetMin 円' : '未設定'),
                  Text(' 〜 '),
                  Text(_budgetMax != null ? '$_budgetMax 円' : '未設定'),
                  Icon(Icons.expand_more),
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
                decoration: InputDecoration(labelText: '最低予算（円）'),
                onChanged: (value) {
                  budgetMin = value;
                },
                controller: TextEditingController(text: budgetMin),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '最高予算（円）'),
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
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'タグ',
                ),
              ),
              SizedBox(height: 16),
              _buildSectionTitle('どこへ'),
              Padding(
                padding: const EdgeInsets.only(left: 10.0), // 字下げ10
                child: Column(
                  children: [
                    _buildFilterItem(context, '方面', _selectedArea,
                        isRegion: true),
                    _buildFilterItem(context, '行き先', _selectedDestination,
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
                    _buildFilterItem(context, '性別、属性', _selectedTargetGroup,
                        isGenderAttribute: true, isHost: false),
                    _buildFilterItem(
                      context,
                      '年齢',
                      _ageMin != null && _ageMax != null
                          ? '${_ageMin}歳〜${_ageMax}歳'
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
