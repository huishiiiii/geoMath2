import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/global.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/helpers/validate_helper.dart';
import 'package:geomath/models/note_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/widget/app_bar.dart';
import 'package:geomath/views/widget/button/custom_button.dart';
import 'package:geomath/views/widget/button/custom_dropdown_button.dart';
import 'package:geomath/views/widget/custom_text_form_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geomath/views/widget/show_custom_snackbar.dart';

class AddNewNotePage extends StatefulWidget {
  static const routeName = 'add_new_note';
  final void Function(int)? onTabSelected;
  const AddNewNotePage({Key? key, this.onTabSelected}) : super(key: key);

  @override
  State<AddNewNotePage> createState() => _AddNewNotePageState();
}

class _AddNewNotePageState extends State<AddNewNotePage> {
  final _formKey = GlobalKey<FormState>();

  String classId = '';
  String firstName = '';
  String lastName = '';
  List<String> classIds = [];
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  FirebaseService firebaseService = FirebaseService();
  bool submitButtonIsClicked = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController instructionController = TextEditingController();
  TextEditingController formulaController = TextEditingController();
  TextEditingController imageController = TextEditingController();

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

  Future<Map<String, dynamic>> fetchUserDetails(String uid) async {
    return await firebaseService.getUserDetails(uid);
  }

  Future<void> getUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    Map<String, dynamic> userDetails = await fetchUserDetails(user!.uid);

    // Access user details
    setState(() {
      firstName = userDetails['firstname'];
      lastName = userDetails['lastname'];
    });
  }

  Future uploadFile() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    Map<String, dynamic> userDetails = await fetchUserDetails(user!.uid);
    NoteModel noteModel;

    String authorName =
        userDetails['firstname'] + ' ' + userDetails['lastname'];

    Map<String, dynamic> classDetails =
        await firebaseService.getClassDetails(classId);

    if (pickedFile != null) {
      final path = 'Notes/$classId/${pickedFile!.name}';
      final file = File(pickedFile!.path!);

      final ref = FirebaseStorage.instance.ref().child(path);
      setState(() {
        uploadTask = ref.putFile(file);
      });

      final snapshot = await uploadTask!.whenComplete(() {
        showCustomSnackBar(context, TextConstant.noteSuccessfullyAdded);
        Navigator.of(context).pop();
      });

      final urlDownload = await snapshot.ref.getDownloadURL();
      print(
          'Download Link: $urlDownload\n classid: $classId\n title: ${titleController.text}\n instruction: ${instructionController.text}\n fileUrl: $urlDownload\n source: $authorName\n year: ${classDetails['year']}');
      noteModel = NoteModel(
          title: titleController.text,
          classId: classId,
          instruction: instructionController.text,
          fileName: pickedFile!.name,
          fileUrl: urlDownload,
          year: classDetails['year'],
          source: authorName);
      firebaseService.addNewNote(noteModel);
    } else {
      noteModel = NoteModel(
          title: titleController.text,
          classId: classId,
          fileName: '',
          fileUrl: '',
          instruction: instructionController.text,
          year: classDetails['year'],
          source: authorName);
      firebaseService.addNewNote(noteModel);
      // ignore: use_build_context_synchronously
      showCustomSnackBar(context, TextConstant.noteSuccessfullyAdded);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Widget buildProgress() => Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: StreamBuilder<TaskSnapshot>(
          stream: uploadTask?.snapshotEvents,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!;
              double progress = data.bytesTransferred / data.totalBytes;
              return SizedBox(
                  height: 20,
                  child: Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    fit: StackFit.expand,
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: ColorConstant.greyColor,
                        color: ColorConstant.greenColor,
                      ),
                      Center(
                        child: Text(
                          '${(100 * progress).roundToDouble()}%',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ));
            } else {
              return const SizedBox(height: 50);
            }
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    setScreenWidth(context);
    return Scaffold(
        appBar: const CustomAppBar(
          title: TextConstant.addNewNote,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            CustomDropdownButton(
                              width: (MediaQuery.of(context).size.width - 40),
                              prefixIcon: Icons.numbers_outlined,
                              hintText: TextConstant.classId,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              items: classIds,
                              onItemSelected: (value) {
                                classId = value!;
                              },
                            ),
                            if (classId.isEmpty && submitButtonIsClicked)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10.5, 8, 10, 0),
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
                            CustomTextFormField(
                              width: (MediaQuery.of(context).size.width - 40),
                              prefixIcon: const Icon(Icons.title_outlined),
                              labelText: TextConstant.title,
                              padding: const EdgeInsets.only(bottom: 20),
                              hintText: '',
                              controller: titleController,
                              validator: (value) =>
                                  ValidatorHelper.validateEmpty(
                                      value, TextConstant.title),
                            ),
                            Container(
                              height:
                                  (MediaQuery.of(context).size.height * 0.15),
                              child: CustomTextFormField(
                                // height:
                                //     (MediaQuery.of(context).size.height * 0.15),
                                width: (MediaQuery.of(context).size.width - 40),
                                prefixIcon: const Icon(Icons.note_outlined),
                                labelText:
                                    '${TextConstant.writeAMessageOrInstruction} (${TextConstant.optional})',
                                padding: const EdgeInsets.only(bottom: 20),
                                hintText: '',
                                controller: instructionController,
                                maxLines: null,
                                textAlignVertical: TextAlignVertical.top,
                              ),
                            ),
                            CustomButton(
                                // fontColor: ColorConstant.blackColor,
                                borderRadius: 5,
                                onPressed: selectFile,
                                label: pickedFile == null
                                    ? TextConstant.uploadFile
                                    : pickedFile!.name),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomButton(
                                    fontSize: screenWidth * 4.5,
                                    height: screenWidth * 12,
                                    label: TextConstant.submit,
                                    onPressed: () {
                                      print('classid: $classId');
                                      setState(() {
                                        submitButtonIsClicked = true;
                                      });

                                      if (_formKey.currentState!.validate() &&
                                          classId.isNotEmpty) {
                                        uploadFile();
                                      }
                                    }),
                              ],
                            ),
                          ],
                        ),
                        buildProgress(),
                      ])),
            )));
  }
}
