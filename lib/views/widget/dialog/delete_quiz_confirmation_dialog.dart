import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/global.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/models/quiz_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/widget/show_custom_snackbar.dart';

Future<void> showDeleteQuizConfirmationDialog(
    BuildContext context, QuizModel quizModel) {
  FirebaseService firebaseService = FirebaseService();

  print('quizModel: $quizModel');

  setScreenWidth(context);
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(TextConstant.deleteNote,
                      style: TextStyle(fontSize: screenWidth * 6)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    TextConstant.sureWantDeleteNote,
                    style: TextStyle(
                      fontSize: screenWidth * 4.5,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Container(
                    color: ColorConstant.redColor.withOpacity(0.1),
                    padding: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.warning,
                                color: ColorConstant.redColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                TextConstant.warning,
                                style: TextStyle(
                                    color: ColorConstant.redColor,
                                    fontSize: screenWidth * 4.5,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            TextConstant.deleteAccountActionCannotBeUndone,
                            style: TextStyle(
                                color: ColorConstant.redColor,
                                fontSize: screenWidth * 4.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(TextConstant.cancel,
                          style: TextStyle(fontSize: screenWidth * 4.2)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Perform delete action
                        // Add your logic for deleting the account here
                        print("quizModel: $quizModel");
                        firebaseService.deleteQuiz(quizModel);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).maybePop();
                        showCustomSnackBar(
                            context, TextConstant.quizSuccessfullyDeleted);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstant.redColor,
                      ),
                      child: Text(TextConstant.delete,
                          style: TextStyle(fontSize: screenWidth * 4.2)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
