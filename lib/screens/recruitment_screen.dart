import 'package:flutter/material.dart';

void main() {
  runApp(RecruitmentScreen());
}

class RecruitmentScreen extends StatelessWidget {
  const RecruitmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 変数を定義
    String title = '北欧、ヨーロッパ旅行';
    String tags = 'オーロラ 犬ぞり 北欧 ヨーロッパ';
    String area = 'アジア';
    String destination = '台湾、中国';
    String startDate = '2024年-02月-15日';
    String endDate = '2024年-02月-17日';
    String days = '金、土、日';
    String gender = '男、女、家族、グループ';
    String age = '20歳~49歳';
    String photo = 'どちらでも';
    String budget = '未定';
    String payment = '各自自腹';
    String locationArea = '日本';
    String departure = '福岡';
    String memberTitle = '参加メンバー';
    String organizerTitle = '主催者';
    String member1Name = 'たなか、24歳、男';
    String member2Name = 'かくえい、28歳、女';
    String member3Name = 'ごん、23歳、男';
    String moneyTitle = 'お金について';
    String placeTitle = '集合場所';
    String recruitText = '旅行仲間募集です。\n20~40代の方だと嬉しいです。\n場所は台湾、中国あたりを考えています。\n当方1年に4~6回ほど海外に行き英語話せます。\n現地の友人もいるのですが、日本人同士の旅行だと一緒に遊べて、現地でのスケジュールも合わせやすい為、友人募集させて頂きたいといった感じです。\n観光事、現地の人々との交流等、オープンマインドで気軽に一緒に楽しめる方を探しています。';
    String buttonText = '話を聞きたい';

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('仲間と集まる'),
          backgroundColor: Color(0xFF559900), // ヘッダーの色を559900に変更
        ),
        backgroundColor: Colors.white, // 背景色を白に変更
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 画像部分
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://static.wikia.nocookie.net/pokemon/images/2/29/Spr_6x_677.png/revision/latest/scale-to-width-down/250?cb=20161026045550'), // 画像URLをここに入力
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'タイトル: $title', // 変数を埋め込む
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'タグ: $tags', // 変数を埋め込む
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'どこへ',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.favorite_border),
                      ],
                    ),
                    ListTile(
                      title: Text('方面'),
                      trailing: Text(area), // 変数を埋め込む
                    ),
                    ListTile(
                      title: Text('行き先'),
                      trailing: Text(destination), // 変数を埋め込む
                    ),
                    SizedBox(height: 20),
                    Text(
                      'いつ',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      title: Text('いつから'),
                      trailing: Text(startDate), // 変数を埋め込む
                    ),
                    ListTile(
                      title: Text('いつまで'),
                      trailing: Text(endDate), // 変数を埋め込む
                    ),
                    ListTile(
                      title: Text('曜日'),
                      trailing: Text(days), // 変数を埋め込む
                    ),
                    SizedBox(height: 20),
                    Text(
                      '募集する人',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      title: Text('性別、属性'),
                      trailing: Text(gender), // 変数を埋め込む
                    ),
                    ListTile(
                      title: Text('年齢'),
                      trailing: Text(age), // 変数を埋め込む
                    ),
                    ListTile(
                      title: Text('写真付き'),
                      trailing: Text(photo), // 変数を埋め込む
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  memberTitle, // 変数を埋め込む
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  organizerTitle, // 変数を埋め込む
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                ),
                title: Text(member1Name), // 変数を埋め込む
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                ),
                title: Text(member2Name), // 変数を埋め込む
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                ),
                title: Text(member3Name), // 変数を埋め込む
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  moneyTitle, // 変数を埋め込む
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: Text('予算'),
                trailing: Text(budget), // 変数を埋め込む
              ),
              ListTile(
                title: Text('お金の分け方'),
                trailing: Text(payment), // 変数を埋め込む
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  placeTitle, // 変数を埋め込む
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: Text('方面'),
                trailing: Text(locationArea), // 変数を埋め込む
              ),
              ListTile(
                title: Text('出発地'),
                trailing: Text(departure), // 変数を埋め込む
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFBFAF6),
                    border: Border.all(color: Colors.grey),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    recruitText, // 変数を埋め込む
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // ボタンが押されたときの処理
                    },
                    child: Text(buttonText), // 変数を埋め込む
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // ボタンの背景色
                      foregroundColor: Colors.white, // ボタンのテキスト色
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