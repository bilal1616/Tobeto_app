import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Surveys extends StatefulWidget {
  @override
  _SurveysState createState() => _SurveysState();
}

class _SurveysState extends State<Surveys> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Anketlerim'),
        ),
        body: Center(
          child: Text("Lütfen giriş yapın."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Anketlerim'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/videoback.png'), // Arka plan resmi burada belirtilmeli
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var userDoc = snapshot.data;
            var surveyIds = List.from(userDoc?['surveys'] ?? []);

            return ListView.builder(
              itemCount: surveyIds.length,
              itemBuilder: (context, index) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('surveys')
                      .doc(surveyIds[index])
                      .get(),
                  builder: (context, surveySnapshot) {
                    if (!surveySnapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    var surveyData = surveySnapshot.data;
                    return _buildSurveyCard(
                        context, surveyData?['imageURL'], surveyData?['title']);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSurveyCard(
      BuildContext context, String? imageUrl, String? title) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(imageUrl,
                      width: double.infinity, fit: BoxFit.cover)
                  : Image.asset('assets/placeholder.jpg',
                      width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                title ?? "Anket Başlığı Bulunamadı",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
