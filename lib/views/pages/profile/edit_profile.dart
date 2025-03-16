import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/enum/user_enum.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/global.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/helpers/validate_helper.dart';
import 'package:geomath/models/user_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/pages/profile/user_profile.dart';
import 'package:geomath/views/widget/app_bar.dart';
import 'package:geomath/views/widget/button/custom_button.dart';
import 'package:geomath/views/widget/button/custom_dropdown_button.dart';
import 'package:geomath/views/widget/custom_text_form_field.dart';
import 'package:geomath/views/widget/dialog/delete_confirmation_dialog.dart';

class EditUserProfilePage extends StatefulWidget {
  static const routeName = 'edit_user_profile';
  const EditUserProfilePage({super.key});

  @override
  State<EditUserProfilePage> createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String fname = '';
  String lname = '';
  String role = '';
  String school = '';
  String category = '';
  String year = '';
  String email = '';
  String gender = '';
  String classType = '';
  String teacherName = '';
  bool updateButtonIsClicked = false;

  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();
  TextEditingController schoolController = TextEditingController();
  TextEditingController classController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController teacherController = TextEditingController();

  FirebaseService firebaseService = FirebaseService();

  UserModel? user;
  List<String> classIds = [];

  Future<Map<String, dynamic>> fetchUserDetails(String uid) async {
    return await firebaseService.getUserDetails(uid);
  }

  Future<void> getUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? firebaseUser = auth.currentUser;
    Map<String, dynamic> userDetails =
        await fetchUserDetails(firebaseUser!.uid);

