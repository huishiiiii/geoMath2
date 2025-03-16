import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/enum/user_enum.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/global.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/models/user_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/pages/profile/edit_profile.dart';
import 'package:geomath/views/pages/profile/widget/user_profile_board.dart';
import 'package:geomath/views/pages/progress/progress.dart';
import 'package:geomath/views/widget/app_bar.dart';

class UserProfilePage extends StatefulWidget {
  static const routeName = 'user_profile';
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  FirebaseService firebaseService = FirebaseService();
  late Future<List<Map<String, dynamic>>> allQuizzesResult;
  late Future<List<Map<String, dynamic>>> allClassesResult;

  double numberOfFeatures = 3;
  bool useSides = false;
  int touchedIndex = 0;

  @override
  void initState() {
    allQuizzesResult = firebaseService.getStudentPerformance();
    allClassesResult = firebaseService.getClassPerformance();
    getUserDetails();
    super.initState();
  }

  UserModel? user;

  Future<Map<String, dynamic>> fetchUserDetails(String uid) async {
    return await firebaseService.getUserDetails(uid);
  }

  Future<void> getUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? firebaseUser = auth.currentUser;
    Map<String, dynamic> userDetails =
        await fetchUserDetails(firebaseUser!.uid);

    // Access user details
    setState(() {
      user = UserModel(
          uid: firebaseUser.uid,
          firstName: userDetails['firstname'] ?? '',
          lastName: userDetails['lastname'] ?? '',
          gender: userDetails['gender'] ?? '',
          role: userDetails['role'] ?? '',
          email: userDetails['email'] ?? '',
          classEnrollmentKey: userDetails['classEnrollmentKey'] ?? '',
          year: userDetails['year'] ?? '',
          school: userDetails['school'] ?? '',
          teacherName: userDetails['teacherName'] ?? '',
          image: userDetails['profilePic'] ?? '',
          profilePicture: userDetails['profilePicture'] ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    setScreenWidth(context);
    return Scaffold(
      appBar: CustomAppBar(title: TextConstant.profile, action: [
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () =>
              Navigator.of(context).pushNamed(EditUserProfilePage.routeName),
          icon: const Icon(Icons.edit_square),
        )
      ]),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                UserProfileBoard(user: user!),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                            color: Theme.of(context).colorScheme.surface),
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: (user?.role.toLowerCase() ==
                                    RoleEnum.student
                                        .enumToString()
                                        .toLowerCase())
                                ? FutureBuilder<List<Map<String, dynamic>>>(
                                    future: allQuizzesResult,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  6),
                                          child:
                                              const CircularProgressIndicator(),
                                        )); // Show a loading indicator
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        List<Map<String, dynamic>>
                                            allQuizzesResult =
                                            snapshot.data ?? [];
                                        double sumScore = 0.0;

                                        for (int i = 0;
                                            i < allQuizzesResult.length;
                                            i++) {
                                          if (allQuizzesResult[i]['score'] ==
                                              null) {
                                            allQuizzesResult[i]['score'] = 0;
                                          }
                                          double score = allQuizzesResult[i]
                                                  ['score'] /
                                              allQuizzesResult[i]
                                                  ['numQuestion'] *
                                              100;
                                          sumScore += score;
                                        }

