import 'package:geomath/helpers/config_helper.dart';
import 'package:geomath/helpers/text_constant.dart';

class ValidatorHelper {
  static String? validateEmpty(String? requiredField, String fieldName) {
    if (requiredField == null || requiredField.trim().isEmpty) {
      return '$fieldName is Empty';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    {
      if (email == null || email.isEmpty) {
        return TextConstant.emailEmpty;
      } else if (!ConfigHelper.emailReg.hasMatch(email)) {
        return TextConstant.emailInvalid;
      }
      return null;
    }
  }

  static String? validatePassword(String? password, String? confirmedPassword) {
    {
      if (password == null || password.isEmpty) {
        return TextConstant.passwordEmpty;
      } else if (password.length < 6) {
        return TextConstant.passwordLength;
      } else if (password != confirmedPassword) {
        return TextConstant.pwdNotMatch;
      }
      return null;
    }
  }

  static String? validateConfirmedPassword(
      String? confirmedPassword, String? password) {
    {
      if (confirmedPassword == null || confirmedPassword.isEmpty) {
        return TextConstant.confirmedPasswordEmpty;
      } else if (confirmedPassword.length < 6) {
        return TextConstant.passwordLength;
      } else if (confirmedPassword != password) {
        return TextConstant.confirmPwdNotMatch;
      }
      return null;
    }
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is empty';
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return 'Name should only contain alphabetic characters and spaces';
    }
    return null;
  }

  static String? validateSchool(String? school) {
    if (school == null || school.isEmpty) {
      return 'School is empty';
    } else if (!RegExp(r'^[a-zA-Z0-9\s\(\)]+$').hasMatch(school)) {
      return 'School should only contain alphabetic characters, numbers, spaces, and parentheses';
    }
    return null;
  }
}
