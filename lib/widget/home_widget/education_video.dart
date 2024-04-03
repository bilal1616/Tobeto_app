import 'package:cloud_firestore/cloud_firestore.dart';

class EducationVideo {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String videoURL;

  EducationVideo({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.videoURL,
  });

  factory EducationVideo.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final String? id = snapshot.id;
    final String? title = data['title'];
    final String? imageUrl = data['imageUrl'];
    final String? videoURL = data['videoURL'];

    if (id == null || title == null || imageUrl == null || videoURL == null) {
      throw Exception("Invalid snapshot data for EducationVideo");
    }

    return EducationVideo(
      id: id,
      title: title,
      subtitle: data['subtitle'],
      imageUrl: imageUrl,
      videoURL: videoURL,
    );
  }
}
