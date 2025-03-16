import 'package:flutter/material.dart';
import 'package:geomath/helpers/theme_helper.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = CustomThemeData.lightMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == CustomThemeData.lightMode) {
      themeData = CustomThemeData.darkMode;
    } else if (_themeData == CustomThemeData.darkMode) {
      themeData = CustomThemeData.lightMode;
    }
  }
}
