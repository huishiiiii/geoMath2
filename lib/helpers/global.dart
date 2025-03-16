import 'package:flutter/widgets.dart';

double screenWidth = 0.0;

void setScreenWidth(BuildContext context) {
  screenWidth = MediaQuery.of(context).size.width / 100;
}
