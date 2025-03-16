import 'package:flutter/material.dart';
import 'package:geomath/views/widget/app_bar.dart';

import '../../../helpers/color_constant.dart';
import '../../../helpers/text_constant.dart';

class ProgressPage extends StatelessWidget {
  static const routeName = 'progress';
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> classData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    List<Map<String, dynamic>> students = classData['students'];
    List<double> studentScore = [];
    double sumScore = 0.0;
    double overallScore = 0.0;

    for (int i = 0; i < students.length; i++) {
      List<Map<String, dynamic>> quizzes = classData['students'][i]['quizzes'];

      sumScore = 0.0;

      for (int j = 0; j < quizzes.length; j++) {
        double score = quizzes[j]['score'] / quizzes[j]['numQuestion'] * 100;
        sumScore += score;
      }
      studentScore.add(sumScore);
      if (quizzes.isNotEmpty) {
        overallScore += sumScore / quizzes.length;
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: '${classData['classId']} ${TextConstant.analysis}',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Center(
          child: Column(children: [
            const Text(
              TextConstant.overallPerformance,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
              child: CircleAvatar(
                backgroundColor: ColorConstant.whiteColor,
                radius: 40,
                child: Text(
                    students.isNotEmpty
                        ? '${(overallScore / students.length).toStringAsFixed((overallScore / students.length).truncateToDouble() == (overallScore / students.length) ? 0 : 2)}%'
                        : '0%',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500)),
              ),
            ),
            const Divider(
              height: 3,
              thickness: 1,
              color: ColorConstant.darkGreyColor,
            ),
            if (students.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    List<Map<String, dynamic>> quizzes =
                        students[index]['quizzes'];
                    print('studentScore: ${studentScore[index]}');
                    return ExpansionTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      textColor: ColorConstant.darkBlueColor,
                      iconColor: ColorConstant.darkBlueColor,
                      title: Text(
                        '${students[index]['firstname']} ${students[index]['lastname']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Quiz done: ${students[index]['quizzes'].length}',
                      ),
                      trailing: students[index]['quizzes'].isEmpty
                          ? const Text('0.0%',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500))
                          : Text(
                              '${(studentScore[index] / students[index]['quizzes'].length).toStringAsFixed((studentScore[index] / students[index]['quizzes'].length).truncateToDouble() == (studentScore[index] / students[index]['quizzes'].length) ? 0 : 2)}%',
                              style: const TextStyle(fontSize: 20),
                            ),
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: quizzes.length,
                          itemBuilder: (context, quizIndex) {
                            Map<String, dynamic> quiz = quizzes[quizIndex];
                            double score =
                                quiz['score'] / quiz['numQuestion'] * 100;
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                      'Quiz ${quizIndex + 1}: ${quiz['quizName']}'),
                                ),
                                subtitle: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Correct: ${quiz['score']}'),
                                      Text(
                                          'Total Question: ${quiz['numQuestion']}'),
                                    ],
                                  ),
                                ),
                                trailing: Text(
                                  '${(score).toStringAsFixed((score).truncateToDouble() == (score) ? 0 : 2)}%',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              )
            else
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SizedBox(height: MediaQuery.of(context).size.height / 6),
                    Icon(Icons.clear,
                        size: 55,
                        color:
                            ColorConstant.redColor // Adjust the size as needed
                        ),
                    Text(TextConstant.noStudentsFound),
                  ],
                ),
              ),
          ]),
        ),
      ),
      backgroundColor: ColorConstant.primaryColor,
    );
  }
}
