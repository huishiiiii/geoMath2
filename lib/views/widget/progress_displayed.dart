import 'package:flutter/material.dart';
import 'package:geomath/helpers/global.dart';
import 'package:geomath/helpers/text_constant.dart';

class ProgressDisplayed extends StatelessWidget {
  const ProgressDisplayed({super.key});

  @override
  Widget build(BuildContext context) {
    setScreenWidth(context);
    return Row(
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '5',
                      style: TextStyle(fontSize: screenWidth * 10),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      TextConstant.quizDone,
                      style: TextStyle(fontSize: screenWidth * 4),
                    )
                  ],
                )),
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(
                        '|',
                        style: TextStyle(fontSize: screenWidth * 10),
                      )
                    ])),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '74%',
                      style: TextStyle(fontSize: screenWidth * 10),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      TextConstant.averageScore,
                      style: TextStyle(fontSize: screenWidth * 4),
                    )
                  ],
                ))
              ],
            );
  }
}