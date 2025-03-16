import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/global.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/widget/button/custom_dropdown_button.dart';
import 'package:geomath/views/widget/show_custom_snackbar.dart';

Future<void> showUpdateNewClassDialog(BuildContext context) {
  setScreenWidth(context);
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return const UpdateClassDialog();
    },
  );
}

class UpdateClassDialog extends StatefulWidget {
  const UpdateClassDialog({super.key});

  @override
  State<UpdateClassDialog> createState() => _UpdateClassDialogState();
}

class _UpdateClassDialogState extends State<UpdateClassDialog> {
  FirebaseService firebaseService = FirebaseService();
  List<String> classIds = [];
  final _formKey = GlobalKey<FormState>();
  bool confirmButtonIsClicked = false;
  String classId = '';

  @override
  void initState() {
    getClassIds();
    super.initState();
  }

  Future<void> getClassIds() async {
    List<Map<String, dynamic>> teacherClasses =
        await firebaseService.getTeacherClasses();

    setState(() {
      classIds =
          teacherClasses.map((classData) => classData['id'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('class id: $classIds');
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
                      CustomDropdownButton(
                        width: (MediaQuery.of(context).size.width - 112),
                        prefixIcon: Icons.numbers_outlined,
                        hintText: TextConstant.classId,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        items: classIds,
                        onItemSelected: (value) {
                          classId = value!;
                        },
                      ),
                      if (classId.isEmpty && confirmButtonIsClicked)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10.5, 8, 10, 0),
                          child: Row(
                            children: [
                              Text(
                                '${TextConstant.classId} is Empty',
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
                      if (classId.isEmpty && confirmButtonIsClicked)
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
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
                              showCustomSnackBar(context,
                                  TextConstant.classSuccessfullyCreated);
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
            )));
  }
}
