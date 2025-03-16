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
import 'package:geomath/views/widget/dialog/delete_note_confirmation_dialog.dart';
import 'package:geomath/views/widget/show_custom_snackbar.dart';

class UpdateNotePage extends StatefulWidget {
  static const routeName = 'update_note';
  final void Function(int, String?)? onTabSelected;
  const UpdateNotePage({Key? key, this.onTabSelected}) : super(key: key);

  @override
  State<UpdateNotePage> createState() => _UpdateNotePageState();
}

class _UpdateNotePageState extends State<UpdateNotePage> {
  final _formKey = GlobalKey<FormState>();

  late Future<List<Map<String, dynamic>>> teacherClasses;

  late NoteModel noteModel;

  String classId = '';
  String firstName = '';
  String lastName = '';
  List<String> classIds = [];
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  FirebaseService firebaseService = FirebaseService();
  bool submitButtonIsClicked = false;
  bool changed = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController instructionController = TextEditingController();
  TextEditingController formulaController = TextEditingController();
  TextEditingController imageController = TextEditingController();

  @override
  void initState() {
    teacherClasses = firebaseService.getTeacherClasses();
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

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
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
      );

  @override
  Widget build(BuildContext context) {
    noteModel = ModalRoute.of(context)!.settings.arguments as NoteModel;
    String oldTitle = '';
    String oldClassId = '';
    oldTitle = noteModel.noteDetails?['title'];
    oldClassId = noteModel.classId!;

    Future uploadFile() async {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      Map<String, dynamic> userDetails = await fetchUserDetails(user!.uid);
      String urlDownload;

      String authorName =
          userDetails['firstname'] + ' ' + userDetails['lastname'];

      Map<String, dynamic> classDetails =
          await firebaseService.getClassDetails(classId);

      if (pickedFile != null) {
        final path = 'Notes/$classId/${pickedFile?.name}';
        final file = File(pickedFile!.path!);

        final ref = FirebaseStorage.instance.ref().child(path);
        setState(() {
          uploadTask = ref.putFile(file);
        });

        final snapshot = await uploadTask!.whenComplete(() {
          Navigator.of(context).pop(true);
        });

        urlDownload = await snapshot.ref.getDownloadURL();
        oldTitle = noteModel.noteDetails?['title'];
        oldClassId = noteModel.classId!;

        noteModel = NoteModel(
            title: titleController.text,
            classId: classId,
            instruction: instructionController.text,
            fileName: pickedFile?.name,
            fileUrl: urlDownload,
            year: classDetails['year'],
            source: authorName);

        firebaseService.updateNote(noteModel, oldTitle, oldClassId);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, TextConstant.noteSuccessfullyUpdated);
      } else {
        oldTitle = noteModel.noteDetails?['title'];
        oldClassId = noteModel.classId!;

        noteModel = NoteModel(
            title: titleController.text,
            classId: classId,
            instruction: instructionController.text,
            fileName: noteModel.noteDetails!['fileName'],
            fileUrl: noteModel.noteDetails!['fileUrl'],
            year: classDetails['year'],
            source: authorName);

        firebaseService.updateNote(noteModel, oldTitle, oldClassId);
        showCustomSnackBar(context, TextConstant.noteSuccessfullyUpdated);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        Navigator.of(context).maybePop();

        // Navigator.of(context).pushNamed(HomePage.routeName);
        // Navigator.of(context).pop(0);
      }
    }

    void checkSubmit() {
      if (classId == noteModel.classId &&
          noteModel.noteDetails?['title'] == titleController.text.trim() &&
          noteModel.noteDetails?['instruction'] ==
              instructionController.text.trim() &&
          (pickedFile == null ||
              pickedFile!.name == noteModel.noteDetails?['fileName'])) {
        changed = false;
      } else {
        changed = true;
      }
    }

    Future selectFile() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) return;

      setState(() {
        pickedFile = result.files.first;
        checkSubmit();
      });
    }

    setScreenWidth(context);
    return Scaffold(
        appBar: CustomAppBar(title: TextConstant.updateNote, action: [
          IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () {
                showDeleteNoteConfirmationDialog(
                    context, noteModel, oldTitle, oldClassId);
                // firebaseService.deleteNote(noteModel, oldTitle, oldClassId);
              }),
        ]),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: teacherClasses,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height / 6),
                        child: const CircularProgressIndicator(),
                      )); // Show a loading indicator
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Form(
                          key: _formKey,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    CustomDropdownButton(
                                      defaultItem: noteModel.classId,
                                      width:
                                          (MediaQuery.of(context).size.width -
                                              40),
                                      prefixIcon: Icons.numbers_outlined,
                                      hintText: TextConstant.classId,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      items: classIds,
                                      onItemSelected: (value) {
                                        classId = value!;
                                        checkSubmit();
                                      },
                                    ),
                                    if (classId.isEmpty &&
                                        submitButtonIsClicked)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10.5, 8, 10, 0),
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
                                      initialValue:
                                          noteModel.noteDetails!['title'],
                                      width:
                                          (MediaQuery.of(context).size.width -
                                              40),
                                      prefixIcon:
                                          const Icon(Icons.title_outlined),
                                      labelText: TextConstant.title,
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      hintText: '',
                                      controller: titleController,
                                      onChanged: (value) {
                                        checkSubmit();
                                      },
                                      validator: (value) =>
                                          ValidatorHelper.validateEmpty(
                                              value, TextConstant.title),
                                    ),
                                    Container(
                                      height:
                                          (MediaQuery.of(context).size.height *
                                              0.15),
                                      child: CustomTextFormField(
                                        initialValue: noteModel
                                            .noteDetails!['instruction'],
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                40),
                                        prefixIcon:
                                            const Icon(Icons.note_outlined),
                                        labelText:
                                            '${TextConstant.writeAMessageOrInstruction} (${TextConstant.optional})',
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        hintText: '',
                                        controller: instructionController,
                                        onChanged: (value) {
                                          checkSubmit();
                                        },
                                        maxLines: null,
                                        textAlignVertical:
                                            TextAlignVertical.top,
                                      ),
                                    ),
                                    CustomButton(
                                        borderRadius: 5,
                                        onPressed: selectFile,
                                        label: pickedFile == null
                                            ? (noteModel
                                                    .noteDetails!['fileName']
                                                    .isEmpty
                                                ? TextConstant.uploadFile
                                                : noteModel
                                                    .noteDetails!['fileName'])
                                            : pickedFile!.name),
                                    const SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        CustomButton(
                                            enabled: changed,
                                            fontSize: screenWidth * 4.5,
                                            height: screenWidth * 12,
                                            label: TextConstant.submit,
                                            onPressed: () {
                                              setState(() {
                                                submitButtonIsClicked = true;
                                              });

                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  classId.isNotEmpty) {
                                                uploadFile();
                                              }
                                            }),
                                      ],
                                    ),
                                  ],
                                ),
                                buildProgress(),
                              ]));
                    }
                    ;
                  }),
            )));
  }
}
