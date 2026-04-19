import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SequencePlayer extends StatefulWidget {
  final List<String> videos;

  const SequencePlayer({super.key, required this.videos});

  @override
  State<SequencePlayer> createState() => _SequencePlayerState();
}

class _SequencePlayerState extends State<SequencePlayer> {
  VideoPlayerController? controller;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.videos.isNotEmpty) {
      playVideo();
    }
  }

  void playVideo() async {
    controller?.dispose();

    controller = VideoPlayerController.network(
      "https://cominisign.runasp.net${widget.videos[currentIndex]}",
    );

    await controller!.initialize();

    setState(() {});
    controller!.play();

    controller!.addListener(() {
      if (controller!.value.position >= controller!.value.duration &&
          currentIndex < widget.videos.length - 1) {
        currentIndex++;
        playVideo();
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
        const SizedBox(height: 10),
        Text("Video ${currentIndex + 1} / ${widget.videos.length}")
      ],
    );
  }
}
