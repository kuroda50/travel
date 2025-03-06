import 'dart:async';
import 'package:flutter/material.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({Key? key}) : super(key: key);

  @override
  _TravelScreenState createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;
  final List<String> _imageUrls = [
    'lib/screens/images/OIP (1).jpg',
    'lib/screens/images/OIP (2).jpg',
    'lib/screens/images/OIP (3).jpg',
    'lib/screens/images/OIP (4).jpg',
    'lib/screens/images/OIP (5).jpg',
    'lib/screens/images/OIP (6).jpg',
    'lib/screens/images/OIP (7).jpg',
    'lib/screens/images/OIP (8).jpg',
    'lib/screens/images/OIP (9).jpg',
    'lib/screens/images/OIP (10).jpg',
    'lib/screens/images/OIP.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _imageUrls.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
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
      appBar: AppBar(
        title: const Text('旅へ行く'),
      ),
      body: const Center(
        child: Text('旅へ行く画面'),
      ),
    );
  }
}