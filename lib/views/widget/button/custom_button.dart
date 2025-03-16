import 'package:flutter/material.dart';

import '../../../helpers/color_constant.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final Color buttonColor;
  final bool enabled;
  final Color? fontColor;
  final double borderRadius;
  final double? height;
  final double? width;
  final double? fontSize;
  final VoidCallback? onPressed;
  const CustomButton(
      {Key? key,
      required this.label,
      required this.onPressed,
      this.enabled = true,
      this.height,
      this.width,
      this.fontSize,
      this.fontColor,
      this.buttonColor = ColorConstant.secondaryColor,
      this.borderRadius = 40})
      : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isTextOverflow(String text, TextStyle style, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: maxWidth);

    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final isOverflow = isTextOverflow(
        widget.label,
        const TextStyle(fontSize: 16.0),
        (MediaQuery.of(context).size.width - 60));

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          enableFeedback: widget.enabled,
          backgroundColor: widget.buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
        onPressed: widget.enabled ? widget.onPressed : null,
        child: widget.label.toLowerCase() == 'login' ||
                widget.label.toLowerCase() == 'sign up'
            ? Row(
                children: [
                  Text(widget.label.toUpperCase(),
                      style: TextStyle(fontSize: widget.fontSize)),
                  Container(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: const Icon(Icons.arrow_right_outlined, size: 30),
                  )
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isOverflow
                      ? Expanded(
                          child: Text(
                            widget.label,
                            style: TextStyle(
                                fontSize: widget.fontSize,
                                color: widget.fontColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : Text(widget.label.toUpperCase(),
                          style: TextStyle(
                              fontSize: widget.fontSize,
                              color: widget.fontColor)),
                ],
              ),
      ),
    );
  }
}
