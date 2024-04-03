import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tobeto_app/bloc/reviews_bloc/reviews_exam_bloc.dart';
import 'package:tobeto_app/widget/reviews_widget/reviews_exam_model.dart';

class ReviewsExam extends StatefulWidget {
  final String examTitle;

  const ReviewsExam({Key? key, required this.examTitle}) : super(key: key);

  @override
  _ReviewsExamState createState() => _ReviewsExamState();
}

class _ReviewsExamState extends State<ReviewsExam> {
  final examBloc = ExamBloc();

  @override
  void initState() {
    super.initState();
    examBloc.fetchQuestions();
  }

  @override
  void dispose() {
    examBloc.dispose();
    super.dispose();
  }

  void finishExam() {
    int correctCount = 0;
    int totalCount = examBloc.questions.length;

    examBloc.selectedOptions.forEach((questionNumber, selectedOption) {
      if (selectedOption ==
          examBloc.questions[questionNumber - 1].correctAnswer) {
        correctCount++;
      }
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${widget.examTitle}\nSınav Sonucu:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text('Doğru Cevap: $correctCount',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              SizedBox(height: 20),
              Text('Yanlış Cevap: ${totalCount - correctCount}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                saveResult(correctCount, totalCount - correctCount);
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  void saveResult(int correctCount, int incorrectCount) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'reviews-exam-result': {
          'examTitle': widget.examTitle,
          'Correct': correctCount,
          'Incorrect': incorrectCount,
        }
      });
    } catch (e) {
      print('Error saving result: $e');
    }
  }

  void showExamResult() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      var examResult = userDoc.data()?['reviews-exam-result'];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sınav sonucu'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Text('Sınav: ${examResult['examTitle']}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                SizedBox(height: 20),
                Text('Doğru Cevap: ${examResult['Correct']}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                SizedBox(height: 20),
                Text('Yanlış Cevap: ${examResult['Incorrect']}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error showing exam result: $e');
    }
  }

  Widget buildQuestion(
    int questionNumber,
    String question,
    List<String> options,
    int correctAnswer,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$questionNumber) $question',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        RadioButtonGroup(
          options: options,
          onChanged: (value) {
            setState(() {
              examBloc.selectedOptions[questionNumber] = value;
            });
          },
          selectedOption: examBloc.selectedOptions[questionNumber],
        ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examTitle),
      ),
      body: StreamBuilder<List<ExamQuestion>>(
        stream: examBloc.questionsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ExamQuestion> questions = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: List.generate(questions.length, (index) {
                        ExamQuestion question = questions[index];
                        return buildQuestion(
                          index + 1,
                          question.question,
                          question.options,
                          question.correctAnswer,
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: finishExam,
                      child: Text('Sınavı Bitir'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: showExamResult,
                      child: Text('Sınav Sonucunu Göster'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('Çıkış Yap'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class RadioButtonGroup extends StatelessWidget {
  final List<String> options;
  final Function(int?) onChanged;
  final int? selectedOption;

  const RadioButtonGroup({
    Key? key,
    required this.options,
    required this.onChanged,
    required this.selectedOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        int index = options.indexOf(option);
        return RadioListTile<int>(
          title: Text(
            option,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color ??
                  Theme.of(context).colorScheme.background,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          value: index,
          groupValue: selectedOption,
          onChanged: onChanged,
        );
      }).toList(),
    );
  }
}
