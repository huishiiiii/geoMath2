import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/services/auth.dart';
import 'package:geomath/views/widget/show_custom_snackbar.dart';
import '../../helpers/text_constant.dart';
import 'package:geomath/views/pages/home.dart';

class LoginController {
  final AuthService _auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> signIn(
      BuildContext context, GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      User? user = await _auth.signInWithEmailAndPassword(
        context,
        emailController.text,
        passwordController.text,
      );

      if (user != null) {
        emailController.clear();
        passwordController.clear();
        showCustomSnackBar(context, TextConstant.loginSuccessfully);
        Navigator.of(context).pushNamed(HomePage.routeName);
      } else {
        showCustomSnackBar(context, TextConstant.loginFailed);
      }
    }
  }
}
