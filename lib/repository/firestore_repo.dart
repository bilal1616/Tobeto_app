import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireStoreRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuthInstance = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestoreInstance = FirebaseFirestore.instance;

  Future<Map<String, List<Map<String, dynamic>>>> getAllDocuments() async {
    final String? userId = _firebaseAuthInstance.currentUser?.uid;
    if (userId == null) {
      print("Kullanıcı girişi yapılmamış.");
      return {};
    }

    try {
      final Map<String, List<Map<String, dynamic>>> allDocuments = {};

      final List<String> collections = [
        'announcements',
        'applications',
        'catalog-card',
        'exam',
        'report-detail',
        'reviews-card',
        'reviews-exam',
        'surveys'
      ];

      for (String collection in collections) {
        final QuerySnapshot<Map<String, dynamic>> snapshot =
            await _firebaseFirestoreInstance
                .collection(collection)
                .get();

        final List<Map<String, dynamic>> documents = snapshot.docs.map((doc) {
          return doc.data();
        }).toList();

        allDocuments[collection] = documents;
      }

      return allDocuments;
    } catch (e) {
      print("Hata oluştu: $e");
      return {};
    }
  }

  Future<void> getAllCollections() async {
    final String? userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      print("Kullanıcı girişi yapılmamış.");
      return;
    }

    try {
      // users koleksiyonundaki belgeleri al
      await _firestore.collection('users').doc(userId).get().then((userDoc) {
        if (userDoc.exists) {
          // user belgesinin içindeki alt koleksiyonları al
          _getSubCollections(userDoc.reference);
        } else {
          print("Kullanıcı bulunamadı.");
        }
      });
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }

  Future<void> _getSubCollections(DocumentReference userRef) async {
    try {
      // user belgesinin içindeki calendar koleksiyonunu al
      await userRef.collection('calendar').get().then((calendarDocs) {
        // calendar koleksiyonundaki belgeleri işle
        for (DocumentSnapshot doc in calendarDocs.docs) {
          print("Calendar Document ID: ${doc.id}");
          print("Calendar Document Data: ${doc.data()}");
        }
      });

      // user belgesinin içindeki certificates koleksiyonunu al
      await userRef.collection('certificates').get().then((certificatesDocs) {
        // certificates koleksiyonundaki belgeleri işle
        for (DocumentSnapshot doc in certificatesDocs.docs) {
          print("Certificates Document ID: ${doc.id}");
          print("Certificates Document Data: ${doc.data()}");
        }
      });

      // user belgesinin içindeki videos koleksiyonunu al
      await userRef.collection('videos').get().then((videosDocs) {
        // videos koleksiyonundaki belgeleri işle
        for (DocumentSnapshot doc in videosDocs.docs) {
          print("Videos Document ID: ${doc.id}");
          print("Videos Document Data: ${doc.data()}");
        }
      });

      // user belgesinin içindeki watched_videos koleksiyonunu al
      await userRef.collection('watched_videos').get().then((watchedVideosDocs) {
        // watched_videos koleksiyonundaki belgeleri işle
        for (DocumentSnapshot doc in watchedVideosDocs.docs) {
          print("Watched Videos Document ID: ${doc.id}");
          print("Watched Videos Document Data: ${doc.data()}");
        }
      });

      // Diğer koleksiyonları da buraya ekleyebilirsiniz

    } catch (e) {
      print("Hata oluştu: $e");
    }
  }
}
