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



class RecruitmentPost {
  String postId;
  String title;
  String organizerPhotoURL;
  String organizerGroup;
  List<String> targetGroups;
  String targetAgeMin;
  String targetAgeMax;
  String targetHasPhoto;
  List<String> destinations;
  String organizerName;
  String organizerAge;
  String startDate;
  String endDate;
  List<String> days;

  RecruitmentPost({
    required this.postId,
    required this.title,
    required this.organizerPhotoURL,
    required this.organizerGroup,
    required this.targetGroups,
    required this.targetAgeMin,
    required this.targetAgeMax,
    required this.targetHasPhoto,
    required this.destinations,
    required this.organizerName,
    required this.organizerAge,
    required this.startDate,
    required this.endDate,
    required this.days,
  });
}