                                        print(
                                            'overall score: ${sumScore / allQuizzesResult.length}');
                                        return Column(children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                    TextConstant
                                                        .overallPerformance,
                                                    style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 6,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        ColorConstant
                                                            .primaryColor,
                                                    radius: 40,
                                                    child: allQuizzesResult
                                                            .isEmpty
                                                        ? const Text('0.0%',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500))
                                                        : Text(
                                                            '${(sumScore / allQuizzesResult.length).toStringAsFixed((sumScore / allQuizzesResult.length).truncateToDouble() == (sumScore / allQuizzesResult.length) ? 0 : 2)}%',
                                                            style: const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Divider(
                                              height: 3,
                                              thickness: 1,
                                              color: ColorConstant.greyColor),
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 30.0,
                                                    vertical: 10),
                                                child: Text(
                                                    TextConstant.quizList,
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount:
                                                  allQuizzesResult.length,
                                              itemBuilder: (context, index) {
                                                Map<String, dynamic> quizData =
                                                    allQuizzesResult[index];
                                                double score = quizData[
                                                        'score'] /
                                                    quizData['numQuestion'] *
                                                    100;
                                                // Customize ListTile as per your data structure
                                                return ListTile(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 15,
                                                          vertical: 8),
                                                  leading: const CircleAvatar(
                                                    backgroundColor:
                                                        ColorConstant
                                                            .transparentColor,
                                                    child: Icon(
                                                        Icons.quiz_outlined,
                                                        color: ColorConstant
                                                            .blackColor),
                                                  ),
                                                  // isThreeLine: true,

                                                  title: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 6.0),
                                                    child: Text(
                                                        quizData['quizName']),
                                                  ), // Replace with your actual data keys
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Correct answered: ${quizData['score']}'),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                          'Total question: ${quizData['numQuestion']}'),
                                                    ],
                                                  ),
                                                  trailing: Text(
                                                    '${score.toStringAsFixed(score.truncateToDouble() == score ? 0 : 2)} %', // Format score based on whether it's an integer or not
                                                    style: const TextStyle(
                                                        fontSize:
                                                            20), // Adjust fontSize as needed
                                                  ), // Example of subtitle
                                                  onTap: () {
                                                    // Handle onTap if needed
                                                  },
                                                );
                                              },
                                            ),
                                          )
                                        ]);
                                      }
                                    })
                                : FutureBuilder<List<Map<String, dynamic>>>(
                                    future: firebaseService
                                        .getClassPerformance(), // Replace with your future function
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    6),
                                            child:
                                                const CircularProgressIndicator(),
                                          ),
                                        ); // Show a loading indicator
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        List<Map<String, dynamic>>
                                            allClassesResult =
                                            snapshot.data ?? [];

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      TextConstant
                                                          .classPerformance,
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 6,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Display each class and its associated students
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount:
                                                    allClassesResult.length,
                                                itemBuilder: (context, index) {
                                                  Map<String, dynamic>
                                                      classData =
                                                      allClassesResult[index];
                                                  List<Map<String, dynamic>>
                                                      students =
                                                      classData['students'];
                                                  double sumScore = 0.0;
                                                  double studentScore = 0.0;

                                                  for (int i = 0;
                                                      i < students.length;
                                                      i++) {
                                                    List<Map<String, dynamic>>
                                                        quizzes =
                                                        classData['students'][i]
                                                            ['quizzes'];
                                                    sumScore = 0.0;
                                                    for (int j = 0;
                                                        j < quizzes.length;
                                                        j++) {
                                                      double score = quizzes[j]
                                                              ['score'] /
                                                          quizzes[j]
                                                              ['numQuestion'] *
                                                          100;
                                                      sumScore += score;
                                                    }
                                                    if (quizzes.isNotEmpty) {
                                                      studentScore += sumScore /
                                                          quizzes.length;
                                                    }
                                                  }

                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              ProgressPage
                                                                  .routeName,
                                                              arguments:
                                                                  allClassesResult[
                                                                      index]);
                                                    },
                                                    child: Card(
                                                      color: ColorConstant
                                                          .primaryColor,
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0,
                                                          vertical: 4.0),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10.0,
                                                                horizontal:
                                                                    20.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Class ID: ${classData['classId']}',
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        8.0),
                                                                Text(
                                                                  'Year: ${classData['classData']['year']}',
                                                                  // Adjust the display of class data as per your requirement
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        3.0),
                                                                Text(
                                                                  'Number of Students: ${students.length}',
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              students.isNotEmpty
                                                                  ? '${(studentScore / students.length).toStringAsFixed((studentScore / students.length).truncateToDouble() == (studentScore / students.length) ? 0 : 2)}%'
                                                                  : '0%',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          20),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ))))
              ],
            ),
    );
  }
}
