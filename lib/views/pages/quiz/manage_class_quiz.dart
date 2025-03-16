import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/models/quiz_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/pages/quiz/update_quiz.dart';
import 'package:geomath/views/widget/button/custom_edit_note_button.dart';

import 'dart:async';

class ManageClassQuizTabPage extends StatefulWidget {
  static const routeName = 'manage_class_notes';
  final void Function(int, String?)? onTabSelected;
  final String classId;
  const ManageClassQuizTabPage(
      {Key? key, this.onTabSelected, required this.classId})
      : super(key: key);

  @override
  State<ManageClassQuizTabPage> createState() => _ManageClassQuizTabPageState();
}

class _ManageClassQuizTabPageState extends State<ManageClassQuizTabPage> {
  FirebaseService firebaseService = FirebaseService();
  late StreamController<List<Map<String, dynamic>>> _classController;
  late Stream<List<Map<String, dynamic>>> _quizStream;

  List<String> classIds = [];
  Map<String, dynamic>? quizDetails;
  List<Map<String, dynamic>>? questionsDetails;

  String firstName = '';
  String lastName = '';
  String role = '';
  String gender = '';
  String email = '';

  @override
  void initState() {
    _classController = StreamController<List<Map<String, dynamic>>>();
    _quizStream = _classController.stream;
    fetchClassQuizzes();
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

  Future<void> fetchClassQuizzes() async {
    try {
      List<Map<String, dynamic>> classNotes =
          await firebaseService.getTeacherQuizzes(widget.classId);
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
        stream: _quizStream,
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
            List<Map<String, dynamic>> allQuizzes = snapshot.data ?? [];
            if (allQuizzes.isEmpty) {
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
                    child: Text(TextConstant.noQuizzesFound),
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
                            buttonText: ' ${allQuizzes[index]['quizname']}',
                            source: allQuizzes[index]['source'],
                            onPressed: () async {
                              quizDetails =
                                  await firebaseService.getTeacherQuizDetails(
                                      widget.classId, allQuizzes[index]['id']);
                              questionsDetails = await firebaseService
                                  .getTeacherQuizQuestionDetails(
                                      widget.classId, allQuizzes[index]['id']);

                              // final noteInfo = NoteModel(
                              //     classId: widget.classId,
                              //     title: allQuizzes[index]['id'],
                              //     noteDetails: noteDetails);
                              final quizInfo = QuizModel(
                                  classId: widget.classId,
                                  quizId: allQuizzes[index]['id'],
                                  title: allQuizzes[index]['quizname'],
                                  quizDetails: quizDetails,
                                  questionDetails: questionsDetails);
                              final result =
                                  // ignore: use_build_context_synchronously
                                  await Navigator.of(context).pushNamed(
                                UpdateQuizPage.routeName,
                                arguments: quizInfo,
                              );

                              if (result != null && result == true) {
                                fetchClassQuizzes();
                              }
                            },
                          );
                        },
                        childCount: allQuizzes.length,
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
