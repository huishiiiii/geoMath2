import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/helpers/global.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/helpers/validate_helper.dart';
import 'package:geomath/models/quiz_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/widget/app_bar.dart';
import 'package:geomath/views/widget/button/custom_button.dart';
import 'package:geomath/views/widget/button/custom_dropdown_button.dart';
import 'package:geomath/views/widget/custom_text_form_field.dart';
import 'package:geomath/views/widget/show_custom_snackbar.dart';

class AddNewQuizPage extends StatefulWidget {
  static const routeName = 'add_new_quiz';
  final void Function(int)? onTabSelected;
  const AddNewQuizPage({Key? key, this.onTabSelected}) : super(key: key);

  @override
  State<AddNewQuizPage> createState() => _AddNewQuizPageState();
}

class _AddNewQuizPageState extends State<AddNewQuizPage> {
  final _formKey = GlobalKey<FormState>();
  FirebaseService firebaseService = FirebaseService();

  String classId = '';
  String year = '';
  String firstName = '';
  String lastName = '';
  List<String> classIds = [];
  int numberOfQuestions = 0;
  List<TextEditingController> questionControllers = [];

  bool submitButtonIsClicked = false;

  TextEditingController quizNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController numQuestionController = TextEditingController();
  List<TextEditingController> answerControllers = [];
  List<List<TextEditingController>> optionControllers = [];

  @override
  void initState() {
    getClassIds();
    super.initState();
  }

  Future<void> getClassIds() async {
    List<Map<String, dynamic>> teacherClasses =
        await firebaseService.getTeacherClasses();

    setState(() {
      classIds =
          teacherClasses.map((classData) => classData['id'] as String).toList();
    });
  }

  Future<Map<String, dynamic>> fetchUserDetails(String uid) async {
    return await firebaseService.getUserDetails(uid);
  }

  Future<void> getUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    Map<String, dynamic> userDetails = await fetchUserDetails(user!.uid);

