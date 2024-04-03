// exam_question_model.dart

class ExamQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;

  ExamQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}
