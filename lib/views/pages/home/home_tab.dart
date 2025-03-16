import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/enum/user_enum.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/models/user_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/pages/home/calculator/calculator.dart';
import 'package:geomath/views/pages/home/learn_with_ar/learn_with_ar.dart';
import 'package:geomath/views/pages/unity.dart';
import 'package:geomath/views/widget/dialog/add_new_class_dialog.dart';
import 'package:geomath/views/widget/button/custom_menu_button.dart';

class HomeTabPage extends StatefulWidget {
  static const routeName = 'home_tab';
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  FirebaseService firebaseService = FirebaseService();

  String firstName = '';
  String lastName = '';
  String role = '';
  String gender = '';
  String email = '';

  @override
  void initState() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
              future: firebaseService
                  .getUserDetails(FirebaseAuth.instance.currentUser!.uid),
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
                  return CustomScrollView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    primary: false,
                    slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverGrid.count(
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          crossAxisCount: 3,
                          childAspectRatio: 0.85,
                          children: <Widget>[
                            if (role.toLowerCase() ==
                                RoleEnum.teacher.enumToString().toLowerCase())
                              CustomMenuButton(
                                prefixIcon: Icons.add,
                                buttonText: TextConstant.createNewClass,
                                onPressed: () => showAddNewClassDialog(context),
                              ),
                            CustomMenuButton(
                              prefixIcon: Icons.calculate_outlined,
                              buttonText: TextConstant.calculator,
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(CalculatorPage.routeName),
                            ),
                            CustomMenuButton(
                              prefixIcon: Icons.filter_center_focus_rounded,
                              buttonText: TextConstant.learnWithAr,
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(UnityPage.routeName),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              })
        ],
      ),
    );
  }
}
