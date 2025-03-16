import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/helpers/global.dart';
import 'package:geomath/models/note_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/pages/note/view_pdf.dart';
import 'package:geomath/views/widget/app_bar.dart';
import 'package:geomath/views/widget/button/custom_button.dart';

class ViewNotePage extends StatefulWidget {
  static const routeName = 'view_note';
  const ViewNotePage({super.key});

  @override
  State<ViewNotePage> createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
  late NoteModel noteModel;
  FirebaseService firebaseService = FirebaseService();

  String firstName = '';
  String lastName = '';
  String role = '';
  String year = '';
  double? _progress;

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  Future<void> getUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    Map<String, dynamic> userDetails =
        await firebaseService.getUserDetails(user!.uid);

    // Access user details
    setState(() {
      firstName = userDetails['firstname'];
      lastName = userDetails['lastname'];
      role = userDetails['role'];
      year = userDetails['year'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    noteModel = ModalRoute.of(context)!.settings.arguments as NoteModel;
    int yearNum = 7;

    void openPDF(BuildContext context, File file) => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
        );

    if (year.isNotEmpty) {
      yearNum = int.parse(year.trim());
    }

    setScreenWidth(context);
    return Scaffold(
        appBar: CustomAppBar(
          title: noteModel.title,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SingleChildScrollView(
            child: noteModel.noteDetails!['image'] != null
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Image(
                              image:
                                  NetworkImage(noteModel.noteDetails!['image']),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  Text(noteModel.noteDetails!['description'],
                                      textAlign: TextAlign.justify,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      )),
                                  if (noteModel.noteDetails?['volume'] !=
                                          null &&
                                      noteModel.noteDetails!['volume']
                                          .toString()
                                          .isNotEmpty &&
                                      yearNum >= 3)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Text(
                                          'Volume of ${noteModel.title} = ${noteModel.noteDetails!['volume']}',
                                          textAlign: TextAlign.justify,
                                          style: const TextStyle(
                                            fontSize: 16,
                                          )),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(noteModel.noteDetails!['instruction'],
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                  fontSize: 16,
                                )),
                          ),
                          const SizedBox(height: 20),
                          if (noteModel.noteDetails!['fileName'] != "")
                            CustomButton(
                                borderRadius: 10,
                                label: noteModel.noteDetails!['fileName'],
                                onPressed: () async {
                                  print('xixixi');
                                  final String filePath =
                                      '/Notes/${noteModel.classId}/${noteModel.noteDetails!['fileName']}';
                                  final file = await firebaseService
                                      .loadFirebase(filePath);

                                  if (file == null) return;
                                  // ignore: use_build_context_synchronously
                                  openPDF(context, file);
                                })
                        ]),
                  )));
  }
}
