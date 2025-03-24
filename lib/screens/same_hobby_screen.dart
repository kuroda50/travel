import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SameHobbyScreen extends StatefulWidget {
  const SameHobbyScreen({super.key});

  @override
  _SameHobbyScreenState createState() => _SameHobbyScreenState();
}

class _SameHobbyScreenState extends State<SameHobbyScreen> {
  final TextEditingController _hobbyController = TextEditingController();
  String _selectedGender = 'どちらでも';
  int? _startAge;
  int? _endAge;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<String> _imageUrls = [
    'https://source.unsplash.com/random/800x600?nature',
    'https://source.unsplash.com/random/800x600?city',
    'https://source.unsplash.com/random/800x600?technology',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _imageUrls.length - 1) {
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

  void _search() {
    GoRouter.of(context).push(
      '/account-list',
      extra: {
        'hobby': _hobbyController.text,
        'gender': _selectedGender,
        'startAge': _startAge,
        'endAge': _endAge,
      },
    );
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
      appBar: AppBar(title: const Text('同じ趣味の人を探す')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _imageUrls.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return Image.network(
                    _imageUrls[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _hobbyController,
              decoration: const InputDecoration(labelText: '趣味'),
            ),
            DropdownButton<String>(
              value: _selectedGender,
              items: ['男', '女', 'どちらでも']
                  .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedGender = value!),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: '開始年齢'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() => _startAge = int.tryParse(value)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: '終了年齢'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() => _endAge = int.tryParse(value)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _search,
              child: const Text('検索'),
            ),
          ],
        ),
      ),
    );
  }
}
