import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tobeto_app/widget/home_widget/education_video.dart';

class EducationVideoRepository {
  final FirebaseFirestore _firestore;

  EducationVideoRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<EducationVideo>> getEducationVideos() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection('education_videos').get();
      final List<EducationVideo> videos = querySnapshot.docs
          .map((doc) => EducationVideo.fromSnapshot(doc))
          .toList();
      return videos;
    } catch (e) {
      throw Exception('Failed to load education videos: $e');
    }
  }
}
