import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/global.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/helpers/validate_helper.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/widget/app_bar.dart';
import 'package:geomath/views/widget/button/custom_button.dart';
import 'package:geomath/views/widget/custom_text_form_field.dart';

class ChangePasswordPage extends StatefulWidget {
  static const routeName = 'change_password';
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  FirebaseService firebaseService = FirebaseService();

  String currentPassword = '';
  String newPassword = '';
  String confirmedPassword = '';
  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isNewConfirmedPasswordVisible = false;

  TextEditingController currentPassController = TextEditingController();
  TextEditingController newConPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    setScreenWidth(context);
    return Scaffold(
      appBar: const CustomAppBar(
        title: TextConstant.changePassword,
      ),
      backgroundColor: ColorConstant.primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                        prefixIcon: const Icon(Icons.lock_open_outlined),
                        obscureText: !isCurrentPasswordVisible,
                        controller: currentPassController,
                        labelText: TextConstant.currentPassword,
                        hintText:
                            '${TextConstant.eg} ${TextConstant.examplePassword}',
                        suffixIcon: IconButton(
                          icon: Icon(
                            isCurrentPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isCurrentPasswordVisible =
                                  !isCurrentPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) => ValidatorHelper.validateEmpty(
                            value, TextConstant.currentPassword),
                        onChanged: (value) {
                          setState(() => currentPassword = value);
                        },
                        padding: const EdgeInsets.only(bottom: 10)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                        prefixIcon: const Icon(Icons.password_outlined),
                        obscureText: !isNewPasswordVisible,
                        controller: newPassController,
                        labelText: TextConstant.newPassword,
                        hintText:
                            '${TextConstant.eg} ${TextConstant.examplePassword}',
                        suffixIcon: IconButton(
                          icon: Icon(
                            isNewPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isNewPasswordVisible = !isNewPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) => ValidatorHelper.validateEmpty(
                            value, TextConstant.newPassword),
                        onChanged: (value) {
                          setState(() => newPassword = value);
                        },
                        padding: const EdgeInsets.only(bottom: 10)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                        prefixIcon: const Icon(Icons.password_outlined),
                        obscureText: !isNewConfirmedPasswordVisible,
                        controller: newConPassController,
                        labelText: TextConstant.newConfirmedPassword,
                        hintText:
                            '${TextConstant.eg} ${TextConstant.examplePassword}',
                        suffixIcon: IconButton(
                          icon: Icon(
                            isNewConfirmedPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isNewConfirmedPasswordVisible =
                                  !isNewConfirmedPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) => ValidatorHelper.validateEmpty(
                            value, TextConstant.confirmedPassword),
                        onChanged: (value) {
                          setState(() => confirmedPassword = value);
                        },
                        padding: const EdgeInsets.only(bottom: 10)),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: screenWidth * 40,
                    child: CustomButton(
                      fontSize: screenWidth * 4,
                      height: screenWidth * 13,
                      label: TextConstant.update,
                      onPressed: () async {
                        print('newpass: ${newPassController.text}');
                        if (_formKey.currentState!.validate()) {
                          await firebaseService
                              .changePassword(newPassController.text,
                                  currentPassController.text)
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 45.0,
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.07),
                                  child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 10),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              '${TextConstant.passwordSuccessfullyChanged}...'),
                                        ),
                                      )),
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                                backgroundColor: ColorConstant.transparentColor,
                                elevation: 0,
                              ),
                            );
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                          }).catchError((error) {
                            // Handle errors, if any
                            Navigator.of(context)
                                .pop(); // Close the loading dialog

                            // Show an error message or perform additional error handling
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Failed to change password. Please try again."),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
