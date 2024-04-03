import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tobeto_app/widget/reviews_widget/reviews_exam.dart';

final List<Map<String, dynamic>> reviewCategories = [
  {
    'title': 'Front End',
    'icon': Icons.list_outlined,
    'buttonText': 'Başla',
    'color': Colors.blue,
  },
  {
    'title': 'Full Stack',
    'icon': Icons.list_outlined,
    'buttonText': 'Başla',
    'color': Colors.green,
  },
  {
    'title': 'Back End',
    'icon': Icons.list_outlined,
    'buttonText': 'Başla',
    'color': Colors.red,
  },
  {
    'title': 'Microsoft SQL Server',
    'icon': Icons.list_outlined,
    'buttonText': 'Başla',
    'color': Colors.orange,
  },
  {
    'title': 'Masaüstü Programlama',
    'icon': Icons.list_outlined,
    'buttonText': 'Başla',
    'color': Colors.purple,
  },
];

void showReviewCategoryDialog(BuildContext context, String title) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder(
        future: fetchReviewData(title),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return Center(child: Text("No data available"));
          }
          var reviewData = snapshot.data!;
          return AlertDialog(
            title: Row(
              children: [
                Expanded(
                    child: Text(title,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    "${reviewData['subtitle']}",
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Text(
                    "Sınav Süresi: ${reviewData['exam duration']}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    "Soru Sayısı: ${reviewData['number of questions']}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    "Soru Tipi: ${reviewData['question type']}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReviewsExam(
                                  examTitle: '$title',
                                )),
                      );
                    },
                    child: Text('Sınava Başla'),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}

Future<Map<String, dynamic>> fetchReviewData(String title) async {
  // Firestore'dan ilgili review verilerini çek
  // Kullanıcının oturum açtığı kullanıcı kimliğiyle belge al
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  // Kullanıcının reviews-card array'inden ilgili incelemeyi bul
  List<dynamic> reviewCards = userDoc['reviews-card'] ?? [];
  Map<String, dynamic>? reviewData;

  // Incelemeler arasında dolaşarak ilgili incelemeyi bul
  for (String reviewId in reviewCards) {
    DocumentSnapshot reviewDoc = await FirebaseFirestore.instance
        .collection('reviews-card')
        .doc(reviewId)
        .get();
    if (reviewDoc.exists && reviewDoc['title'] == title) {
      reviewData = {
        'subtitle': reviewDoc['subtitle'], // Subtitle eklendi
        'exam duration': reviewDoc['exam duration'],
        'number of questions': reviewDoc['number of questions'],
        'question type': reviewDoc['question type'],
      };
      break;
    }
  }

  return reviewData ??
      {
        'subtitle': 'N/A',
        'exam duration': 'N/A',
        'number of questions': 'N/A',
        'question type': 'N/A',
      };
}
