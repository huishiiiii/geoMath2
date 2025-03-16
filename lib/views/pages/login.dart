import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/helpers/validate_helper.dart';
import 'package:geomath/services/auth.dart';
import 'package:geomath/views/pages/register.dart';
import 'package:geomath/views/widget/custom_text_form_field.dart';
import 'package:geomath/views/widget/show_custom_snackbar.dart';

import '../../helpers/asset_helper.dart';
import '../../helpers/color_constant.dart';
import '../../helpers/text_constant.dart';
import '../../helpers/global.dart';
import 'home.dart';
import '../widget/button/custom_button.dart';

class LoginPage extends StatefulWidget {
  static const routeName = 'login';
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  String? password;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signUp(BuildContext context, String email, String password) async {
    User? user =
        await _auth.signInWithEmailAndPassword(context, email, password);

    print('Clicked!!');

    if (user != null) {
      print('User is successfully login');
      emailController.clear();
      passwordController.clear();
      showCustomSnackBar(context, TextConstant.loginSuccessfully);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamed(HomePage.routeName);
    } else {
      print('Some error happen');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setScreenWidth(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(AssetHelper.transparentLogo300),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          TextConstant.geomath.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  TextConstant.login,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: screenWidth * 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  TextConstant.pleaseSignInToContinue,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: screenWidth * 5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 36),
                            CustomTextFormField(
                              controller: emailController,
                              height: screenWidth * 14,
                              labelText: TextConstant.email,
                              hintText: TextConstant.exampleEmail,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: (value) =>
                                  ValidatorHelper.validateEmpty(
                                      value, TextConstant.email),
                            ),
                            CustomTextFormField(
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              padding: const EdgeInsets.only(bottom: 20),
                              labelText: TextConstant.password,
                              hintText: TextConstant.examplePassword,
                              prefixIcon: const Icon(Icons.lock_open_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) =>
                                  ValidatorHelper.validateEmpty(
                                      value, TextConstant.password),
                              onChanged: (value) {
                                setState(() => password = value);
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomButton(
                                    fontSize: screenWidth * 4.5,
                                    height: screenWidth * 12,
                                    label: TextConstant.login,
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        signUp(context, emailController.text,
                                            passwordController.text);
                                      }
                                      // Navigator.of(context)
                                      //     .pushNamed(HomePage.routeName);
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '${TextConstant.dontHaveAnAcc} ',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context)
                            .pushNamed(RegisterPage.routeName),
                        child: const Text(
                          TextConstant.signUp,
                          style: TextStyle(
                            color: ColorConstant.secondaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
