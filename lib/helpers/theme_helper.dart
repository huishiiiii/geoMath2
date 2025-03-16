import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';

class CustomThemeData {
  static ThemeData lightMode = ThemeData(
      canvasColor: ColorConstant.blackColor.withOpacity(0.8),
      fontFamily: 'Ubuntu',
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        background: ColorConstant.primaryColor,
        primary: ColorConstant.secondaryColor,
        tertiary: ColorConstant.darkGreyColor,
        onSecondaryContainer: ColorConstant.greyColor,
        onTertiary: ColorConstant.primaryColor,
        secondary: ColorConstant.oceanBlueColor,
        onSecondary: ColorConstant.darkBlueColor,
        tertiaryContainer: ColorConstant.oceanBlueColor,
        // error: error,
        // onError: onError,
        onBackground: ColorConstant.whiteColor,
        surface: ColorConstant.whiteColor,
        onSurface: ColorConstant.blackColor,
      ));
  static ThemeData darkMode = ThemeData(
      canvasColor: ColorConstant.whiteColor.withOpacity(0.8),
      fontFamily: 'Ubuntu',
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
          background: ColorConstant.darkBlueColor,
          primary: ColorConstant.secondaryColor,
          tertiary: ColorConstant.darkGreyColor,
          onTertiary: Color.fromARGB(255, 0, 111, 201),
          secondary: ColorConstant.lightBlueColor,
          onSecondaryContainer: ColorConstant.whiteColor,
          onSecondary: ColorConstant.primaryColor,
          tertiaryContainer: ColorConstant.darkBlueColor,
          // error: error,
          // onError: onError,
          onBackground: ColorConstant.primaryColor,
          surface: ColorConstant.blackColor,
          onSurface: ColorConstant.whiteColor));
}
