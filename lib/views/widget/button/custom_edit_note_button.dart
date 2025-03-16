import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class CustomManageNoteButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final IconData prefixIcon;
  final String? source;
  const CustomManageNoteButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
    required this.prefixIcon,
    this.source,
  }) : super(key: key);

  @override
  State<CustomManageNoteButton> createState() => _CustomManageNoteButtonState();
}

class _CustomManageNoteButtonState extends State<CustomManageNoteButton> {
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
        widget.buttonText,
        const TextStyle(fontSize: 16.0),
        (MediaQuery.of(context).size.width - 76) / 3);

    return ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          padding: const EdgeInsets.only(top: 16.0),
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.prefixIcon,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: isOverflow
                      ? Marquee(
                          text: widget.buttonText,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          scrollAxis: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          blankSpace: 20.0,
                          velocity: 30.0,
                          pauseAfterRound: const Duration(seconds: 1),
                          accelerationDuration: const Duration(seconds: 1),
                          accelerationCurve: Curves.linear,
                          decelerationDuration: const Duration(milliseconds: 500),
                          decelerationCurve: Curves.easeOut,
                        )
                      : AutoSizeText(
                          textAlign: TextAlign.center,
                          widget.buttonText,
                          maxLines: 2,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                ),
              ),
            ),
            if (widget.source != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AutoSizeText(
                          textAlign: TextAlign.center,
                          'by ${widget.source}',
                          minFontSize: 9,
                          maxLines: 2,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (widget.source == null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AutoSizeText(
                          textAlign: TextAlign.center,
                          '',
                          minFontSize: 8,
                          maxLines: 2,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ));
  }
}