    // Access user details
    setState(() {
      user = UserModel(
          uid: firebaseUser.uid,
          firstName: userDetails['firstname'] ?? '',
          lastName: userDetails['lastname'] ?? '',
          gender: userDetails['gender'] ?? '',
          role: userDetails['role'] ?? '',
          email: userDetails['email'] ?? '',
          classEnrollmentKey: userDetails['classEnrollmentKey'] ?? '',
          year: userDetails['year'] ?? '',
          school: userDetails['school'] ?? '',
          teacherName: userDetails['teacherName'] ?? '',
          profilePicture: userDetails['profilePicture'] ?? '');
    });
  }

  Future<void> getClassIds() async {
    List<Map<String, dynamic>> teacherClasses =
        await firebaseService.getTeacherClasses();

    setState(() {
      classIds =
          teacherClasses.map((classData) => classData['id'] as String).toList();
    });
  }

  Future<void> _deleteClass(String classId) async {
    try {
      await firebaseService.deleteClass(classId);
      setState(() {}); // Refresh the list after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete class: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    fnameController.dispose();
    lnameController.dispose();
    schoolController.dispose();
    classController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getUserDetails();
    getClassIds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setScreenWidth(context);
    return Scaffold(
        appBar: const CustomAppBar(
          title: TextConstant.editProfile,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: user == null
            ? const Center(child: CircularProgressIndicator())
            : user?.role == RoleEnum.student.enumToString()
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomTextFormField(
                                  width:
                                      (MediaQuery.of(context).size.width - 55) /
                                          2,
                                  controller: fnameController,
                                  padding: const EdgeInsets.only(bottom: 10),
                                  labelText: TextConstant.firstName,
                                  hintText: TextConstant.exampleFirstName,
                                  initialValue: '${user?.firstName}',
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  validator: (value) =>
                                      ValidatorHelper.validateEmpty(
                                          value, TextConstant.firstName),
                                  onChanged: (value) {
                                    setState(() => user?.firstName = value);
                                  },
                                ),
                                const SizedBox(width: 15),
                                CustomTextFormField(
                                  width:
                                      (MediaQuery.of(context).size.width - 55) /
                                          2,
                                  controller: lnameController,
                                  padding: const EdgeInsets.only(bottom: 10),
                                  labelText: TextConstant.lastName,
                                  hintText: TextConstant.exampleLastName,
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  initialValue: '${user?.lastName}',
                                  validator: (value) =>
                                      ValidatorHelper.validateEmpty(
                                          value, TextConstant.lastName),
                                  onChanged: (value) {
                                    setState(() => user?.lastName = value);
                                  },
                                ),
                              ],
                            ),
                            CustomDropdownButton(
                              width: MediaQuery.of(context).size.width - 40,
                              prefixIcon: Icons.person_outlined,
                              hintText: TextConstant.gender,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              defaultItem: user?.gender,
                              items: const ['Female', 'Male'],
                              onItemSelected: (value) {
                                user?.gender = value!;
                              },
                            ),
                            if (user!.gender.isEmpty && updateButtonIsClicked)
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
                              height: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextFormField(
                                    readOnly: true,
                                    prefixIcon:
                                        const Icon(Icons.school_outlined),
                                    controller: schoolController,
                                    labelText: TextConstant.school,
                                    hintText:
                                        '${TextConstant.eg} ${TextConstant.exampleSchool}',
                                    initialValue: user?.school,
                                    validator: (value) =>
                                        ValidatorHelper.validateSchool(
                                            value),
                                    onChanged: (value) {
                                      setState(() => user?.school = value);
                                    },
                                    padding: const EdgeInsets.only(bottom: 10)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextFormField(
                                    readOnly: true,
                                    prefixIcon:
                                        const Icon(Icons.badge_outlined),
                                    controller: teacherController,
                                    labelText: TextConstant.teacherName,
                                    hintText:
                                        '${TextConstant.eg} ${TextConstant.exampleName}',
                                    initialValue: '${user?.teacherName}',
                                    validator: (value) =>
                                        ValidatorHelper.validateEmpty(
                                            value, TextConstant.teacherName),
                                    onChanged: (value) {
                                      setState(() => user?.teacherName = value);
                                    },
                                    padding: const EdgeInsets.only(bottom: 10)),
                              ],
                            ),
                            CustomDropdownButton(
                              enabled: false,
                              width: MediaQuery.of(context).size.width - 40,
                              prefixIcon: Icons.numbers_outlined,
                              hintText: TextConstant.year,
                              defaultItem: user?.year,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              items: const ['1', '2', '3', '4', '5', '6'],
                              onItemSelected: (value) {
                                user?.year = value!;
                              },
                            ),
                            if (user!.year.isEmpty && updateButtonIsClicked)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10.5, 8, 10, 0),
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
                              height: 10,
                            ),
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     CustomTextFormField(
                            //         prefixIcon:
                            //             const Icon(Icons.class_outlined),
                            //         controller: classController,
                            //         labelText: TextConstant.classText,
                            //         initialValue: user?.className,
                            //         hintText:
                            //             '${TextConstant.eg} ${TextConstant.exampleClass}',
                            //         onChanged: (value) {
                            //           setState(() => user?.className = value);
                            //         },
                            //         padding: const EdgeInsets.only(bottom: 10)),
                            //   ],
                            // ),
                            const SizedBox(height: 20),
                            Center(
                              child: SizedBox(
                                width: screenWidth * 40,
                                child: CustomButton(
                                  fontSize: screenWidth * 4,
                                  height: screenWidth * 13,
                                  label: TextConstant.update,
                                  onPressed: () async {
                                    setState(() {
                                      updateButtonIsClicked = true;
                                    });
                                    if (_formKey.currentState!.validate()) {
                                      if (user!.gender.isNotEmpty &&
                                          user!.year.isNotEmpty) {
                                        await firebaseService
                                            .addUserDetails(user!)
                                            .then((_) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 50.0,
                                                    vertical:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.07),
                                                child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.05,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSecondary),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8.0,
                                                              horizontal: 10),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                            '${TextConstant.profileSuccessfullyUpdated}...'),
                                                      ),
                                                    )),
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              duration:
                                                  const Duration(seconds: 2),
                                              backgroundColor: ColorConstant
                                                  .transparentColor,
                                              elevation: 0,
                                            ),
                                          );
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pushNamed(
                                              UserProfilePage.routeName);
                                        }).catchError((error) {
                                          // Handle errors, if any
                                          print(
                                              "Error updating profile: $error");
                                          Navigator.of(context)
                                              .pop(); // Close the loading dialog

                                          // Show an error message or perform additional error handling
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "Failed to updated. Please try again."),
                                              duration:
                                                  const Duration(seconds: 3),
                                            ),
                                          );
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomTextFormField(
                                width:
                                    (MediaQuery.of(context).size.width - 55) /
                                        2,
                                controller: fnameController,
                                padding: const EdgeInsets.only(bottom: 10),
                                labelText: TextConstant.firstName,
                                hintText: TextConstant.exampleFirstName,
                                initialValue: '${user?.firstName}',
                                prefixIcon: const Icon(Icons.badge_outlined),
                                validator: (value) =>
                                    ValidatorHelper.validateEmpty(
                                        value, TextConstant.firstName),
                                onChanged: (value) {
                                  setState(() => user?.firstName = value);
                                },
                              ),
                              const SizedBox(width: 15),
                              CustomTextFormField(
                                width:
                                    (MediaQuery.of(context).size.width - 55) /
                                        2,
                                controller: lnameController,
                                padding: const EdgeInsets.only(bottom: 10),
                                labelText: TextConstant.lastName,
                                hintText: TextConstant.exampleLastName,
                                prefixIcon: const Icon(Icons.badge_outlined),
                                initialValue: '${user?.lastName}',
                                validator: (value) =>
                                    ValidatorHelper.validateEmpty(
                                        value, TextConstant.lastName),
                                onChanged: (value) {
                                  setState(() => user?.lastName = value);
                                },
                              ),
                            ],
                          ),
                          CustomDropdownButton(
                            width: MediaQuery.of(context).size.width - 40,
                            prefixIcon: Icons.person_outlined,
                            hintText: TextConstant.gender,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            defaultItem: user?.gender,
                            items: const ['Female', 'Male'],
                            onItemSelected: (value) {
                              user?.gender = value!;
                            },
                          ),
                          if (user!.gender.isEmpty && updateButtonIsClicked)
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
                            height: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextFormField(
                                  prefixIcon: const Icon(Icons.school_outlined),
                                  controller: schoolController,
                                  labelText: TextConstant.school,
                                  hintText:
                                      '${TextConstant.eg} ${TextConstant.exampleSchool}',
                                  initialValue: user?.school,
                                  validator: (value) =>
                                      ValidatorHelper.validateEmpty(
                                          value, TextConstant.school),
                                  onChanged: (value) {
                                    setState(() => user?.school = value);
                                  },
                                  padding: const EdgeInsets.only(bottom: 10)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextFormField(
                                  readOnly: true,
                                  prefixIcon:
                                      const Icon(Icons.mail_outline_outlined),
                                  controller: emailController,
                                  labelText: TextConstant.school,
                                  hintText:
                                      '${TextConstant.eg} ${TextConstant.email}',
                                  initialValue: user?.email,
                                  validator: (value) =>
                                      ValidatorHelper.validateEmpty(
                                          value, TextConstant.email),
                                  padding: const EdgeInsets.only(bottom: 10)),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: firebaseService.getTeacherClasses(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                      child: Text(TextConstant.noClassFound));
                                } else {
                                  List<Map<String, dynamic>> classes =
                                      snapshot.data!;

                                  return SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            'Class List', // Title text
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: classes.map((classData) {
                                            return Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                              decoration: BoxDecoration(
                                                color: ColorConstant.whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color:
                                                        ColorConstant.greyColor,
                                                    blurRadius: 4,
                                                    offset: Offset(2, 2),
                                                  ),
                                                ],
                                              ),
                                              child: ListTile(
                                                title: Text(classData['id'] ??
                                                    'No Name'), // Ensure the class has a name field
                                                subtitle: Text(classData[
                                                            'year'] !=
                                                        null
                                                    ? 'Year: ${classData['year']}'
                                                    : 'No Description'),
                                                // Ensure the class has a description field
                                                trailing: IconButton(
                                                  icon: Icon(Icons.delete),
                                                  onPressed: () =>
                                                      showDeleteConfirmationDialog(
                                                          context,
                                                          classData['id']),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),

                          const SizedBox(height: 20),
                          Center(
                            child: SizedBox(
                              width: screenWidth * 40,
                              child: CustomButton(
                                fontSize: screenWidth * 4,
                                height: screenWidth * 13,
                                label: TextConstant.update,
                                onPressed: () async {
                                  setState(() {
                                    updateButtonIsClicked = true;
                                  });
                                  if (_formKey.currentState!.validate()) {
                                    if (user!.gender.isNotEmpty &&
                                        user!.year.isNotEmpty) {
                                      await firebaseService
                                          .addUserDetails(user!)
                                          .then((_) async {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 50.0,
                                                  vertical:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.07),
                                              child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSecondary),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8.0,
                                                            horizontal: 10),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                          '${TextConstant.profileSuccessfullyUpdated}...'),
                                                    ),
                                                  )),
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            duration:
                                                const Duration(seconds: 2),
                                            backgroundColor:
                                                ColorConstant.transparentColor,
                                            elevation: 0,
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pushNamed(
                                            UserProfilePage.routeName);
                                      }).catchError((error) {
                                        // Handle errors, if any
                                        print("Error updating profile: $error");
                                        Navigator.of(context)
                                            .pop(); // Close the loading dialog

                                        // Show an error message or perform additional error handling
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Failed to updated. Please try again."),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
  }
}
