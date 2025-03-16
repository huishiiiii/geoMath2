class UserModel {
  final String uid;
  String firstName;
  String lastName;
  String gender;
  final String role;
  String classEnrollmentKey;
  String year;
  String school;
  String teacherName;
  String? image;
  final String email;
  final String profilePicture;

  UserModel(
      {required this.uid,
      required this.firstName,
      required this.lastName,
      required this.gender,
      required this.role,
      required this.classEnrollmentKey,
      required this.year,
      required this.school,
      required this.teacherName,
      required this.email,
      this.image,
      required this.profilePicture});
}
