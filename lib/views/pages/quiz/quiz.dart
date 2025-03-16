import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/enum/user_enum.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/models/quiz_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/pages/quiz/view_quiz_page.dart';
import 'package:geomath/views/widget/button/custom_page_button.dart';

class QuizPage extends StatefulWidget {
  static const routeName = 'quiz';
  final void Function(int, String?)? onTabSelected;
  const QuizPage({Key? key, this.onTabSelected}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  FirebaseService firebaseService = FirebaseService();
  late Future<List<Map<String, dynamic>>> allQuizzesFuture;
  late Future<List<Map<String, dynamic>>> classQuizzesFuture = Future.value([]);
  late Future<List<Map<String, dynamic>>> combinedQuizzesFuture =
      combineFutures();
  Map<String, dynamic>? quizDetails;

  String firstName = '';
  String lastName = '';
  String role = '';
  String gender = '';
  String email = '';
  String classId = '';
  String year = '';

  @override
  void initState() {
    allQuizzesFuture = firebaseService.getAllQuizzes();
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
      year = userDetails['year'] ?? '';
    });
    classQuizzesFuture = firebaseService.getClassQuizzes(classId);
    combinedQuizzesFuture = combineFutures();
  }

  Future<List<Map<String, dynamic>>> combineFutures() async {
    List<List<Map<String, dynamic>>> results =
        await Future.wait([classQuizzesFuture, allQuizzesFuture]);

    // Combine the results into a single list
    List<Map<String, dynamic>> combinedQuizzes = [];

    for (List<Map<String, dynamic>> quizzesList in results) {
      for (Map<String, dynamic> quiz in quizzesList) {
        combinedQuizzes.add(quiz); // Add the quiz to combinedQuizzes
        print('ID: ${quiz['id']}');
      }
    }

    return combinedQuizzes;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: combinedQuizzesFuture,
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
                            buttonText: TextConstant.manageQuizzes,
                            onPressed: () {
                              print("hello");
                              // Handle custom button press
                              widget.onTabSelected!(6, '');
                            },
                          );
                        } else if (role.toLowerCase() ==
                            RoleEnum.teacher.enumToString().toLowerCase()) {
                          // Use your CustomPageButton for quizzes
                          return CustomPageButton(
                            prefixIcon: Icons.quiz_outlined,
                            buttonText: '${allQuizzes[index - 1]['quizname']}',
                            source: allQuizzes[index - 1]['source'],
                            onPressed: () async {
                              quizDetails =
                                  await firebaseService.getQuizzesDetails(
                                      allQuizzes[index - 1]['id'], null);
                              print("quizDetails: $quizDetails");

                              final quizInfo = QuizModel(
                                  quizId: allQuizzes[index - 1]['id'],
                                  title: allQuizzes[index - 1]['quizname'],
                                  quizDetails: quizDetails);
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pushNamed(
                                ViewQuizPage.routeName,
                                arguments: {
                                  'id': allQuizzes[index - 1]['id'],
                                  'quizInfo': quizInfo,
                                },
                              );
                            },
                          );
                        } else if (role.toLowerCase() ==
                            RoleEnum.student.enumToString().toLowerCase()) {
                          // print(
                          //     "allquizzes from firebase: ${allQuizzes[index]}, year = $year");
                          if (allQuizzes[index]['year'] == year) {
                            return CustomPageButton(
                              prefixIcon: Icons.quiz_outlined,
                              buttonText: '${allQuizzes[index]['quizname']}',
                              source: allQuizzes[index]['source'],
                              onPressed: () async {
                                quizDetails =
                                    await firebaseService.getQuizzesDetails(
                                        allQuizzes[index]['id'], classId);

                                print("quizDetails: ${allQuizzes[index]}");
                                final quizInfo = QuizModel(
                                    quizId: allQuizzes[index]['id'],
                                    title: allQuizzes[index]['quizname'],
                                    classId: classId,
                                    quizDetails: quizDetails);
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pushNamed(
                                  ViewQuizPage.routeName,
                                  arguments: {
                                    'id': allQuizzes[index]['id'],
                                    'quizInfo': quizInfo,
                                  },
                                );
                              },
                            );
                          }
                        }
                        return null;
                      },
                      childCount: role.toLowerCase() ==
                              RoleEnum.teacher.enumToString().toLowerCase()
                          ? allQuizzes.length + 1
                          : allQuizzes.length,
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
