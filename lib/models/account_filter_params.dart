class AccountFilterParams {
  final List<String> hobbies;
  final String gender;
  final int ageMin;
  final int ageMax;

  AccountFilterParams(
      {required this.hobbies,
      required this.gender,
      required this.ageMin,
      required this.ageMax});
}