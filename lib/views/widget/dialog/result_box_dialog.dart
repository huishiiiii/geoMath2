import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/models/score_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/widget/button/custom_button.dart';

class ResultBoxDialog extends StatelessWidget {
  const ResultBoxDialog({
    Key? key,
    this.classId,
    required this.result,
    required this.questionLength,
    required this.onPressed,
    required this.scoreModel,
  }) : super(key: key);

  final String? classId;
  final int result;
  final int questionLength;
  final VoidCallback onPressed;
  final ScoreModel scoreModel;

  @override
  Widget build(BuildContext context) {
    FirebaseService firebaseService = FirebaseService();

    return AlertDialog(
        backgroundColor: ColorConstant.primaryColor,
        content: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(TextConstant.result,
                    style: TextStyle(
                        color: ColorConstant.blackColor, fontSize: 25.0)),
                const SizedBox(height: 20.0),
                CircleAvatar(
                    radius: 70.0,
                    backgroundColor: result == questionLength / 2
                        ? ColorConstant.yellowColor
                        : result < questionLength / 2
                            ? ColorConstant.redColor
                            : ColorConstant.greenColor,
                    child: Text('$result/$questionLength',
                        style: const TextStyle(
                            color: ColorConstant.whiteColor, fontSize: 22.0))),
                const SizedBox(height: 20.0),
                Text(
                    result == questionLength / 2
                        ? TextConstant.almostThere
                        : result < questionLength / 2
                            ? '${TextConstant.tryAgain} ?'
                            : '${TextConstant.great}!',
                    style: const TextStyle(
                        color: ColorConstant.blackColor, fontSize: 22.0)),
                const SizedBox(height: 25.0),
                CustomButton(
                  label: TextConstant.startOver,
                  onPressed: onPressed,
                ),
                const SizedBox(height: 5.0),
                CustomButton(
                  label: TextConstant.exit,
                  onPressed: () {
                    print("hihiclassid: $classId");
                    if (classId != null) {
                      firebaseService.addScore(scoreModel, classId!);
                    }
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )));
  }
}
