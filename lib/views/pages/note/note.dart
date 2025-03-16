import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/enum/user_enum.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/models/note_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/pages/note/view_note.dart';
import 'package:geomath/views/widget/button/custom_page_button.dart';

class NotePage extends StatefulWidget {
  static const routeName = "note";
  final void Function(int, String?)? onTabSelected;
  const NotePage({Key? key, this.onTabSelected}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  FirebaseService firebaseService = FirebaseService();
  late Future<List<Map<String, dynamic>>> allNotesFuture;
  late Future<List<Map<String, dynamic>>> classNotesFuture = Future.value([]);
  late Future<List<Map<String, dynamic>>> combinedNotesFuture =
      combineFutures();
  Map<String, dynamic>? noteDetails;

  String firstName = '';
  String lastName = '';
  String role = '';
  String gender = '';
  String email = '';
  String classId = '';

  @override
  void initState() {
    allNotesFuture = firebaseService.getAllNotes();
    getUserDetails();

    super.initState();
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
      role = userDetails['role'];
      gender = userDetails['gender'];
      email = userDetails['email'];
      classId = userDetails['classEnrollmentKey'] ?? '';
    });
    classNotesFuture = firebaseService.getClassNotes(classId);
    combinedNotesFuture = combineFutures();
  }

  Future<List<Map<String, dynamic>>> combineFutures() async {
    List<List<Map<String, dynamic>>> results =
        await Future.wait([classNotesFuture, allNotesFuture]);

    // Combine the results into a single list
    List<Map<String, dynamic>> combinedNotes = [];

    for (List<Map<String, dynamic>> notesList in results) {
      for (Map<String, dynamic> note in notesList) {
        combinedNotes.add(note); // Add the note to combinedNotes
        print('ID: ${note['id']}');
      }
    }

    return combinedNotes;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: combinedNotesFuture,
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
            List<Map<String, dynamic>> allNotes = snapshot.data ?? [];
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
                        if (index == 0 &&
                            role.toLowerCase() ==
                                RoleEnum.teacher.enumToString().toLowerCase()) {
                          // Custom button at the beginning
                          return CustomPageButton(
                            prefixIcon: Icons
                                .edit_document, // Change the icon as needed
                            buttonText: TextConstant.manageNotes,
                            onPressed: () {
                              // Handle custom button press
                              widget.onTabSelected!(5, '');
                            },
                          );
                        } else if (role.toLowerCase() ==
                            RoleEnum.teacher.enumToString().toLowerCase()) {
                          // Use your CustomPageButton for notes
                          return CustomPageButton(
                            prefixIcon: Icons.description_outlined,
                            buttonText:
                                '${TextConstant.topic} ${allNotes[index - 1]['id']}',
                            source: allNotes[index - 1]['source'],
                            onPressed: () async {
                              noteDetails =
                                  await firebaseService.getNotesDetails(
                                      allNotes[index - 1]['id'],
                                      classId,
                                      role.toLowerCase());

                              final noteInfo = NoteModel(
                                  title: allNotes[index - 1]['id'],
                                  noteDetails: noteDetails);
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pushNamed(
                                ViewNotePage.routeName,
                                arguments: noteInfo,
                              );
                            },
                          );
                        } else if (role.toLowerCase() ==
                            RoleEnum.student.enumToString().toLowerCase()) {
                          return CustomPageButton(
                            prefixIcon: Icons.description_outlined,
                            buttonText:
                                '${TextConstant.topic} ${allNotes[index]['id']}',
                            source: allNotes[index]['source'],
                            onPressed: () async {
                              noteDetails =
                                  await firebaseService.getNotesDetails(
                                      allNotes[index]['id'],
                                      classId,
                                      role.toLowerCase());
                              print('note Details: $noteDetails');
                              final noteInfo = NoteModel(
                                  title: allNotes[index]['id'],
                                  classId: classId,
                                  noteDetails: noteDetails);
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pushNamed(
                                ViewNotePage.routeName,
                                arguments: noteInfo,
                              );
                            },
                          );
                        }
                        return null;
                      },
                      childCount: role.toLowerCase() ==
                              RoleEnum.teacher.enumToString().toLowerCase()
                          ? allNotes.length + 1
                          : allNotes.length,
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
