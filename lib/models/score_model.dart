class ScoreModel {
  final String quizId;
  final String quizName;
  final int numQuestion;
  final int score;

  ScoreModel(
      {required this.quizId,
      required this.quizName,
      required this.numQuestion,
      required this.score});

  @override
  String toString() {
    return 'ScoreModel{quizId: $quizId, quizName: $quizName, numQuestion: $numQuestion, score: $score}';
  }
}
