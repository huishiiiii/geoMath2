import 'package:flutter/material.dart';
import 'package:geomath/helpers/text_constant.dart';

class QuestionWidget extends StatelessWidget {
  const QuestionWidget(
      {Key? key,
      required this.question,
      required this.indexAction,
      required this.totalQuestion,
      required this.score,
      this.image})
      : super(key: key);

  final String question;
  final int indexAction;
  final int totalQuestion;
  final int score;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${TextConstant.question} ${indexAction + 1}/$totalQuestion:',
                  style: const TextStyle(
                    fontSize: 17,
                  )),
              Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text('${TextConstant.score}: $score',
                      style: const TextStyle(
                        fontSize: 17,
                      )))
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 25.0, 0, 8.0),
            child: Text(question,
                style: const TextStyle(
                  fontSize: 19,
                )),
          ),
          if (image != null && image != '')
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Center(
                child: Image(
                  image: NetworkImage(image!),
                  width: 200,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
