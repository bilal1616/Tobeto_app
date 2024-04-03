import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tobeto_app/model/education_video_player.dart';

class SearchField extends StatefulWidget {
  final Function(String) onTextChanged;

  const SearchField({Key? key, required this.onTextChanged}) : super(key: key);

  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: widget.onTextChanged,
      decoration: InputDecoration(
        hintText: 'Eğitim ara...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        prefixIcon: Icon(Icons.search),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class EducationPage extends StatefulWidget {
  const EducationPage({Key? key}) : super(key: key);

  @override
  _EducationPageState createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  late List<DocumentSnapshot> videos = [];
  late List<DocumentSnapshot> filteredVideos = [];

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final snapshots = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('videos')
          .get();
      setState(() {
        videos = snapshots.docs;
        filteredVideos = List.from(videos);
      });
    } catch (e) {
      // Handle error
      print("Error fetching videos: $e");
    }
  }

  void filterVideos(String searchText) {
    setState(() {
      filteredVideos = videos
          .where((doc) => doc['title']
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eğitimlerim'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchField(
              onTextChanged: filterVideos,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredVideos.length,
              itemBuilder: (context, index) {
                final doc = filteredVideos[index];
                return EducationCard(
                  title: doc['title'],
                  subtitle: doc['subtitle'],
                  buttonText: 'Eğitime Git',
                  imageUrl: doc['imageUrl'],
                  videoURL: doc['videoURL'],
                  title1: doc['title1'],
                  title2: doc['title2'],
                  videoURL1: doc['videoURL1'],
                  videoURL2: doc['videoURL2'],
                  onCardPressed: (videos) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EducationVideoPlayer(
                          videos: videos,
                          videoIDs: [doc.id, '${doc.id}_1', '${doc.id}_2'], // Videoların ID'lerini iletiyoruz
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class EducationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final String imageUrl;
  final String videoURL;
  final String title1;
  final String title2;
  final String videoURL1;
  final String videoURL2;
  final Function(List<VideoData>) onCardPressed; // Yeni eklenen callback

  const EducationCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageUrl,
    required this.videoURL,
    required this.title1,
    required this.title2,
    required this.videoURL1,
    required this.videoURL2,
    required this.onCardPressed, // Yeni eklenen parametre
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    onCardPressed([
                      VideoData(videoURL: videoURL, title: title),
                      VideoData(videoURL: videoURL1, title: title1),
                      VideoData(videoURL: videoURL2, title: title2),
                    ]);
                  },
                  child: Text(buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: Size(double.infinity, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
