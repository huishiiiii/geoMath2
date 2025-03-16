import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';

void showCustomSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: ColorConstant.lightBlueColor,
      behavior: SnackBarBehavior.floating,
      content: AutoSizeText(
        message,
        style: const TextStyle(color: ColorConstant.blackColor),
      ),
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 80),
    ),
  );
}
