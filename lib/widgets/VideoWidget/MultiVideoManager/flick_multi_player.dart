import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import './flick_multi_manager.dart';
import '../VideoControls/custom_video_control.dart';
import '../VideoControls/multi_portrait_controls.dart';

class FlickMultiPlayer extends StatefulWidget {
  const FlickMultiPlayer(
      {Key? key,
      required this.url,
      this.image,
      required this.flickMultiManager})
      : super(key: key);

  final String url;
  final String? image;
  final FlickMultiManager flickMultiManager;

  @override
  _FlickMultiPlayerState createState() => _FlickMultiPlayerState();
}

class _FlickMultiPlayerState extends State<FlickMultiPlayer> {
  late FlickManager flickManager;
  bool isLoop = true;
  bool showLoader = false;
  @override
  void initState() {
    flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network(widget.url)
          ..setLooping(isLoop),
        autoPlay: false,
    );
    widget.flickMultiManager.init(flickManager);
    super.initState();
  }

  @override
  void dispose() {
    widget.flickMultiManager.remove(flickManager);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(flickManager),
      onVisibilityChanged: (visiblityInfo) {
        print("visiblityInfo.visibleFraction");
        print(visiblityInfo.visibleFraction);

        if (visiblityInfo.visibleFraction > 0.8) {
          widget.flickMultiManager.play(flickManager);

        } else if (visiblityInfo.visibleFraction == 0.0) {
         flickManager.flickControlManager?.pause();
        }

        if(visiblityInfo.visibleFraction == 1.0  &&
            flickManager.flickVideoManager!.errorInVideo){
          print("flickManager.flickVideoManager!.errorInVideo");
          flickManager.flickVideoManager?.videoPlayerController?.initialize().then((value) {
            flickManager.flickControlManager?.play();
          });
        }

        if(visiblityInfo.visibleFraction == 1.0  &&
            flickManager.flickVideoManager!.isBuffering){
          setState((){
            showLoader= true;
          });
        }


      },
      child: FlickVideoPlayer(
        flickManager: flickManager,
        flickVideoWithControls: FlickVideoWithControls(
          videoFit: BoxFit.contain,
          playerLoadingFallback: Positioned.fill(
            child: Stack(
              children: <Widget>[
                if (widget.image != null)
                  Positioned.fill(
                    child: widget.image!.startsWith("http")
                        ? Image.network(
                            widget.image!,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            widget.image!,
                            fit: BoxFit.cover,
                          ),
                  ),
                const Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          playerErrorFallback: Positioned.fill(
            child: Stack(
              children: <Widget>[
                if (widget.image != null)
                  Positioned.fill(
                    child: widget.image!.startsWith("http")
                        ? Image.network(
                            widget.image!,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            widget.image!,
                            fit: BoxFit.cover,
                          ),
                  ),
                const Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          controls: FeedPlayerPortraitControls(
            flickMultiManager: widget.flickMultiManager,
            flickManager: flickManager,
          ),
        ),
        systemUIOverlayFullscreen: const [
          SystemUiOverlay.top,
          SystemUiOverlay.bottom,
        ],
        preferredDeviceOrientationFullscreen: const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
        flickVideoWithControlsFullscreen: FlickVideoWithControls(
          videoFit: BoxFit.contain,
          playerLoadingFallback: Center(
              child: widget.image != null
                  ? Image.network(
                      widget.image!,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      color: Colors.black,
                    )),
          playerErrorFallback: Center(
              child: widget.image != null
                  ? Image.network(
                      widget.image!,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      color: Colors.black,
                    )),
          controls: CustomFlickPortraitControls(
            progressBarSettings: FlickProgressBarSettings(
              handleColor: Colors.blue,
              height: 3.0,
              playedColor: Colors.blue,

            ),
          ),
          iconThemeData: const IconThemeData(
            size: 40,
            color: Colors.blue,
          ),
          textStyle: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }


}
