import 'package:cloud_firestore/cloud_firestore.dart';

class CatalogModel {
  final String id;
  final String name;
  final String time;
  final String title;
  final String imagePath;
  final String videoURL;

  CatalogModel({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.time,
    required this.title,
    required this.videoURL,
  });
}

class CatalogService {
  final CollectionReference catalogCollection =
      FirebaseFirestore.instance.collection('catalog-card');

  Future<List<CatalogModel>> getCatalog() async {
    QuerySnapshot querySnapshot = await catalogCollection.get();
    List<CatalogModel> catalogList = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return CatalogModel(
        id: doc.id,
        name: data['instructor'] ?? '',
        time: data['time'] ?? '',
        title: data['title'] ?? '',
        imagePath: data['imageUrl'] ?? '',
        videoURL: data['videoURL'] ?? '',
      );
    }).toList();
    return catalogList;
  }
}
