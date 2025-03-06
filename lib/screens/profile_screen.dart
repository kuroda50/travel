import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/component/header.dart';

class ProfileScreen2 extends StatelessWidget {
  const ProfileScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
      ),
      body: const Center(
        child: Text('プロフィール画面'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              SizedBox(height: 20),
              Text('今までの募集',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildRecruitmentList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/profile.jpg'), // 適宜画像を変更
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('山田花子  32歳',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.settings, color: AppColor.subTextColor,),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColor.mainButtonColor
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.mail, color: AppColor.subTextColor,),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColor.mainButtonColor
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            'フォロー ',
                            style: TextStyle(
                              color: AppColor.subTextColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.mainButtonColor),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('自己紹介文', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('30代女、英語講師です。ヨーロッパ10か国に行きました。'),
            SizedBox(height: 10),
            Text('趣味', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: ['サイクリング', '野球観戦', 'カラオケ', '読書']
                  .map((hobby) => Chip(label: Text(hobby)))
                  .toList(),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.edit,
                color: AppColor.subTextColor,
              ),
              label: Text(
                'プロフィールを編集する',
                style: TextStyle(
                  color: AppColor.subTextColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.mainButtonColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecruitmentList() {
    return Column(
      children: List.generate(3, (index) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.grey[300]),
            title: const Column(
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
            // subtitle: Text(
            //     'アメリカ・カナダ\n20才〜35才 写真あり\n2025/04/01 〜 2025/04/30 金土日\nてつろう、20歳'),
          ),
        );
      }),
    );
  }
}
