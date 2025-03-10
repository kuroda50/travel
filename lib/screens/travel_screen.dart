import 'dart:async';
import 'package:flutter/material.dart';
import 'travel_search.dart'; // ここに追加

void main() {
  runApp(TravelScreen());
}

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
    return MaterialApp(
      title: '旅行仲間募集',
      home: Scaffold(
        appBar: AppBar(
          title: Text('仲間と集まる'),
          backgroundColor: Color(0xFF559900),
          actions: [
            TextButton(
              onPressed: () {},
              child: Text('ログイン'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: 390,
                    height: 227,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          _imageUrls[index],
                          fit: BoxFit.cover,
                        );
                      },
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 0, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            '旅行仲間と\n集まる',
                            textAlign: TextAlign.center,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            backgroundColor: Colors.green, // 背景色を緑に設定
                            foregroundColor: Colors.white, // テキスト色を白に設定
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            '同じ趣味の人と\n集まる',
                            textAlign: TextAlign.center,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            backgroundColor: Colors.green, // 背景色を緑に設定
                            foregroundColor: Colors.white, // テキスト色を白に設定
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TravelSearch()),
                    );
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('検索条件を設定する'),
                        Icon(Icons.search),
                      ],
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('2週間でアメリカ、カナダ巡り'),
                        Row(
                          children: <Widget>[
                            Icon(Icons.person),
                            Text('>20才~35才 写真あり'),
                          ],
                        ),
                        Text('アメリカ、カナダ'),
                        Text('てつろう、20才 2025/04/01~2025/04/30 金土日'),
                      ],
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text('全て表示する >'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // 人を募集する処理
                    },
                    child: Text('人を募集する'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // 背景色を緑に設定
                      foregroundColor: Colors.white, // テキスト色を白に設定
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}