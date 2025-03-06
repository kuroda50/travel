import 'package:flutter/material.dart';
import 'package:travel/colors/color.dart';
import 'package:travel/component/header.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isMyProfile = false;
  @override
  void initState() {
    super.initState();
    isMyProfile = checkUserId(widget.userId);
  }

  bool checkUserId(String userId) {
    // if (userId == FirebaseAuth.instance.currentUser!.uid) {
    //   print('自分のプロフィールを見ています');
    //   return true;
    // } else {
    //   print('他人のプロフィールを見ています');
    //   return false;
    // }
    return true;
  }

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
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '山田花子  32歳',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColor.mainButtonColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.settings,
                                  color: AppColor.subTextColor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      isMyProfile
                          ? Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.mainButtonColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.mail,
                                        color: AppColor.subTextColor),
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text(
                                    'フォロー',
                                    style:
                                        TextStyle(color: AppColor.subTextColor),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColor.mainButtonColor),
                                ),
                              ],
                            )
                          : ElevatedButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.edit,
                                  color: AppColor.subTextColor),
                              label: Text(
                                'プロフィールを編集する',
                                style: TextStyle(color: AppColor.subTextColor),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.mainButtonColor,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('自己紹介文', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('30代女、英語講師です。ヨーロッパ10か国に行きました。'),
            SizedBox(height: 16),
            Text('趣味', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ['サイクリング', '野球観戦', 'カラオケ', '読書']
                  .map((hobby) => Chip(label: Text(hobby)))
                  .toList(),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.edit, color: AppColor.subTextColor),
                label: Text(
                  'プロフィールを編集する',
                  style: TextStyle(color: AppColor.subTextColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.mainButtonColor,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
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

// class ProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: Header(),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildProfileSection(),
//               SizedBox(height: 20),
//               Text('今までの募集',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               SizedBox(height: 10),
//               _buildRecruitmentList(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileSection() {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 40,
//                   backgroundImage: AssetImage('assets/profile.jpg'),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               '山田花子  32歳',
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: AppColor.mainButtonColor,
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               onPressed: () {},
//                               icon: Icon(Icons.settings,
//                                   color: AppColor.subTextColor),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 6),
//                       Row(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               color: AppColor.mainButtonColor,
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               onPressed: () {},
//                               icon: Icon(Icons.mail,
//                                   color: AppColor.subTextColor),
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           ElevatedButton(
//                             onPressed: () {},
//                             child: Text(
//                               'フォロー',
//                               style: TextStyle(color: AppColor.subTextColor),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColor.mainButtonColor),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Text('自己紹介文', style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 4),
//             Text('30代女、英語講師です。ヨーロッパ10か国に行きました。'),
//             SizedBox(height: 16),
//             Text('趣味', style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 4),
//             Wrap(
//               spacing: 8,
//               runSpacing: 4,
//               children: ['サイクリング', '野球観戦', 'カラオケ', '読書']
//                   .map((hobby) => Chip(label: Text(hobby)))
//                   .toList(),
//             ),
//             SizedBox(height: 16),
//             Center(
//               child: ElevatedButton.icon(
//                 onPressed: () {},
//                 icon: Icon(Icons.edit, color: AppColor.subTextColor),
//                 label: Text(
//                   'プロフィールを編集する',
//                   style: TextStyle(color: AppColor.subTextColor),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColor.mainButtonColor,
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRecruitmentList() {
//     return Column(
//       children: List.generate(3, (index) {
//         return Card(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           elevation: 2,
//           margin: EdgeInsets.symmetric(vertical: 8),
//           child: ListTile(
//             leading: CircleAvatar(backgroundColor: Colors.grey[300]),
//             title: const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Text('2週間でアメリカ、カナダ巡り'),
//                 Row(
//                   children: <Widget>[
//                     Icon(Icons.person),
//                     Text('>20才~35才 写真あり'),
//                   ],
//                 ),
//                 Text('アメリカ、カナダ'),
//                 Text('てつろう、20才 2025/04/01~2025/04/30 金土日'),
//               ],
//             ),
//             // subtitle: Text(
//             //     'アメリカ・カナダ\n20才〜35才 写真あり\n2025/04/01 〜 2025/04/30 金土日\nてつろう、20歳'),
//           ),
//         );
//       }),
//     );
//   }
// }
