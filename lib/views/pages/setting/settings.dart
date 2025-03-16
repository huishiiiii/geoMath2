import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/pages/profile/about.dart';
import 'package:geomath/views/pages/setting/change_password.dart';
import 'package:geomath/views/widget/button/custom_menu_button.dart';
import 'package:geomath/views/widget/dialog/delete_account_dialog.dart';

class SettingTabPage extends StatefulWidget {
  static const routeName = 'setting';
  const SettingTabPage({super.key});

  @override
  State<SettingTabPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingTabPage> {
  FirebaseService firebaseService = FirebaseService();

  String classId = '';
  String role = '';

  Future<Map<String, dynamic>> fetchUserDetails(String uid) async {
    return await firebaseService.getUserDetails(uid);
  }

  Future<void> getUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    Map<String, dynamic> userDetails = await fetchUserDetails(user!.uid);

    // Access user details
    setState(() {
      classId = userDetails['classEnrollmentKey'];
      role = userDetails['role'];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    getUserDetails();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CustomScrollView(
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
                  children: <Widget>[
                    // CustomProfileButton(
                    //   prefixIcon: Icons.person_outline,
                    //   buttonText: TextConstant.userProfile,
                    //   onPressed: () => Navigator.of(context)
                    //       .pushNamed(UserProfilePage.routeName),
                    // ),
                    CustomMenuButton(
                      prefixIcon: Icons.lock_open_outlined,
                      buttonText: TextConstant.changePassword,
                      onPressed: () => Navigator.of(context)
                          .pushNamed(ChangePasswordPage.routeName),
                    ),
                    CustomMenuButton(
                      prefixIcon: Icons.help_outline,
                      buttonText: TextConstant.about,
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AboutPage.routeName),
                    ),
                    CustomMenuButton(
                      prefixIcon: Icons.delete_outlined,
                      buttonText: TextConstant.deleteAccount,
                      onPressed: () => showDeleteAccountDialog(context, classId, role),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
