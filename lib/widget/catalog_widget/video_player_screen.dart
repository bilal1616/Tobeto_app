import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoApp extends StatefulWidget {
  final String videoURL;
  final String title;
  final String subtitle;

  const VideoApp({
    Key? key,
    required this.videoURL,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  bool _isControlVisible = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoURL))
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          // Arka plan resmi
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/videoback.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isControlVisible = !_isControlVisible),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const Center(child: CircularProgressIndicator()),
                _isControlVisible ? _videoControls(context) : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoControls(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isControlVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black45,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10),
              color: Colors.white,
              onPressed: () => _controller
                  .seekTo(_controller.value.position - const Duration(seconds: 10)),
            ),
            IconButton(
              icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
              color: Colors.white,
              onPressed: () {
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
              icon: const Icon(Icons.forward_10),
              color: Colors.white,
              onPressed: () => _controller
                  .seekTo(_controller.value.position + const Duration(seconds: 10)),
            ),
            IconButton(
              icon: const Icon(Icons.fullscreen),
              color: Colors.white,
              onPressed: _toggleFullScreen,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFullScreen() {
    setState(() {
      if (MediaQuery.of(context).orientation == Orientation.landscape) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
