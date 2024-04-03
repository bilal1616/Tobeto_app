import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tobeto_app/widget/reviews_widget/reviews_exam_model.dart';

class ExamBloc {
  late List<ExamQuestion> questions;
  final Map<int, int?> selectedOptions = {};

  final _questionsController = StreamController<List<ExamQuestion>>.broadcast();
  Stream<List<ExamQuestion>> get questionsStream => _questionsController.stream;

  Future<void> fetchQuestions() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('reviews-exam').get();

      questions = querySnapshot.docs.map((doc) {
        return ExamQuestion(
          question: doc['question'],
          options: List<String>.from(doc['options']),
          correctAnswer: doc['correctAnswer'],
        );
      }).toList();

      _questionsController.sink.add(questions);
    } catch (e) {
      print('Error fetching questions: $e');
    }
  }

  void dispose() {
    _questionsController.close();
  }
}