    // Access user details
    setState(() {
      firstName = userDetails['firstname'];
      lastName = userDetails['lastname'];
    });
  }

  @override
  void dispose() {
    numQuestionController.dispose();
    for (var controller in questionControllers) {
      controller.dispose();
    }
    for (var controller in answerControllers) {
      controller.dispose();
    }
    for (var controllers in optionControllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _addOptionField(int questionIndex) {
    List<TextEditingController> controllers = optionControllers[questionIndex];

    controllers.removeWhere((controller) => controller.text.trim().isEmpty);

    if (controllers.every((controller) => controller.text.trim().isNotEmpty)) {
      setState(() {
        controllers.add(TextEditingController());
      });
    }
  }

  bool isAtLeastOneOptionAnswered(
      List<List<TextEditingController>> optionsControllers,
      List<TextEditingController> answerControllers) {
    for (int i = 0; i < optionsControllers.length; i++) {
      TextEditingController answerController = answerControllers[i];
      String answer = answerController.text.trim();

      bool isAnswered = optionsControllers[i]
          .any((optionController) => optionController.text.trim() == answer);

      if (!isAnswered) {
        return false;
      }
    }

    return true;
  }

  Future<Map<String, dynamic>> fetchClassDetails(String classId) async {
    return await firebaseService.getClassDetails(classId);
  }

  Future<String> getEnrolledClassDetails() async {
    print('calss enrolment key: $classId');

    Map<String, dynamic> classDetails = await fetchClassDetails(classId);

    setState(() {
      year = classDetails['year'];
    });
    return year;
  }

  void _saveQuiz() async {
    List<Question> questions = [];
    year = await getEnrolledClassDetails();

    for (int i = 0; i < questionControllers.length; i++) {
      List<String> options = optionControllers[i]
          .map((controller) => controller.text.trim())
          .where((option) => option.isNotEmpty)
          .toList();

      questions.add(Question(
        questionText: questionControllers[i].text,
        answer: answerControllers[i].text,
        options: options,
      ));
    }

    QuizModel quiz = QuizModel(
      classId: classId,
      year: year,
      title: quizNameController.text,
      description: descriptionController.text,
      numberOfQuestions: questionControllers.length,
      questions: questions,
    );

    print(quiz.toString());

    try {
      await firebaseService.addNewQuiz(quiz);
      // ignore: use_build_context_synchronously
      showCustomSnackBar(context, '${TextConstant.quizSuccessfullyAdded}!');
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (error) {
      // ignore: use_build_context_synchronously
      showCustomSnackBar(context, '${TextConstant.failedToAddNewQuiz}: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    setScreenWidth(context);
    return Scaffold(
        appBar: const CustomAppBar(
          title: TextConstant.addNewQuiz,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            CustomDropdownButton(
                              width: (MediaQuery.of(context).size.width - 40),
                              prefixIcon: Icons.numbers_outlined,
                              hintText: TextConstant.classId,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              items: classIds,
                              onItemSelected: (value) {
                                classId = value!;
                              },
                            ),
                            if (classId.isEmpty && submitButtonIsClicked)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10.5, 8, 10, 0),
                                child: Row(
                                  children: [
                                    Text(
                                      '${TextConstant.classId} is Empty',
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
                            const SizedBox(
                              height: 20,
                            ),
                            CustomTextFormField(
                              width: (MediaQuery.of(context).size.width - 40),
                              prefixIcon: const Icon(Icons.title_outlined),
                              labelText:
                                  '${TextConstant.quiz} ${TextConstant.title}',
                              padding: const EdgeInsets.only(bottom: 20),
                              hintText: '',
                              controller: quizNameController,
                              validator: (value) =>
                                  ValidatorHelper.validateEmpty(
                                      value, TextConstant.title),
                            ),
                            Container(
                              height:
                                  (MediaQuery.of(context).size.height * 0.15),
                              child: CustomTextFormField(
                                // height:
                                //     (MediaQuery.of(context).size.height * 0.15),
                                width: (MediaQuery.of(context).size.width - 40),
                                prefixIcon: const Icon(Icons.note_outlined),
                                labelText:
                                    TextConstant.writeADescriptionOrInstruction,
                                padding: const EdgeInsets.only(bottom: 20),
                                hintText: '',
                                controller: descriptionController,
                                maxLines: null,
                                textAlignVertical: TextAlignVertical.top,
                                validator: (value) =>
                                    ValidatorHelper.validateEmpty(value,
                                        TextConstant.descriptionOrInstruction),
                              ),
                            ),
                            CustomTextFormField(
                              width: (MediaQuery.of(context).size.width - 40),
                              prefixIcon: const Icon(Icons.numbers_outlined),
                              labelText: TextConstant.questionNumber,
                              padding: const EdgeInsets.only(bottom: 20),
                              hintText: '',
                              controller: numQuestionController,
                              validator: (value) =>
                                  ValidatorHelper.validateEmpty(
                                      value, TextConstant.questionNumber),
                              onChanged: (value) {
                                int numQuestions = int.tryParse(value) ?? 0;
                                setState(() {
                                  questionControllers = List.generate(
                                    numQuestions,
                                    (index) => TextEditingController(),
                                  );
                                  answerControllers = List.generate(
                                    numQuestions,
                                    (index) => TextEditingController(),
                                  );
                                  optionControllers = List.generate(
                                    numQuestions,
                                    (index) => List.generate(
                                        2,
                                        (_) =>
                                            TextEditingController()), // 4 options per question
                                  );
                                });
                              },
                            ),
                            Column(
                              children: [
                                for (int i = 0;
                                    i < questionControllers.length;
                                    i++)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8.0, 0, 8, 8),
                                          child: Text(
                                              '${TextConstant.question} ${i + 1}'),
                                        ),
                                        CustomTextFormField(
                                          width: (MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40),
                                          prefixIcon:
                                              const Icon(Icons.question_mark),
                                          labelText: TextConstant.questionText,
                                          padding:
                                              const EdgeInsets.only(bottom: 20),
                                          hintText:
                                              TextConstant.enterQuestionText,
                                          controller: questionControllers[i],
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return TextConstant
                                                  .pleaseEnterAQuestion;
                                            }
                                            return null;
                                          },
                                        ),
                                        CustomTextFormField(
                                          width: (MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40),
                                          prefixIcon: const Icon(Icons.check),
                                          labelText: TextConstant.answer,
                                          padding:
                                              const EdgeInsets.only(bottom: 20),
                                          hintText: TextConstant.enterAnswer,
                                          controller: answerControllers[i],
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return TextConstant
                                                  .pleaseEnterAnAnswer;
                                            }
                                            return null;
                                          },
                                        ),
                                        const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(8.0, 0, 8, 8),
                                          child: Text(TextConstant.options),
                                        ),
                                        for (int j = 0;
                                            j < optionControllers[i].length;
                                            j++)
                                          CustomTextFormField(
                                            width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                40),
                                            prefixIcon:
                                                const Icon(Icons.circle),
                                            labelText:
                                                '${TextConstant.option} ${j + 1}',
                                            padding: const EdgeInsets.only(
                                                bottom: 20),
                                            hintText:
                                                '${TextConstant.enterOption} ${j + 1}',
                                            controller: optionControllers[i][j],
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                if (j ==
                                                    optionControllers[i]
                                                            .length -
                                                        1) {
                                                  if (optionControllers[i]
                                                          .length >
                                                      2) {
                                                    return null;
                                                  }
                                                }

                                                return '${TextConstant.pleaseEnterOption} ${j + 1}';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              if (value.isNotEmpty &&
                                                  j ==
                                                      optionControllers[i]
                                                              .length -
                                                          1) {
                                                _addOptionField(i);
                                              } else if (value.isEmpty &&
                                                  j ==
                                                      optionControllers[i]
                                                              .length -
                                                          2) {
                                                if (optionControllers[i]
                                                        .length >
                                                    2) {
                                                  optionControllers[i]
                                                      .removeLast();

                                                  setState(() {});
                                                }
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomButton(
                                    fontSize: screenWidth * 4.5,
                                    height: screenWidth * 12,
                                    label: TextConstant.submit,
                                    onPressed: () {
                                      setState(() {
                                        submitButtonIsClicked = true;
                                      });

                                      if (_formKey.currentState!.validate() &&
                                          classId.isNotEmpty) {
                                        if (!isAtLeastOneOptionAnswered(
                                            optionControllers,
                                            answerControllers)) {
                                          showCustomSnackBar(
                                              context,
                                              TextConstant
                                                  .makeSureOptionIsAmswer);
                                          return;
                                        }

                                        _saveQuiz();
                                      }
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ])),
            )));
  }
}
