import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/global.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/helpers/validate_helper.dart';
import 'package:geomath/models/class_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/widget/button/custom_dropdown_button.dart';
import 'package:geomath/views/widget/show_custom_snackbar.dart';
import 'package:geomath/views/widget/custom_text_form_field.dart';

Future<void> showAddNewClassDialog(BuildContext context) {
  setScreenWidth(context);
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return const AddNewClassDialog();
    },
  );
}

class AddNewClassDialog extends StatefulWidget {
  const AddNewClassDialog({super.key});

  @override
  _AddNewClassDialogState createState() => _AddNewClassDialogState();
}

class _AddNewClassDialogState extends State<AddNewClassDialog> {
  FirebaseService firebaseService = FirebaseService();

  late Future<List<Map<String, dynamic>>> allClassEnrollmentKeyFuture;

  final _formKey = GlobalKey<FormState>();
  String userId = '';
  String classEnrollmentKey = '';
  String year = '';
  String teacherName = '';
  String schoolName = '';

  TextEditingController classEnrollmentKeyController = TextEditingController();

  bool confirmButtonIsClicked = false;

  @override
  void initState() {
    allClassEnrollmentKeyFuture = firebaseService.getClassEnrollmentKey();
    getUserDetails();
    super.initState();
  }

  @override
  void dispose() {
    classEnrollmentKeyController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchUserDetails(String uid) async {
    return await firebaseService.getUserDetails(uid);
  }

  Future<void> getUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    Map<String, dynamic> userDetails = await fetchUserDetails(user!.uid);

    // Access user details
    setState(() {
      userId = user.uid;
      teacherName = userDetails['firstname'] + ' ' + userDetails['lastname'];
      schoolName = userDetails['school'];
    });
  }

  @override
  Widget build(BuildContext context) {
    print(teacherName);
    return Dialog(
      backgroundColor: ColorConstant.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(TextConstant.createNewClass,
                      style: TextStyle(fontSize: screenWidth * 6)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TextConstant.enterNewClassDetails,
                    style: TextStyle(
                      fontSize: screenWidth * 4.5,
                    ),
                  ),
                  const SizedBox(height: 25),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: allClassEnrollmentKeyFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List<Map<String, dynamic>> allclassEnrollmentKeys =
                            snapshot.data ?? [];
                        return CustomTextFormField(
                          controller: classEnrollmentKeyController,
                          padding: const EdgeInsets.only(bottom: 20),
                          labelText: TextConstant.classEnrollmentKey,
                          hintText: '',
                          prefixIcon: const Icon(Icons.class_outlined),
                          validator: (value) {
                            // Validate if the field is empty
                            String? emptyValidationMessage =
                                ValidatorHelper.validateEmpty(
                                    value, TextConstant.classEnrollmentKey);
                            if (emptyValidationMessage != null) {
                              // Return the empty validation message if the field is empty
                              return emptyValidationMessage;
                            }

                            // Check if the entered enrollment key exists in the list of enrollment keys
                            bool isEnrollKeyExists = allclassEnrollmentKeys.any(
                                (enrollKeyData) =>
                                    enrollKeyData['id'] == value);
                            if (isEnrollKeyExists) {
                              // Return a message if the entered enrollment key does not exist
                              return 'Enrollment key already exist!';
                            }

                            // Return null if validation passes
                            return null;
                          },
                          onChanged: (value) {
                            bool isEnrollKeyExists = allclassEnrollmentKeys.any(
                                (enrollKeyData) =>
                                    enrollKeyData['id'] == value);
                            if (isEnrollKeyExists) {
                              print('Enrollment key exists!');
                            } else {
                              setState(() => classEnrollmentKey = value);
                              print('Enrollment key does not exist!');
                            }
                          },
                        );
                      }
                    },
                  ),
                  CustomDropdownButton(
                    width: MediaQuery.of(context).size.width - 112,
                    prefixIcon: Icons.numbers_outlined,
                    hintText: TextConstant.year,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    items: const ['1', '2', '3', '4', '5', '6'],
                    onItemSelected: (value) {
                      year = value!;
                    },
                  ),
                  if (year.isEmpty && confirmButtonIsClicked)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.5, 8, 10, 0),
                      child: Row(
                        children: [
                          Text(
                            '${TextConstant.year} is Empty',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: Theme.of(context).colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  // const SizedBox(height: 20.0),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(TextConstant.cancel,
                          style: TextStyle(fontSize: screenWidth * 4.2)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          confirmButtonIsClicked = true;
                        });
                        if (_formKey.currentState!.validate()) {
                          ClassModel classModel = ClassModel(
                              userId: userId,
                              classEnrollmentKey: classEnrollmentKey,
                              year: year,
                              teacherName: teacherName,
                              schoolName: schoolName);

                          firebaseService.addClassEnrollmentKey(classModel);
                          showCustomSnackBar(
                              context, TextConstant.classSuccessfullyCreated);
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstant.darkBlueColor,
                      ),
                      child: Text(TextConstant.confirm,
                          style: TextStyle(fontSize: screenWidth * 4.2)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
