import 'dart:math';
import 'package:flutter/material.dart';

class CalculatorController {
  final formKey = GlobalKey<FormState>();
  bool calculateButtonIsClicked = false;

  String type = '';
  String selectedShape = '';
  double height = 0.0;
  double width = 0.0;
  double length = 0.0;
  double radius = 0.0;
  double result = 0.0;

  TextEditingController heightController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController radiusController = TextEditingController();

  String? validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field cannot be empty.';
    }

    // Convert value to double (assuming it's a numeric input)
    try {
      double numericValue = double.parse(value);
      if (numericValue <= 0) {
        return 'Value must be positive and non-zero.';
      }
    } catch (e) {
      return 'Invalid input. Please enter a valid number.';
    }

    return null;
  }

  void calculate() {
    if (formKey.currentState!.validate()) {
      switch (selectedShape) {
        case 'Cube':
          type == 'Volume'
              ? result = length * length * length
              : result = (length * length) * 6;
          break;
        case 'Cuboid':
          type == 'Volume'
              ? result = length * width * height
              : result = 2 * (length * width) +
                  2 * (length * height) +
                  2 * (height * width);
          break;
        case 'Cylinder':
          type == 'Volume'
              ? result = (pi) * radius * radius * height
              : result =
                  (2 * (pi) * radius * height) + (2 * (pi) * radius * radius);
          break;
        case 'Pyramid':
          type == 'Volume'
              ? result = (length * width * height) / 3
              : result = (length * width) +
                  length *
                      (sqrt(
                          (((width / 2) * (width / 2)) + (height * height)))) +
                  width * (sqrt(((1 / 2) * (1 / 2) + (height * height))));
          break;
        case 'Cone':
          type == 'Volume'
              ? result = (pi) * radius * radius * (height / 3)
              : result = (pi) *
                  radius *
                  (radius + sqrt(((height * height) + (radius * radius))));
          break;
        case 'Sphere':
          type == 'Volume'
              ? result = (4 / 3) * pi * radius * radius * radius
              : 4 * (pi) * radius * radius;
          break;
        default:
          return;
      }
    }
  }
}
