import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/enum/gender_enum.dart';
import 'package:geomath/helpers/asset_helper.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/views/pages/login.dart';
import 'package:geomath/views/pages/profile/user_profile.dart';

class PopUpProfileButton extends StatelessWidget {
  final String gender;
  String? image;

  PopUpProfileButton({Key? key, required this.gender, this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      clipBehavior: Clip.hardEdge,
      elevation: 50,
      surfaceTintColor: ColorConstant.redColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      offset: const Offset(-10, 0),
      iconSize: 63,
      icon: Ink(
        padding: const EdgeInsets.all(1),
        decoration: const ShapeDecoration(
          color: ColorConstant.whiteColor,
          shape: CircleBorder(),
        ),
        child: image != null
            ? CircleAvatar(
                radius: 45,
                backgroundImage:
                    NetworkImage(image!), // Assuming `image` is a String URL
              )
            : gender == GenderEnum.male.enumToString()
                ? Image.asset(AssetHelper.boyAvatar)
                : Image.asset(AssetHelper.girlAvatar),
      ),
      onSelected: (value) {
        // your logic
      },
      itemBuilder: (BuildContext bc) {
        return [
          PopupMenuItem(
            padding: const EdgeInsets.all(8),
            height: 40,
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Icon(Icons.person_2_outlined),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(TextConstant.profile),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () =>
                Navigator.of(context).pushNamed(UserProfilePage.routeName),
          ),
          PopupMenuItem(
            padding: const EdgeInsets.all(8),
            height: 40,
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Icon(Icons.logout_outlined),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(TextConstant.logout),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamed(LoginPage.routeName);
            },
          ),
        ];
      },
    );
  }
}
