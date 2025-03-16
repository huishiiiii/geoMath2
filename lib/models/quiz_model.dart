class QuizModel {
  final String? classId;
  final String? quizId;
  final String? year;
  final String title;
  final String? description;
  final int? numberOfQuestions;
  final List<Question>? questions;
  final Map<String, dynamic>? quizDetails;
  final List<Map<String, dynamic>>? questionDetails;

  QuizModel({
    required this.title,
    this.year,
    this.quizId,
    this.classId,
    this.description,
    this.numberOfQuestions,
    this.questions,
    this.quizDetails,
    this.questionDetails,
  });

  @override
  String toString() {
    return 'QuizModel{classId: $classId, quizId: $quizId, title: $title, description: $description, numberOfQuestions: $numberOfQuestions, questions: $questions, quizDetails: $quizDetails, questionDetails: $questionDetails}';
  }
}

class Question {
  final String questionText;
  final String answer;
  final List<String> options;

  Question({
    required this.questionText,
    required this.answer,
    required this.options,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': questionText,
      'answer': answer,
      'options': options,
    };
  }

  @override
  String toString() {
    return 'Question{questionText: $questionText, answer: $answer, options: $options}';
  }
}
