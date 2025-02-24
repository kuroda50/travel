import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel/locations/location.dart';
import 'package:flutter/services.dart';
import 'package:travel/colors/color.dart';

class RecruitmentPostScreen extends StatefulWidget {
  const RecruitmentPostScreen({super.key});

  @override
  _RecruitmentPostScreenState createState() => _RecruitmentPostScreenState();
}

class _RecruitmentPostScreenState extends State<RecruitmentPostScreen> {
  String? area;
  String? destination;
  String? departure;
  DateTime? startDate;
  DateTime? endDate;
  String? description;
  String? gender;
  String? minAge;
  String? maxAge;

  TextEditingController minAgeController = TextEditingController();
  TextEditingController maxAgeController = TextEditingController();

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _savePost() async {
    if (area == null || destination == null || departure == null || startDate == null || endDate == null || description == null || gender == null || minAge == null || maxAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('すべてのフィールドを入力してください')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ユーザーがログインしていません')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('posts').add({
      'organizerId': user.uid, // 現在のユーザーIDを使用
      'area': area,
      'destination': destination,
      'departure': {
        'name': departure,
        'location': GeoPoint(35.682839, 139.759455), // ここは実際の出発地の座標に置き換えてください
      },
      'startDate': startDate!.toIso8601String(),
      'endDate': endDate!.toIso8601String(),
      'expirationDate': startDate!.toIso8601String(),
      'description': description,
      'recruitment_target': {
        'gender': gender,
        'age_max': int.parse(maxAge!),
        'age_min': int.parse(minAge!),
      },
      'createdAt': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('投稿が保存されました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('募集する'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: AppColor.subBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("旅について", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("方面", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "方面",
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: destinationsByArea.keys.map((String key) {
                          return DropdownMenuItem<String>(
                            value: key,
                            child: Text(key),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            area = value;
                            destination = null;
                          });
                        },
                        value: area,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("行き先", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "行き先",
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: (area != null ? destinationsByArea[area]! : [])
                            .map<DropdownMenuItem<String>>((dynamic place) {
                          return DropdownMenuItem<String>(
                            value: place as String,
                            child: Text(place as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            destination = value;
                          });
                        },
                        value: destination,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("出発地", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "出発地",
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: prefectures.map((String pref) {
                          return DropdownMenuItem<String>(
                            value: pref,
                            child: Text(pref),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            departure = value;
                          });
                        },
                        value: departure,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("いつから", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      backgroundColor: Colors.white, // ここを追加
                    ),
                    child: Text(startDate == null ? "いつから" : startDate!.toLocal().toString().split(' ')[0]),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("いつまで", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      backgroundColor: Colors.white, // ここを追加
                    ),
                    child: Text(endDate == null ? "いつまで" : endDate!.toLocal().toString().split(' ')[0]),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: 200,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "本文",
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                  onChanged: (value) => description = value,
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(height: 20),
              const Text("募集する相手について", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("性別", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 10,
                      children: [
                        ChoiceChip(
                          label: Text("女性"),
                          selected: gender == "female",
                          onSelected: (selected) {
                            setState(() {
                              gender = selected ? "female" : null;
                            });
                          },
                          selectedColor: AppColor.mainButtonColor, // ここを追加
                        ),
                        ChoiceChip(
                          label: Text("男性"),
                          selected: gender == "male",
                          onSelected: (selected) {
                            setState(() {
                              gender = selected ? "male" : null;
                            });
                          },
                          selectedColor: AppColor.mainButtonColor, // ここを追加
                        ),
                        ChoiceChip(
                          label: Text("性別不問"),
                          selected: gender == "unknown",
                          onSelected: (selected) {
                            setState(() {
                              gender = selected ? "unknown" : null;
                            });
                          },
                          selectedColor: AppColor.mainButtonColor, // ここを追加
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 70.0),
                      child: Text(
                        "年齢",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("下限", style: TextStyle(fontSize: 12)),
                              TextField(
                                controller: minAgeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    minAge = value;
                                  });
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Text("〜", style: TextStyle(fontSize: 20)),
                        Container(
                          width: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("上限", style: TextStyle(fontSize: 12)),
                              TextField(
                                controller: maxAgeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    maxAge = value;
                                  });
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.mainButtonColor, // ボタンの背景色
                  foregroundColor: AppColor.subTextColor, // ボタンの文字色
                ),
                child: const Text('人を募集する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}