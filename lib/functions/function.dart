import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

int calculateAge(DateTime birth) {
  DateTime today = DateTime.now();
  int age = today.year - birth.year;

  // 誕生日がまだ来ていなければ1歳引く
  if (today.month < birth.month ||
      (today.month == birth.month && today.day < birth.day)) {
    age--;
  }
  return age;
}

// Future<List<RecruitmentPost>> getRecruitmentList(
//     List<String> recruitmentPostIdList) async {
//   List<RecruitmentPost> recruitmentPosts = [];
//   for (int i = 0; i < recruitmentPostIdList.length; i++) {
//     DocumentReference recruitmentRef = FirebaseFirestore.instance
//         .collection('posts')
//         .doc(recruitmentPostIdList[i]);
//     await recruitmentRef.get().then((recruitment) {
//       if (recruitment.exists) {
//         // 'post' をここで初期化
//         RecruitmentPost post = RecruitmentPost(
//           postId: recruitmentPostIdList[i],
//           title: recruitment['title'],
//           organizerPhotoURL: recruitment['organizer']['photoURL'] ?? "",
//           organizerGroup: recruitment['organizer']['organizerGroup'],
//           targetGroups: List<String>.from(recruitment['target']['targetGroups']
//               .map((group) => group.toString())
//               .toList()),
//           targetAgeMin: recruitment['target']['ageMin'].toString(),
//           targetAgeMax: recruitment['target']['ageMax'].toString(),
//           targetHasPhoto: recruitment['target']['hasPhoto'] ? '写真あり' : '写真なし',
//           destinations: List<String>.from(recruitment['where']['destination']
//               .map((destination) => destination.toString())
//               .toList()),
//           organizerName: recruitment['organizer']['organizerName'],
//           organizerAge: calculateAge(
//                   recruitment['organizer']['organizerBirthday'].toDate())
//               .toString(),
//           startDate: DateFormat('yyyy/MM/dd')
//               .format(recruitment['when']['startDate'].toDate())
//               .toString(),
//           endDate: DateFormat('yyyy/MM/dd')
//               .format(recruitment['when']['endDate'].toDate())
//               .toString(),
//           days: List<String>.from(recruitment['when']['dayOfWeek']
//               .map((day) => day.toString())
//               .toList()),
//         );
//         // 'post' をリストに追加
//         recruitmentPosts.add(post);
//       } else {
//         print("募集情報が見つかりません");
//       }
//     });
//   }
//   return recruitmentPosts;
// }

String generateRoomKey(String userIdA, String userIdB) {
  List<String> sortedUsers = [userIdA, userIdB]..sort(); // ソートして順序を統一
  return "${sortedUsers[0]}_${sortedUsers[1]}";
}

// class RecruitmentPost {
//   String postId;
//   String title;
//   String organizerPhotoURL;
//   String organizerGroup;
//   List<String> targetGroups;
//   String targetAgeMin;
//   String targetAgeMax;
//   String targetHasPhoto;
//   List<String> destinations;
//   String organizerName;
//   String organizerAge;
//   String startDate;
//   String endDate;
//   List<String> days;

//   RecruitmentPost({
//     required this.postId,
//     required this.title,
//     required this.organizerPhotoURL,
//     required this.organizerGroup,
//     required this.targetGroups,
//     required this.targetAgeMin,
//     required this.targetAgeMax,
//     required this.targetHasPhoto,
//     required this.destinations,
//     required this.organizerName,
//     required this.organizerAge,
//     required this.startDate,
//     required this.endDate,
//     required this.days,
//   });
// }
