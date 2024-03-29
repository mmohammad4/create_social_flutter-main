
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../MultiVideoManager/flick_multi_manager.dart';

class FeedPlayerPortraitControls extends StatelessWidget {
  const FeedPlayerPortraitControls(
      {Key? key, this.flickMultiManager, this.flickManager})
      : super(key: key);

  final FlickMultiManager? flickMultiManager;
  final FlickManager? flickManager;

  @override
  Widget build(BuildContext context) {
    FlickDisplayManager displayManager =
        Provider.of<FlickDisplayManager>(context);
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: FlickVideoBuffer(
        bufferingChild: Center(
          child: CircularProgressIndicator(
            strokeWidth: 5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            FlickAutoHideChild(
              showIfVideoNotInitialized: false,
              autoHide: false,
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FlickLeftDuration(),
                ),
              ),
            ),
            Expanded(
              child: FlickToggleSoundAction(
                toggleMute: () {
                  displayManager.handleShowPlayerControls();

                },
              ),
            ),
            FlickAutoHideChild(
              autoHide: true,
              showIfVideoNotInitialized: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FlickSoundToggle(
                      toggleMute: () => flickMultiManager?.toggleMute(),
                      color: Colors.blue,
                      muteChild: Image.asset('assets/logos/mute.png',height:24,width:24,
                        color: Colors.blue,),
                      unmuteChild: Image.asset('assets/logos/volume.png',height:24,width:24,
                        color: Colors.blue,),
                    ),
                  ),
                  // FlickFullScreenToggle(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

