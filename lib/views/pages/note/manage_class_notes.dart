import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/models/note_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/pages/note/update_note.dart';
import 'package:geomath/views/widget/button/custom_edit_note_button.dart';

import 'dart:async';

class ManageClassNotesTabPage extends StatefulWidget {
  static const routeName = 'manage_class_notes';
  final void Function(int, String?)? onTabSelected;
  final String classId;
  const ManageClassNotesTabPage(
      {Key? key, this.onTabSelected, required this.classId})
      : super(key: key);

  @override
  State<ManageClassNotesTabPage> createState() => _ManageClassNotesPageState();
}

class _ManageClassNotesPageState extends State<ManageClassNotesTabPage> {
  FirebaseService firebaseService = FirebaseService();
  late StreamController<List<Map<String, dynamic>>> _classController;
  late Stream<List<Map<String, dynamic>>> _classStream;

  List<String> classIds = [];
  Map<String, dynamic>? noteDetails;

  String firstName = '';
  String lastName = '';
  String role = '';
  String gender = '';
  String email = '';

  @override
  void initState() {
    _classController = StreamController<List<Map<String, dynamic>>>();
    _classStream = _classController.stream;
    fetchClassNotes();
    getUserDetails();
    super.initState();
  }

  @override
  void dispose() {
    _classController.close();
    super.dispose();
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
      gender = userDetails['gender'];
      email = userDetails['email'];
    });
  }

  Future<void> fetchClassNotes() async {
    try {
      List<Map<String, dynamic>> classNotes =
          await firebaseService.getTeacherNotes(widget.classId);
      _classController.add(classNotes);
    } catch (error) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _classStream,
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
            List<Map<String, dynamic>> allClasses = snapshot.data ?? [];
            if (allClasses.isEmpty) {
              return Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 6),
                  const Center(
                    child: Icon(Icons.clear,
                        size: 55,
                        color:
                            ColorConstant.redColor // Adjust the size as needed
                        ),
                  ),
                  const Center(
                    child: Text(TextConstant.noNotesFound),
                  ),
                ],
              );
            } else {
              return CustomScrollView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                primary: false,
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Set the number of columns
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return CustomManageNoteButton(
                            prefixIcon: Icons.edit_note,
                            buttonText: ' ${allClasses[index]['id']}',
                            source: allClasses[index]['source'],
                            onPressed: () async {
                              noteDetails =
                                  await firebaseService.getTeacherNoteDetails(
                                      widget.classId, allClasses[index]['id']);

                              final noteInfo = NoteModel(
                                  classId: widget.classId,
                                  title: allClasses[index]['id'],
                                  noteDetails: noteDetails);
                              final result =
                                  // ignore: use_build_context_synchronously
                                  await Navigator.of(context).pushNamed(
                                UpdateNotePage.routeName,
                                arguments: noteInfo,
                              );

                              if (result != null && result == true) {
                                fetchClassNotes();
                              }
                            },
                          );
                        },
                        childCount: allClasses.length,
                      ),
                    ),
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }
}
