class FilterParams {
  final List<String> hobbies;
  final String gender;
  final int ageMin;
  final int ageMax;

  FilterParams(
      {required this.hobbies,
      required this.gender,
      required this.ageMin,
      required this.ageMax});
}