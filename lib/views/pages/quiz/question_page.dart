import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/enum/user_enum.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/models/score_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/widget/app_bar.dart';
import 'package:geomath/views/widget/button/custom_button.dart';
import 'package:geomath/views/widget/dialog/result_box_dialog.dart';
import 'package:geomath/views/widget/option_card.dart';
import 'package:geomath/views/widget/question_widget.dart';
import 'package:geomath/views/widget/show_custom_snackbar.dart';

class QuestionPage extends StatefulWidget {
  static const routeName = 'question';
  const QuestionPage({super.key});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final _formKey = GlobalKey<FormState>();
  FirebaseService firebaseService = FirebaseService();
  late Future<List<Map<String, dynamic>>> allQuestionsFuture;
  List<Map<String, dynamic>> allQuestions = [];
  late ScoreModel scoreModel;

  int index = 0;
  int score = 0;
  String role = '';

  bool isAlreadySelected = false;
  bool isPressed = false;

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  void checkAnswerAndUpdate(bool value) {
    if (isAlreadySelected) {
      return;
    } else {
      if (value == true) {
        score++;
      }
      setState(() {
        isPressed = true;
        isAlreadySelected = true;
      });
    }
  }

  Future<void> getUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    Map<String, dynamic> userDetails =
        await firebaseService.getUserDetails(user!.uid);

    // Access user details
    setState(() {
      role = userDetails['role'];
    });
  }

  void startOver() {
    setState(() {
      index = 0;
      score = 0;
      isPressed = false;
      isAlreadySelected = false;
    });
    Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit the quiz?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final id = args['id'];
    final quizModel = args['quizModel'];
    print('quizModel: $quizModel');

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          title: quizModel.title,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder<List<Map<String, dynamic>>>(
                future:
                    firebaseService.getQuizzesQuestions(id, quizModel.classId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height / 6),
                      child: const CircularProgressIndicator(),
                    )); // Show a loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    allQuestions = snapshot.data ?? [];
                    return Form(
                        key: _formKey,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 30.0),
                                  child: QuestionWidget(
                                      image: allQuestions[index]['image'],
                                      question: allQuestions[index]['question'],
                                      indexAction: index,
                                      totalQuestion:
                                          quizModel.quizDetails['question'],
                                      score: score),
                                ),
                                for (int i = 0;
                                    i < allQuestions[index]['options'].length;
                                    i++)
                                  GestureDetector(
                                    onTap: () => checkAnswerAndUpdate(
                                        allQuestions[index]['options'][i] ==
                                            allQuestions[index]['answer']),
                                    child: OptionCard(
                                      option: allQuestions[index]['options'][i],
                                      color: isPressed
                                          ? allQuestions[index]['options'][i] ==
                                                  allQuestions[index]['answer']
                                              ? ColorConstant.greenColor
                                              : ColorConstant.redColor
                                          : ColorConstant.whiteColor,
                                    ),
                                  )
                              ])
                            ]));
                  }
                })),
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: CustomButton(
            height: 50,
            borderRadius: 10,
            label: TextConstant.nextQuestion,
            fontSize: 16,
            onPressed: () {
              if (index == quizModel.quizDetails['question'] - 1) {
                scoreModel = ScoreModel(
                    quizId: quizModel.quizId,
                    quizName: quizModel.title,
                    numQuestion: quizModel.quizDetails['question'],
                    score: score);
                print("hihi11classid: ${quizModel.classId}");
                print("role: ${role}");
                if (role.toLowerCase() ==
                    RoleEnum.student.enumToString().toLowerCase()) {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (ctx) {
                        print("hihi1classid: ${quizModel.classId}");
                        return ResultBoxDialog(
                          classId: quizModel.classId,
                          result: score,
                          questionLength: allQuestions.length,
                          onPressed: startOver,
                          scoreModel: scoreModel,
                        );
                      });
                } else {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (ctx) => ResultBoxDialog(
                            result: score,
                            questionLength: allQuestions.length,
                            onPressed: startOver,
                            scoreModel: scoreModel,
                          ));
                }
              } else {
                if (isPressed) {
                  setState(() {
                    index++;
                    isPressed = false;
                    isAlreadySelected = false;
                  });
                } else {
                  showCustomSnackBar(context, TextConstant.pleaseSelectOption);
                }
              }
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
