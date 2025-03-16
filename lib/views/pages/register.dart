import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/enum/user_enum.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/helpers/validate_helper.dart';
import 'package:geomath/models/class_model.dart';
import 'package:geomath/models/user_model.dart';
import 'package:geomath/services/auth.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/widget/button/custom_dropdown_button.dart';
import 'package:geomath/views/widget/show_custom_snackbar.dart';

import '../../helpers/asset_helper.dart';
import '../../helpers/global.dart';
import '../widget/button/custom_button.dart';
import '../widget/custom_text_form_field.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  static const routeName = 'register';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  FirebaseService firebaseService = FirebaseService();
  late Future<List<Map<String, dynamic>>> allClassEnrollmentKeyFuture;

  bool signUpButtonIsClicked = false;

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
  bool isPassword1Visible = false;
  bool isPassword2Visible = false;

  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();
  TextEditingController schoolController = TextEditingController();
  TextEditingController classController = TextEditingController();
  TextEditingController classEnrollmentKeyController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController teacherController = TextEditingController();
  TextEditingController confirmedPasswordController = TextEditingController();

  @override
  void initState() {
    allClassEnrollmentKeyFuture = firebaseService.getClassEnrollmentKey();
    getEnrolledClassDetails();
    super.initState();
  }

  Future<Map<String, dynamic>> fetchClassDetails(String classId) async {
    return await firebaseService.getClassDetails(classId);
  }

  Future<void> getEnrolledClassDetails() async {
    print('calss enrolment key: $classEnrollmentKey');

    Map<String, dynamic> classDetails =
        await fetchClassDetails(classEnrollmentKey);

    setState(() {
      teacherName = classDetails['teacherName'];
      school = classDetails['schoolName'];
      year = classDetails['year'];
    });
  }

  @override
  void dispose() {
    fnameController.dispose();
    lnameController.dispose();
    schoolController.dispose();
    classController.dispose();
    classEnrollmentKeyController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmedPasswordController.dispose();
    super.dispose();
  }

  void signUp(
      String fname,
      String lname,
      String role,
      String school,
      String year,
      String className,
      String classEnrollmentKey,
      String gender,
      String email,
      String password) async {
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

      if (role.toLowerCase() == RoleEnum.teacher.enumToString().toLowerCase()) {
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
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamed(LoginPage.routeName);
    } else {
      print('Some error happen');
    }
  }

  @override
  Widget build(BuildContext context) {
    setScreenWidth(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(AssetHelper.transparentLogo300),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              TextConstant.geomath.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    TextConstant.createAccount,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: screenWidth * 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),
                              Row(
                                children: [
                                  CustomTextFormField(
                                    width: (MediaQuery.of(context).size.width -
                                            75) /
                                        2,
                                    controller: fnameController,
                                    padding: const EdgeInsets.only(bottom: 20),
                                    labelText: TextConstant.firstName,
                                    hintText: TextConstant.exampleFirstName,
                                    prefixIcon:
                                        const Icon(Icons.badge_outlined),
                                    validator: (value) {
                                      return ValidatorHelper.validateName(
                                          value);
                                    },
                                    onChanged: (value) {
                                      setState(() => fname = value);
                                    },
                                  ),
                                  const SizedBox(width: 15),
                                  CustomTextFormField(
                                    width: (MediaQuery.of(context).size.width -
                                            75) /
                                        2,
                                    controller: lnameController,
                                    padding: const EdgeInsets.only(bottom: 20),
                                    labelText: TextConstant.lastName,
                                    hintText: TextConstant.exampleLastName,
                                    prefixIcon:
                                        const Icon(Icons.badge_outlined),
                                    validator: (value) {
                                      return ValidatorHelper.validateName(
                                          value);
                                    },
                                    onChanged: (value) {
                                      setState(() => lname = value);
                                    },
                                  ),
                                ],
                              ),
                              CustomDropdownButton(
                                prefixIcon: Icons.person_3_outlined,
                                hintText: TextConstant.role,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                                items: const ['Student', 'Teacher'],
                                onItemSelected: (value) {
                                  setState(() {
                                    role = value!;
                                  });
                                },
                              ),
                              if (role.isEmpty && signUpButtonIsClicked)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10.5, 8, 10, 0),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${TextConstant.role} is Empty',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(
                                height: 20,
                              ),
                              if (role.toLowerCase() ==
                                  RoleEnum.student.enumToString().toLowerCase())
                                Column(
                                  children: [
                                    
                                    FutureBuilder<List<Map<String, dynamic>>>(
                                      future: allClassEnrollmentKeyFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          List<Map<String, dynamic>>
                                              allclassEnrollmentKeys =
                                              snapshot.data ?? [];
                                          return CustomTextFormField(
                                            controller:
                                                classEnrollmentKeyController,
                                            padding: const EdgeInsets.only(
                                                bottom: 20),
                                            labelText:
                                                TextConstant.classEnrollmentKey,
                                            hintText: '',
                                            prefixIcon: const Icon(
                                                Icons.class_outlined),
                                            validator: (value) {
                                              // Validate if the field is empty
                                              String? emptyValidationMessage =
                                                  ValidatorHelper.validateEmpty(
                                                      value,
                                                      TextConstant
                                                          .classEnrollmentKey);
                                              if (emptyValidationMessage !=
                                                  null) {
                                                // Return the empty validation message if the field is empty
                                                return emptyValidationMessage;
                                              }

                                              // Check if the entered enrollment key exists in the list of enrollment keys
                                              bool isEnrollKeyExists =
                                                  allclassEnrollmentKeys.any(
                                                      (enrollKeyData) =>
                                                          enrollKeyData['id'] ==
                                                          value);
                                              if (!isEnrollKeyExists) {
                                                // Return a message if the entered enrollment key does not exist
                                                return 'Enrollment key does not exist!';
                                              }

                                              // Return null if validation passes
                                              return null;
                                            },
                                            onChanged: (value) {
                                              bool isEnrollKeyExists =
                                                  allclassEnrollmentKeys.any(
                                                      (enrollKeyData) =>
                                                          enrollKeyData['id'] ==
                                                          value);
                                              if (isEnrollKeyExists) {
                                                setState(() =>
                                                    classEnrollmentKey = value);
                                                print('Enrollment key exists!');
                                              } else {
                                                print(
                                                    'Enrollment key does not exist!');
                                              }
                                            },
                                          );
                                        }
                                      },
                                    ),

                                    
                                  ],
                                ),
                              if (role.toLowerCase() ==
                                  RoleEnum.teacher.enumToString().toLowerCase())
                                Column(
                                  children: [
                                   
                                    CustomTextFormField(
                                      controller: schoolController,
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      labelText: TextConstant.schoolName,
                                      hintText: TextConstant.exampleSchool,
                                      prefixIcon:
                                          const Icon(Icons.school_outlined),
                                      validator: (value) =>
                                          ValidatorHelper.validateSchool(value),
                                      onChanged: (value) {
                                        setState(() => school = value);
                                      },
                                    ),
                                    FutureBuilder<List<Map<String, dynamic>>>(
                                      future: allClassEnrollmentKeyFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          List<Map<String, dynamic>>
                                              allclassEnrollmentKeys =
                                              snapshot.data ?? [];
                                          return CustomTextFormField(
                                            controller:
                                                classEnrollmentKeyController,
                                            padding: const EdgeInsets.only(
                                                bottom: 20),
                                            labelText:
                                                TextConstant.classEnrollmentKey,
                                            hintText: '',
                                            prefixIcon: const Icon(
                                                Icons.class_outlined),
                                            validator: (value) {
                                              // Validate if the field is empty
                                              String? emptyValidationMessage =
                                                  ValidatorHelper.validateEmpty(
                                                      value,
                                                      TextConstant
                                                          .classEnrollmentKey);
                                              bool isEnrollKeyExists =
                                                  allclassEnrollmentKeys.any(
                                                      (enrollKeyData) =>
                                                          enrollKeyData['id'] ==
                                                          value);
                                              print(
                                                  'Result: $isEnrollKeyExists Data: ${allclassEnrollmentKeys}');
                                              if (emptyValidationMessage !=
                                                  null) {
                                                return emptyValidationMessage;
                                              } else if (isEnrollKeyExists) {
                                                return 'Enrollment key already exist!';
                                              } else {
                                                return null;
                                              }
                                            },
                                            onChanged: (value) {
                                              setState(() =>
                                                  classEnrollmentKey = value);
                                            },
                                          );
                                        }
                                      },
                                    ),
                                    CustomDropdownButton(
                                      prefixIcon: Icons.numbers_outlined,
                                      hintText: TextConstant.yearOfClass,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      items: const [
                                        '1',
                                        '2',
                                        '3',
                                        '4',
                                        '5',
                                        '6'
                                      ],
                                      onItemSelected: (value) {
                                        year = value!;
                                      },
                                    ),

                                    if (year.isEmpty && signUpButtonIsClicked)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10.5, 8, 10, 0),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${TextConstant.year} is Empty',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    
                                  ],
                                ),
                              CustomDropdownButton(
                                prefixIcon: Icons.person_outlined,
                                hintText: TextConstant.gender,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                                items: const ['Female', 'Male'],
                                onItemSelected: (value) {
                                  gender = value!;
                                },
                              ),
                              if (gender.isEmpty && signUpButtonIsClicked)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10.5, 8, 10, 0),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${TextConstant.gender} is Empty',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(
                                height: 20,
                              ),
                              CustomTextFormField(
                                controller: emailController,
                                padding: const EdgeInsets.only(bottom: 20),
                                labelText: TextConstant.email,
                                hintText: TextConstant.exampleEmail,
                                prefixIcon: const Icon(Icons.email_outlined),
                                validator: (value) =>
                                    ValidatorHelper.validateEmail(value),
                                onChanged: (value) {
                                  setState(() => email = value);
                                },
                              ),
                              CustomTextFormField(
                                controller: passwordController,
                                obscureText: !isPassword1Visible,
                                padding: const EdgeInsets.only(bottom: 20),
                                labelText: TextConstant.password,
                                hintText: TextConstant.examplePassword,
                                prefixIcon:
                                    const Icon(Icons.lock_open_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPassword1Visible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: ColorConstant.blackColor
                                        .withOpacity(0.4),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPassword1Visible = !isPassword1Visible;
                                    });
                                  },
                                ),
                                validator: (value) =>
                                    ValidatorHelper.validatePassword(value,
                                        confirmedPasswordController.text),
                                onChanged: (value) {
                                  setState(() => password = value);
                                },
                              ),
                              CustomTextFormField(
                                controller: confirmedPasswordController,
                                obscureText: !isPassword2Visible,
                                padding: const EdgeInsets.only(bottom: 20),
                                labelText: TextConstant.confirmedPassword,
                                hintText: TextConstant.examplePassword,
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPassword2Visible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: ColorConstant.blackColor
                                        .withOpacity(0.4),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPassword2Visible = !isPassword2Visible;
                                    });
                                  },
                                ),
                                validator: (value) =>
                                    ValidatorHelper.validateConfirmedPassword(
                                        value, passwordController.text),
                                onChanged: (value) {
                                  setState(() => confirmedPassword = value);
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                    fontSize: screenWidth * 4.5,
                                    height: 40,
                                    label: TextConstant.signUp.toUpperCase(),
                                    onPressed: () async {
                                      setState(() {
                                        signUpButtonIsClicked = true;
                                      });

                                      if (_formKey.currentState!.validate()) {
                                        if (role.isNotEmpty &&
                                            gender.isNotEmpty) {
                                          if ((role.toLowerCase() ==
                                              RoleEnum.teacher
                                                  .enumToString()
                                                  .toLowerCase())) {
                                            signUp(
                                                fnameController.text,
                                                lnameController.text,
                                                role,
                                                schoolController.text,
                                                year,
                                                classController.text,
                                                classEnrollmentKey,
                                                gender,
                                                emailController.text,
                                                passwordController.text);
                                          } else {
                                            await getEnrolledClassDetails();

                                            signUp(
                                                fnameController.text,
                                                lnameController.text,
                                                role,
                                                school,
                                                year,
                                                classController.text,
                                                classEnrollmentKey,
                                                gender,
                                                emailController.text,
                                                passwordController.text);
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '${TextConstant.dontHaveAnAcc} ',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(LoginPage.routeName),
                          child: const Text(
                            TextConstant.signUp,
                            style: TextStyle(
                              color: ColorConstant.secondaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
