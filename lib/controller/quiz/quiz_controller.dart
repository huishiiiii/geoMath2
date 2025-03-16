import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/models/quiz_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/widget/show_custom_snackbar.dart';

class QuizController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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

  AddNewQuizController() {
    getClassIds();
    getUserDetails();
  }

  Future<void> getClassIds() async {
    List<Map<String, dynamic>> teacherClasses =
        await firebaseService.getTeacherClasses();

    classIds =
        teacherClasses.map((classData) => classData['id'] as String).toList();
  }

  Future<Map<String, dynamic>> fetchUserDetails(String uid) async {
    return await firebaseService.getUserDetails(uid);
  }

  Future<void> getUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    Map<String, dynamic> userDetails = await fetchUserDetails(user!.uid);

    // Access user details
    firstName = userDetails['firstname'];
    lastName = userDetails['lastname'];
  }

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
  }

  void addOptionField(int questionIndex) {
    List<TextEditingController> controllers = optionControllers[questionIndex];

    controllers.removeWhere((controller) => controller.text.trim().isEmpty);

    if (controllers.every((controller) => controller.text.trim().isNotEmpty)) {
      controllers.add(TextEditingController());
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
    Map<String, dynamic> classDetails = await fetchClassDetails(classId);
    year = classDetails['year'];
    return year;
  }

  Future<void> saveQuiz(BuildContext context) async {
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

    try {
      await firebaseService.addNewQuiz(quiz);
      showCustomSnackBar(context, 'Quiz Successfully Added!');
      Navigator.pop(context);
    } catch (error) {
      showCustomSnackBar(context, 'Failed to add new quiz: $error');
    }
  }
}
