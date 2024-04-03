import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video_player/video_player.dart';

class EducationVideoPlayer extends StatefulWidget {
  final List<VideoData> videos;
  final List<String> videoIDs; // Video ID'lerini tutmak için

  const EducationVideoPlayer({
    Key? key,
    required this.videos,
    required this.videoIDs, // Video ID'lerini alıyoruz
  }) : super(key: key);

  @override
  _EducationVideoPlayerState createState() => _EducationVideoPlayerState();
}

class _EducationVideoPlayerState extends State<EducationVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isControlVisible = false;
  bool _isMuted = false;
  bool _isFullScreen = false;
  late VideoData _currentVideo;
  late Map<String, double> watchedVideoData;

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.videos.first;
    _initializeController();
    _fetchWatchedData(); // Kaydedilen izlenme verilerini getir
    watchedVideoData = {}; // watchedVideoData geç başlatılacak
  }

  Future<void> _fetchWatchedData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final watchedVideosRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('watched_videos');

      final QuerySnapshot snapshots = await watchedVideosRef
          .where('video_id', whereIn: widget.videoIDs)
          .get(); // QuerySnapshot kullanılacak

      watchedVideoData = Map.fromIterable(
          snapshots.docs, // snapshots.docs kullanılacak
          key: (doc) => doc['title'] as String,
          value: (doc) =>
              (doc['percentage_watched'] as double)); // double olarak al

      setState(() {});
    } catch (e) {
      print("Error fetching watched video data: $e");
    }
  }

  Future<void> _initializeController() async {
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(_currentVideo.videoURL));
    await _controller.initialize();
    _controller.setLooping(true);
    _controller.addListener(_updateWatchData);
    setState(() {});
  }

  Future<void> _updateWatchData() async {
    if (_controller.value.isPlaying) {
      final percentageWatched = (_controller.value.position.inSeconds /
              _controller.value.duration.inSeconds) *
          100;
      watchedVideoData[_currentVideo.title] = percentageWatched;
      _saveWatchData();
      setState(() {});
    }
  }

  Future<void> _saveWatchData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final videosRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('watched_videos');
      await videosRef.doc(_currentVideo.title).set({
        'title': _currentVideo.title,
        'percentage_watched': watchedVideoData[_currentVideo.title] ?? 0.0,
        'video_id': widget.videoIDs.first, // Video ID'sini kaydet
      });
    } catch (e) {
      print("Error saving watch data: $e");
    }
  }

  Future<void> _getWatchedVideosData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final videosRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('watched_videos');
      final snapshots = await videosRef.get();
      for (var doc in snapshots.docs) {
        final data = doc.data();
        final title = data['title'];
        final percentageWatched = data['percentage_watched'];
        watchedVideoData[title] = percentageWatched;
      }
      setState(() {});
    } catch (e) {
      print("Error fetching watched video data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen ? null : AppBar(title: Text(_currentVideo.title)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return _isFullScreen
        ? _buildFullScreenPlayer()
        : _buildDefaultPlayerWithContent();
  }

  Widget _buildFullScreenPlayer() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isControlVisible = !_isControlVisible;
        });
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          _buildVideoPlayer(),
          AnimatedOpacity(
            opacity: _isControlVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: Container(
              color: Colors.transparent,
              height: 48.0,
              child: _videoControls(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPlayerWithContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isControlVisible = !_isControlVisible;
                    _isFullScreen = !_isFullScreen;
                    _toggleFullScreen();
                  });
                },
                child: _buildVideoPlayer(),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isControlVisible = !_isControlVisible;
                  });
                },
                child: AnimatedOpacity(
                  opacity: _isControlVisible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    color: Colors.transparent,
                    height: 48.0,
                    child: _videoControls(context),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
              'Ders İçeriği',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          _buildVideoList(),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
              'İzlediğiniz Videolar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          _buildWatchedVideoList(),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }

  Widget _buildVideoList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.videos.length,
      itemBuilder: (context, index) {
        final video = widget.videos[index];
        final isCompleted = watchedVideoData[video.title] == 100.0;
        return ListTile(
          title: Text(video.title),
          trailing: IconButton(
            icon: isCompleted ? Icon(Icons.lock) : Icon(Icons.play_arrow),
            onPressed: isCompleted
                ? null
                : () => _playVideo(video), // Tamamlandıysa onPressed'i devre dışı bırakın
          ),
        );
      },
    );
  }

  Widget _buildWatchedVideoList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: watchedVideoData.entries.map((entry) {
        final percentage = entry.value.toInt();
        return ListTile(
          title: Text(entry.key),
          subtitle: LinearPercentIndicator(
            width: MediaQuery.of(context).size.width - 48,
            lineHeight: 20.0,
            percent: percentage / 100,
            backgroundColor: Colors.grey,
            progressColor: Colors.green,
            center: Text('$percentage%'),
          ),
        );
      }).toList(),
    );
  }

  Widget _videoControls(BuildContext context) {
    final isCompleted = watchedVideoData[_currentVideo.title] == 100.0;
    return Container(
      color: Colors.black45,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.replay_10),
            color: Colors.white,
            onPressed: () => _controller.seekTo(
              _controller.value.position - Duration(seconds: 10),
            ),
          ),
          IconButton(
            icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
            color: Colors.white,
            onPressed: isCompleted
                ? null
                : () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
          ),
          IconButton(
            icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
            color: Colors.white,
            onPressed: () {
              setState(() {
                _isMuted = !_isMuted;
                _controller.setVolume(_isMuted ? 0 : 1);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.forward_10),
            color: Colors.white,
            onPressed: () => _controller.seekTo(
              _controller.value.position + Duration(seconds: 10),
            ),
          ),
          IconButton(
            icon:
                Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
            color: Colors.white,
            onPressed: _toggleFullScreen,
          ),
        ],
      ),
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    });
  }

  void _playVideo(VideoData video) async {
    _currentVideo = video;
    await _controller.pause();
    await _controller.initialize();
    _controller = VideoPlayerController.networkUrl(Uri.parse(video.videoURL));
    await _controller.initialize();
    _controller.addListener(_updateWatchData);
    setState(() {});

    // Kaydedilen son izlenme verisini çek
    final lastWatchedPercentage = watchedVideoData[_currentVideo.title] ?? 0.0;

    // Alert dialog göster
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Son İzlenen Yerden Devam Edilsin Mi?'),
          content: Text(
              'Videoyu ${lastWatchedPercentage.toInt()}% izlemişsiniz. Son izlenen yerden devam etmek ister misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hayır'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Videoyu son izlenen yerden başlat
                _controller.seekTo(Duration(
                    seconds: (lastWatchedPercentage *
                            _controller.value.duration.inSeconds ~/
                            100)
                        .toInt()));
                _controller.play(); // Videoyu oynat
              },
              child: Text('Evet'),
            ),
          ],
        );
      },
    );

    // Videoyu oynat
    // _controller.play(); // Bu satırı yorum satırına alıyoruz, kullanıcı Evet'e bastığında videoyu başlatacağız
  }

  @override
  void dispose() {
    _controller.removeListener(_updateWatchData);
    _saveWatchData();
    _controller.dispose();
    super.dispose();
  }
}

class VideoData {
  final String videoURL;
  final String title;

  VideoData({required this.videoURL, required this.title});
}
