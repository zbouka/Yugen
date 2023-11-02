//import 'package:appinio_video_player/appinio_video_player.dart';
 /* 
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
  //late VideoPlayerController? videoPlayerController;
  bool loading = false;
  //late CustomVideoPlayerController? _customVideoPlayerController;

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });

  videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.animeVideo))
          ..initialize().then((value) => setState(() {
                loading = false;

                videoPlayerController!.play();
              }));

    videoPlayerController!.addListener(() {
      if (videoPlayerController!.value.hasError) {
        Get.back();
        sendErrorMail(
            true, "ERROR", videoPlayerController!.value.errorDescription!);
      }
    });
    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      customVideoPlayerSettings: const CustomVideoPlayerSettings(
        deviceOrientationsAfterFullscreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        enterFullscreenOnStart: true,
        exitFullscreenOnEnd: true,
        autoFadeOutControls: true,
        showDurationRemaining: false,
      ),
      videoPlayerController: videoPlayerController!,
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

   // _customVideoPlayerController!.dispose();
   // videoPlayerController!.dispose();
   // _customVideoPlayerController = null;
   // videoPlayerController = null;

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Material(
            child: CustomVideoPlayer(
                customVideoPlayerController: _customVideoPlayerController!),
          );
  }
}
*/