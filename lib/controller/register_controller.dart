import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/enum/user_enum.dart';
import 'package:geomath/services/auth.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/widget/show_custom_snackbar.dart';
import '../../helpers/text_constant.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import 'package:geomath/views/pages/login.dart';

class RegisterController {
  final AuthService _auth = AuthService();
  final FirebaseService firebaseService = FirebaseService();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool signUpButtonIsClicked = false;
  bool isPassword1Visible = false;
  bool isPassword2Visible = false;

  String? errorMsg;
  String fname = '';
  String lname = '';
  String role = '';
  String school = '';
  String classEnrollmentKey = '';
  String year = '';
  String email = '';
  String password = '';
  String gender = '';
  String classType = '';
  String teacherName = '';
  String confirmedPassword = '';

  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController classEnrollmentKeyController =
      TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController teacherController = TextEditingController();
  final TextEditingController confirmedPasswordController =
      TextEditingController();

  late Future<List<Map<String, dynamic>>> allClassEnrollmentKeyFuture;

  void initState() {
    allClassEnrollmentKeyFuture = firebaseService.getClassEnrollmentKey();
    getEnrolledClassDetails();
  }

  Future<Map<String, dynamic>> fetchClassDetails(String classId) async {
    return await firebaseService.getClassDetails(classId);
  }

  Future<void> getEnrolledClassDetails() async {
    print('class enrollment key: $classEnrollmentKey');

    Map<String, dynamic> classDetails =
        await fetchClassDetails(classEnrollmentKey);

    teacherName = classDetails['teacherName'];
    school = classDetails['schoolName'];
    year = classDetails['year'];
  }

  void dispose() {
    fnameController.dispose();
    lnameController.dispose();
    schoolController.dispose();
    classController.dispose();
    classEnrollmentKeyController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmedPasswordController.dispose();
  }

  Future<void> signUp(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      User? user = await _auth.signUpWithEmailAndPassword(email, password);

      print(user);
      if (user != null) {
        print('User is successfully created');
        UserModel userModel = UserModel(
            uid: user.uid,
            firstName: fname,
            lastName: lname,
            gender: gender,
            role: role,
            classEnrollmentKey: classEnrollmentKey,
            year: year,
            school: school,
            teacherName: role.toLowerCase() ==
                    RoleEnum.teacher.enumToString().toLowerCase()
                ? '$fname $lname'
                : teacherName,
            image: '',
            email: email,
            profilePicture: '');

        if (role.toLowerCase() ==
            RoleEnum.teacher.enumToString().toLowerCase()) {
          ClassModel classModel = ClassModel(
              userId: user.uid,
              classEnrollmentKey: classEnrollmentKey,
              year: year,
              teacherName: '$fname $lname',
              schoolName: school);
          firebaseService.addClassEnrollmentKey(classModel);
        }

        firebaseService.addUserDetails(userModel);
        showCustomSnackBar(context, TextConstant.registerSuccessfully);
        Navigator.of(context).pushNamed(LoginPage.routeName);
      } else {
        print('Some error happen');
      }
    }
  }

  void togglePassword1Visibility() {
    isPassword1Visible = !isPassword1Visible;
  }

  void togglePassword2Visibility() {
    isPassword2Visible = !isPassword2Visible;
  }
}
