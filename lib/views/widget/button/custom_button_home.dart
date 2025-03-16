import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geomath/helpers/global.dart';

class HomeCustomButton extends StatelessWidget {
  final String buttonText;
  final double? fontSize;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final bool isTextButton;
  final double borderRadius;
  final bool capitalText;
  final bool textBold;
  final Color? buttonColor;
  final Color? textColor;
  const HomeCustomButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.fontSize,
    this.fullWidth = true,
    this.isTextButton = false,
    this.borderRadius = 15,
    this.capitalText = true,
    this.buttonColor,
    this.textColor,
    this.textBold = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    setScreenWidth(context);
    if (isTextButton) {
      return SizedBox(
        width: 150,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            onPressed: onPressed,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: AutoSizeText(
                capitalText ? buttonText.toUpperCase() : buttonText,
                maxLines: 1,
                stepGranularity: 0.1,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: textBold ? FontWeight.bold : null,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
