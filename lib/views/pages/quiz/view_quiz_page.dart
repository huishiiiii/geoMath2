import 'package:flutter/material.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/models/quiz_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/pages/quiz/question_page.dart';
import 'package:geomath/views/widget/app_bar.dart';
import 'package:geomath/views/widget/button/custom_button.dart';

class ViewQuizPage extends StatefulWidget {
  static const routeName = 'view_quiz';
  const ViewQuizPage({super.key});

  @override
  State<ViewQuizPage> createState() => _ViewQuizPageState();
}

class _ViewQuizPageState extends State<ViewQuizPage> {
  late QuizModel quizModel;
  FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final id = args['id'];
    final quizModel = args['quizInfo'];
    print("quiz model: $quizModel");

    return Scaffold(
        appBar: CustomAppBar(
          title: quizModel.title,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: quizModel.quizDetails['image'] != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Column(
                          children: [
                            Image(
                              image:
                                  NetworkImage(quizModel.quizDetails?['image']),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(quizModel.quizDetails!['desc'],
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  )),
                            ),
                          ],
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    'This quiz consist of ${quizModel.quizDetails!['question']} questions',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    )),
                              ),
                              CustomButton(
                                height: 50,
                                fontSize: 17,
                                label: TextConstant.letStart,
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(QuestionPage.routeName,
                                        arguments: {
                                      'id': id,
                                      'quizModel': quizModel as QuizModel
                                    }),
                              ),
                            ],
                          ),
                        )
                      ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(quizModel.quizDetails?['desc'],
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  )),
                            ),
                          ],
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    'This quiz consist of ${quizModel.quizDetails!['question']} questions',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    )),
                              ),
                              CustomButton(
                                height: 50,
                                fontSize: 17,
                                label: TextConstant.letStart,
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(QuestionPage.routeName,
                                        arguments: {
                                      'id': id,
                                      'quizModel': quizModel as QuizModel
                                    }),
                              ),
                            ],
                          ),
                        )
                      ])));
  }
}
