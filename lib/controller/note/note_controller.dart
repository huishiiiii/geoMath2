import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/models/note_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:file_picker/file_picker.dart';

class NoteController {
  final formKey = GlobalKey<FormState>();

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

  Future<void> getClassIds() async {
    List<Map<String, dynamic>> teacherClasses =
        await firebaseService.getTeacherClasses();

    classIds =
        teacherClasses.map((classData) => classData['id'] as String).toList();
  }

  Future<Map<String, dynamic>> fetchUserDetails(String uid) async {
    return await firebaseService.getUserDetails(uid);
  }

  Future<void> getUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    Map<String, dynamic> userDetails = await fetchUserDetails(user!.uid);

    // Access user details
    firstName = userDetails['firstname'];
    lastName = userDetails['lastname'];
  }

  Future uploadFile(BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    Map<String, dynamic> userDetails = await fetchUserDetails(user!.uid);
    NoteModel noteModel;

    String authorName =
        userDetails['firstname'] + ' ' + userDetails['lastname'];

    Map<String, dynamic> classDetails =
        await firebaseService.getClassDetails(classId);

    final path = 'Notes/$classId/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TextConstant.noteSuccessfullyAdded)),
      );
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
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    pickedFile = result.files.first;
  }

  Widget buildProgress(BuildContext context) => Padding(
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
                        backgroundColor: Colors.grey,
                        color: Colors.green,
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
}
