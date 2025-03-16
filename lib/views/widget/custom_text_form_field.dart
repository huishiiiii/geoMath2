import 'package:flutter/material.dart';
import 'package:geomath/helpers/config_helper.dart';
import 'package:geomath/helpers/text_constant.dart';

import '../../helpers/color_constant.dart';

class CustomTextFormField extends StatefulWidget {
  final bool readOnly;
  final String labelText;
  final String hintText;
  final Icon? prefixIcon;
  final Color focusedIconColor;
  final EdgeInsetsGeometry padding;
  final double? height;
  final double? width;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final IconButton? suffixIcon;
  final TextEditingController controller;
  final String? errorText;
  final String? initialValue;
  final bool useEmailValidator;
  final String? compareValueWith;
  final String? compareErrorText;
  final int? maxLines;
  final TextAlignVertical? textAlignVertical;

  const CustomTextFormField({
    Key? key,
    this.readOnly = false,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.focusedIconColor = ColorConstant.secondaryColor,
    this.padding = const EdgeInsets.only(bottom: 30),
    this.height = 50,
    this.width,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    required this.controller,
    this.errorText,
    this.initialValue,
    this.useEmailValidator = false,
    this.compareValueWith,
    this.compareErrorText,
    this.maxLines = 1,
    this.textAlignVertical,
  }) : super(key: key);

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final TextEditingController _controller = TextEditingController();
  var _noError = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      widget.controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleError(bool value) {
    if ((value && !_noError) || (!value && _noError)) {
      setState(() {
        _noError = value;
      });
    }
  }

  String? _validate(String? value) {
    // When no value
    if (value != null && value.isEmpty) {
      _toggleError(false);
      return widget.errorText;
    } else {
      // Email Validator
      String? errorText;
      if (widget.useEmailValidator) {
        errorText = _validateEmail(value!);
      } else if (widget.compareValueWith != null) {
        errorText = _compareValue(value!);
      }
      // Phone Validator
      // else if (widget.usePhoneValidator) {
      //   errorText = _validatePhone(value!);
      // } else if (widget.useOtpValidator) {
      //   errorText = _validateOtp(value!);
      // }
      if (errorText != null) {
        return errorText;
      }
      // onChanged
      else if (!_noError) {
        _toggleError(true);
        return null;
      }
      return null;
    }
  }

  String? _validateEmail(String value) {
    if (!ConfigHelper.emailReg.hasMatch(value)) {
      _toggleError(false);
      return TextConstant.emailInvalid;
    }
    return null;
  }

  String? _compareValue(String value) {
    if (value != widget.compareValueWith) {
      _toggleError(false);
      return widget.compareErrorText;
    }
    return null;
  }

  // String? _validatePhone(String value) {
  //   var phone = value;
  //   if (!(value.startsWith('0') || value.startsWith(TextHelper.myMobileCode))) {
  //     phone = '${TextHelper.myMobileCode}$value';
  //   }
  //   if (!ConfigHelper.phoneRegExp.hasMatch(phone)) {
  //     _toggleError(false);
  //     return TextHelper.phoneInvalid;
  //   }
  //   return null;
  // }

  // String? _validateOtp(String? value) {
  //   if (value != null) {
  //     final info = ref.read(smsInfoProvider);
  //     if (info != null) {
  //       if (_controller.text != info.otp ||
  //           info.mobile !=
  //               '${TextHelper.myMobileCode}${ref.read(signupInfoProvider).mobile}') {
  //         return TextHelper.wrongOTPCode;
  //       } else if (info.expiryDate != null &&
  //           DateTime.now().compareTo(info.expiryDate!) == 1) {
  //         return TextHelper.otpExpired;
  //       }
  //     } else {
  //       return TextHelper.wrongOTPCode;
  //     }
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Container(
        // height: widget.height,
        width: widget.width,
        // decoration: const BoxDecoration(
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.grey,
        //       blurRadius: 5.0,
        //       offset: Offset(0, 0),
        //     ),
        //   ],
        // ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          cursorColor: widget.focusedIconColor,
          textAlignVertical:
              widget.textAlignVertical ?? TextAlignVertical.center,
          validator: widget.validator,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText == true ? 1 : widget.maxLines,
          expands: widget.obscureText == true || widget.maxLines != null
              ? false
              : true,
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hintText,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: MaterialStateUnderlineInputBorder.resolveWith(
                (Set<MaterialState> states) {
              return const UnderlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(
                    color: ColorConstant.transparentColor,
                  ));
            }),
            focusedBorder: const UnderlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(
                  color: ColorConstant.transparentColor,
                )),
            labelText: widget.labelText,
            labelStyle: const TextStyle(fontSize: 16),
            floatingLabelStyle:
                MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.focused) &&
                  widget.readOnly != true) {
                return TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary);
              }
              return TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.normal,
              );
            }),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            prefixIconColor: MaterialStateColor.resolveWith(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.focused) &&
                    widget.readOnly != true) {
                  return Theme.of(context).colorScheme.secondary;
                } else {
                  return Theme.of(context).colorScheme.onSecondaryContainer;
                }
              },
            ),
            suffixIconColor: MaterialStateColor.resolveWith(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.focused) &&
                    widget.readOnly != true) {
                  return Theme.of(context).colorScheme.secondary;
                } else {
                  return Theme.of(context).colorScheme.onSecondaryContainer;
                }
              },
            ),
          ),
          onTap: () {},
          onChanged: (text) {
            widget.onChanged?.call(text);
          },
        ),
      ),
    );
  }
}
