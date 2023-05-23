import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayItem({super.key, required this.videoUrl});

  @override
  State<VideoPlayItem> createState() => _VideoPlayItemState();
}

class _VideoPlayItemState extends State<VideoPlayItem> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) {
        _videoPlayerController.play();
        _videoPlayerController.setVolume(1);
      });
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(color: Colors.black),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_videoPlayerController.value.isPlaying) {
              _videoPlayerController.pause();
            } else {
              _videoPlayerController.play();
            }
          });
        },
        child: VideoPlayer(_videoPlayerController),
      ),
    );
  }
}
