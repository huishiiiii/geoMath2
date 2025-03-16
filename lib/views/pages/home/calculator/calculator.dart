import 'package:flutter/material.dart';
import 'package:geomath/helpers/asset_helper.dart';
import 'package:geomath/views/widget/button/custom_button.dart';
import 'package:geomath/views/widget/button/custom_calculator_dropdown_button.dart';
import 'package:geomath/views/widget/custom_text_form_field.dart';
import 'package:geomath/controller/calculator/calculator_controller.dart'; // Import the controller

import '../../../../helpers/color_constant.dart';
import '../../../../helpers/text_constant.dart';
import '../../../widget/app_bar.dart';

class CalculatorPage extends StatefulWidget {
  static const routeName = 'calculator';
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final CalculatorController _controller = CalculatorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: TextConstant.calculator,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Calculation Type: ',
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomCalculatorDropdownButton(
                            hintText: 'Select',
                            items: const [
                              TextConstant.volume,
                              TextConstant.surfaceArea
                            ],
                            onItemSelected: (value) {
                              setState(() {
                                _controller.type = value;
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                if (_controller.type.isEmpty &&
                    _controller.calculateButtonIsClicked)
                  Row(
                    children: [
                      const Expanded(
                          flex: 2,
                          child: Column(
                            children: [SizedBox()],
                          )),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 10, 0),
                              child: Row(
                                children: [
                                  Text(
                                    '${TextConstant.field} is Empty',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Text(
                            'Shape that you want to calculate: ',
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface),
                            textAlign: TextAlign.end,
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          CustomCalculatorDropdownButton(
                            hintText: 'Select',
                            items: const [
                              'Cube',
                              'Cuboid',
                              'Pyramid',
                              'Cone',
                              'Sphere',
                              'Cylinder'
                            ],
                            onItemSelected: (shape) {
                              setState(() {
                                _controller.selectedShape = shape;
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                if (_controller.selectedShape.isEmpty &&
                    _controller.calculateButtonIsClicked)
                  Row(
                    children: [
                      const Expanded(
                          flex: 2,
                          child: Column(
                            children: [SizedBox()],
                          )),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 10, 0),
                              child: Row(
                                children: [
                                  Text(
                                    '${TextConstant.field} is Empty',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (_controller.selectedShape.toLowerCase() == 'cube')
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Image.asset(AssetHelper.cube)),
                      ),
                    ],
                  ),
                if (_controller.selectedShape.toLowerCase() == 'cuboid')
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Image.asset(AssetHelper.cuboid),
                      ),
                    ],
                  ),
                if (_controller.selectedShape.toLowerCase() == 'pyramid')
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Image.asset(AssetHelper.pyramid),
                      ),
                    ],
                  ),
                if (_controller.selectedShape.toLowerCase() == 'cone')
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Image.asset(AssetHelper.cone),
                      ),
                    ],
                  ),
                if (_controller.selectedShape.toLowerCase() == 'cylinder')
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Image.asset(AssetHelper.cylinder),
                      ),
                    ],
                  ),
                if (_controller.selectedShape.toLowerCase() == 'sphere')
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Image.asset(AssetHelper.sphere),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (_controller.selectedShape.toLowerCase() != 'sphere' &&
                    _controller.selectedShape.toLowerCase() != 'cube' &&
                    _controller.selectedShape.isNotEmpty)
                  Column(
                    children: [
                      CustomTextFormField(
                        prefixIcon: const Icon(Icons.arrow_upward),
                        controller: _controller.heightController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        hintText: '${TextConstant.eg} 40.0',
                        labelText: '${TextConstant.height} (cm)',
                        height: 35,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        validator: _controller.validateInput,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _controller.height = double.parse(value);
                          }
                        },
                      ),
                    ],
                  ),
                if (_controller.selectedShape.toLowerCase() == 'cuboid' ||
                    _controller.selectedShape.toLowerCase() == 'pyramid' &&
                        _controller.selectedShape.isNotEmpty)
                  Column(
                    children: [
                      CustomTextFormField(
                        prefixIcon: const Icon(Icons.arrow_outward),
                        controller: _controller.widthController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        hintText: '${TextConstant.eg} 30.0',
                        labelText: '${TextConstant.width} (cm)',
                        height: 35,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        validator: _controller.validateInput,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _controller.width = double.parse(value);
                          }
                        },
                      ),
                    ],
                  ),
                if (_controller.selectedShape.toLowerCase() == 'sphere' ||
                    _controller.selectedShape.toLowerCase() == 'cone' ||
                    _controller.selectedShape.toLowerCase() == 'cylinder' &&
                        _controller.selectedShape.isNotEmpty)
                  Column(
                    children: [
                      CustomTextFormField(
                        prefixIcon: const Icon(Icons.arrow_forward),
                        controller: _controller.radiusController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        hintText: '${TextConstant.eg} 40.0',
                        labelText: '${TextConstant.radius} (cm)',
                        height: 35,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        validator: _controller.validateInput,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _controller.radius = double.parse(value);
                          }
                        },
                      ),
                    ],
                  ),
                if (_controller.selectedShape.toLowerCase() != 'sphere' &&
                    _controller.selectedShape.toLowerCase() != 'cone' &&
                    _controller.selectedShape.toLowerCase() != 'cylinder' &&
                    _controller.selectedShape.isNotEmpty)
                  Column(
                    children: [
                      CustomTextFormField(
                        prefixIcon: const Icon(
                          Icons.arrow_forward,
                        ),
                        controller: _controller.lengthController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        hintText: '${TextConstant.eg} 1.45',
                        labelText: '${TextConstant.length} (cm)',
                        height: 35,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        validator: _controller.validateInput,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _controller.length = double.parse(value);
                          }
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
                if (_controller.result != 0.0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Result = ${_controller.result} cm',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
                SizedBox(
                    width: 120,
                    child: CustomButton(
                      label: TextConstant.calculate,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _controller.calculateButtonIsClicked = true;
                        });
                        if (_controller.formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50.0,
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.07),
                                child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 10),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text('Calculating...')),
                                    )),
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                              backgroundColor: ColorConstant.transparentColor,
                              elevation: 0,
                            ),
                          );
                          setState(() {
                            _controller.calculate();
                          });
                        }
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
