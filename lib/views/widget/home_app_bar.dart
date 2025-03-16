import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomHomeAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(10);

  @override
  PreferredSizeWidget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(10),
      child: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: ColorConstant.transparentColor,
      ),
    );
  }
}
