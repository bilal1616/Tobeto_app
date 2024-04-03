import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Applications extends StatefulWidget {
  @override
  _ApplicationsState createState() => _ApplicationsState();
}

class _ApplicationsState extends State<Applications> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Stream<List<Map<String, dynamic>>> fetchApplications() async* {
    if (userId == null) {
      yield [];
      return;
    }

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
    if (userData == null) {
      yield [];
      return;
    }
    List<dynamic> applicationRefs = userData['applications'] ?? [];
    List<Map<String, dynamic>> applicationsData = [];

    for (var applicationRef in applicationRefs) {
      if (applicationRef is Map<String, dynamic>) {
        String appId = applicationRef['id'];
        DocumentSnapshot applicationDoc = await FirebaseFirestore.instance
            .collection('applications')
            .doc(appId)
            .get();
        Map<String, dynamic>? appData =
            applicationDoc.data() as Map<String, dynamic>?;

        if (appData != null) {
          appData['state'] =
              applicationRef['state']; // Kullanıcıya özel durum bilgisi

          // Ekstra başvurular için işlemler
          if (appData.containsKey('applications') &&
              appData['applications'] is List) {
            List<dynamic> extraApplications = appData['applications'];
            for (var extraApp in extraApplications) {
              if (extraApp is Map<String, dynamic>) {
                // Ekstra başvuruları ana başvuru listesine ekle
                applicationsData.add({
                  'title': extraApp['title'] ?? 'Ek başlık bilinmiyor',
                  'subtitle':
                      extraApp['subtitle'] ?? 'Ek alt başlık bilinmiyor',
                  'subtitle1':
                      extraApp['subtitle1'] ?? 'Ek açıklama bilinmiyor',
                  'state': appData['state'], // Ana başvurunun durumu
                });
              }
            }
          } else {
            // Eğer 'applications' array'i yoksa veya beklenen formatta değilse, ana başvuruyu listeye ekle
            applicationsData.add(appData);
          }
        }
      }
    }

    yield applicationsData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Başvurularım'),
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
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: fetchApplications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("Başvuru bulunamadı."));
            }

            List<Map<String, dynamic>> applications = snapshot.data!;
            return ListView.builder(
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final app = applications[index];
                return _buildApplicationCard(
                  context,
                  app['title'],
                  app['subtitle'],
                  app['subtitle1'],
                  app['state'],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, String title,
      String subtitle, String subtitle1, String state) {
    Color stateColor = state == "Kabul Edildi"
        ? Colors.green
        : state == "Reddedildi"
            ? Colors.red
            : Colors.green;
    IconData stateIcon = state == "Kabul Edildi" ? Icons.check : Icons.close;

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          // Sol taraftaki dikey renk şeridi
          Container(
            width: 5,
            height: 125, // Kartın içerik boyutuna bağlı olarak ayarlanabilir
            decoration: BoxDecoration(
              color: stateColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          SizedBox(width: 1), // Şerit ile içerik arasında boşluk
          // Kartın içeriği
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2, // Başlık 2 satıra kadar uzayabilir
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: stateColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          state,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(stateIcon, color: stateColor, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(stateIcon, color: stateColor, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subtitle1,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
