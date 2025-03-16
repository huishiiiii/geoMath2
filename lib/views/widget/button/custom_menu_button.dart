import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomMenuButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final IconData prefixIcon;
  const CustomMenuButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
    required this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                    prefixIcon,
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
                  child: AutoSizeText(
                    textAlign: TextAlign.center,
                    buttonText,
                    maxLines: 3,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ));
  }
}
