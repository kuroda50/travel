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

String generateRoomKey(String userIdA, String userIdB) {
  List<String> sortedUsers = [userIdA, userIdB]..sort(); // ソートして順序を統一
  return "${sortedUsers[0]}_${sortedUsers[1]}";
}
