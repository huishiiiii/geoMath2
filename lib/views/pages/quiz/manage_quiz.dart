import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/enum/user_enum.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/pages/quiz/add_new_quiz.dart';
import 'package:geomath/views/widget/button/custom_edit_note_button.dart';

class ManageQuizzesTabPage extends StatefulWidget {
  static const routeName = 'manage_notes';
  final void Function(int, String?)? onTabSelected;
  const ManageQuizzesTabPage({Key? key, this.onTabSelected}) : super(key: key);

  @override
  State<ManageQuizzesTabPage> createState() => _ManageQuizzesTabPageState();
}

class _ManageQuizzesTabPageState extends State<ManageQuizzesTabPage> {
  FirebaseService firebaseService = FirebaseService();
  late Future<List<Map<String, dynamic>>> allNotesFuture;
  late Future<List<Map<String, dynamic>>> classFuture;

  List<String> classIds = [];

  String firstName = '';
  String lastName = '';
  String role = '';
  String gender = '';
  String email = '';

  @override
  void initState() {
    classFuture = firebaseService.getTeacherClasses();
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
      gender = userDetails['gender'];
      email = userDetails['email'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: classFuture,
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
                          return CustomManageNoteButton(
                            prefixIcon: Icons.add, // Change the icon as needed
                            buttonText: TextConstant.addNew,
                            onPressed: () {
                              // Handle custom button press
                              Navigator.of(context)
                                  .pushNamed(AddNewQuizPage.routeName);
                            },
                          );
                        } else {
                          // Use your CustomNoteButton for notes
                          return CustomManageNoteButton(
                            prefixIcon: Icons.edit_note,
                            buttonText: ' ${allClasses[index - 1]['id']}',
                            source: allClasses[index - 1]['source'],
                            onPressed: () {
                              String classId = allClasses[index - 1]['id'];
                              widget.onTabSelected!(10, classId);
                            },
                          );
                        }
                      },
                      childCount: role.toLowerCase() ==
                              RoleEnum.teacher.enumToString().toLowerCase()
                          ? allClasses.length + 1
                          : allClasses.length,
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
