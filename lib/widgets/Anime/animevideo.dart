import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:yugen/apis/email.dart';
import 'package:yugen/helpers/check_device.dart';
import '../../assets/loading.dart';

/// Widget that shows the video using a video player
class AnimeVideo extends StatefulWidget {
  final String animeVideo;
  const AnimeVideo({
    super.key,
    required this.animeVideo,
  });

  @override
  State<AnimeVideo> createState() => _AnimeVideoState();
}

class _AnimeVideoState extends State<AnimeVideo> {
  late VideoPlayerController? videoPlayerController;
  bool loading = false;
  late ChewieController? _chewieVideoPlayerController;

  Future<void> initialice() async {
    try {
      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.animeVideo));
      await videoPlayerController!.initialize();
      setState(() {
        loading = false;
      });
      videoPlayerController!.play();
      videoPlayerController!.addListener(() {
        if (videoPlayerController!.value.hasError) {
          // Log detailed error for debugging
          sendErrorMail(true, "ERROR",
              videoPlayerController!.value.errorDescription ?? "Unknown error");
          Get.back();
        }
      });
      _chewieVideoPlayerController = ChewieController(
        allowFullScreen: true,
        zoomAndPan: true,
        fullScreenByDefault: true,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitDown,
          DeviceOrientation.portraitUp
        ],
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ],
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: true,
      );
    } catch (e) {
      // Send the caught error via email
      sendErrorMail(true, "Initialization Error", e.toString());
      Get.back(); // Return to the previous screen if initialization fails
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    try {
      initialice().then((value) => null);
    } catch (e) {
      sendErrorMail(true, "ERROR", e);
    }
  }

  @override
  void dispose() {
    isTablet
        ? SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ])
        : SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);

    _chewieVideoPlayerController!.dispose();
    videoPlayerController!.dispose();
    _chewieVideoPlayerController = null;
    videoPlayerController = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Material(
            child: Chewie(controller: _chewieVideoPlayerController!),
          );
  }
}
