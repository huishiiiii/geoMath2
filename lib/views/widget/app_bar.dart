import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/global.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextStyle? textStyle;
  final List<Widget>? action;
  final Color? backgroundColor;
  final IconThemeData? iconThemeData;
  const CustomAppBar(
      {Key? key, required this.title, this.textStyle, this.action, this.backgroundColor, this.iconThemeData})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  PreferredSizeWidget build(BuildContext context) {
    setScreenWidth(context);
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: backgroundColor ?? ColorConstant.transparentColor,
      title: Text(
        title.toUpperCase(),
        style: textStyle ??TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: screenWidth * 5),
      ),
      actions: action != null ? action! : [],
      iconTheme: iconThemeData??IconThemeData(color: Theme.of(context).colorScheme.onSurface),
    );
  }
}
