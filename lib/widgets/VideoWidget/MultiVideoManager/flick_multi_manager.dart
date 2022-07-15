import 'package:flick_video_player/flick_video_player.dart';

class FlickMultiManager {
  List<FlickManager> _flickManagers = [];
  FlickManager? _activeManager;
  bool _isMute = true;


  init(FlickManager flickManager) {

    _flickManagers.add(flickManager);

    if (_isMute) {
      flickManager.flickControlManager?.mute();
    } else {
      flickManager.flickControlManager?.unmute();
    }
    if (_flickManagers.length == 1) {
      play(flickManager);
    }
  }

  remove(FlickManager flickManager) {
    if (_activeManager == flickManager) {
      _activeManager = null;
    }
    flickManager.dispose();
    _flickManagers.remove(flickManager);
  }

  dispose() {

    _flickManagers.forEach((element) {
      element.dispose();
      _flickManagers.remove(element);
    });
  }

  togglePlay(FlickManager flickManager) {
    if (_activeManager?.flickVideoManager?.isPlaying == true &&
        flickManager == _activeManager) {
      pause();
    } else {
      play(flickManager);
    }
  }

  pause() {
    print("_activeManager?.flickControlManager?.pause();");
    _activeManager?.flickControlManager?.pause();
  }

  initialize(FlickManager flickManager) {
    if (_activeManager?.flickVideoManager?.videoPlayerValue?.hasError == true &&
        flickManager == _activeManager) {
      play(flickManager);
    }
  }

  play([FlickManager? flickManager]) {
    if (flickManager != null) {
      _activeManager?.flickControlManager?.pause();
      _activeManager = flickManager;
    }

    if (_isMute) {
      _activeManager?.flickControlManager?.mute();
    } else {
      _activeManager?.flickControlManager?.unmute();
    }

    _activeManager?.flickControlManager?.play();
  }

  toggleMute() {
    _activeManager?.flickControlManager?.toggleMute();
    _isMute = _activeManager?.flickControlManager?.isMute ?? false;
    if (_isMute) {
      _flickManagers.forEach((manager) => manager.flickControlManager?.mute());
    } else {
      _flickManagers
          .forEach((manager) => manager.flickControlManager?.unmute());
    }
  }

  toggleFulScreen([FlickManager? flickManager]) {

    if (_activeManager?.flickVideoManager?.videoPlayerValue?.isInitialized == true ) {
      _activeManager?.flickControlManager?.toggleFullscreen();
    }

  }

  toggleLoop(bool isLoop) {

    _flickManagers.forEach((manager) => manager.flickVideoManager?.videoPlayerController!.setLooping(
        isLoop
    ));
    if(isLoop){
      _activeManager?.flickControlManager?.play();
    }
  }

  bool isMute() {
    return _activeManager?.flickControlManager?.isMute ?? false;
  }

  Future<Duration?> getVideoPosition() async {
    return _activeManager?.flickVideoManager?.videoPlayerController?.position;
  }
  void setVideoPosition(Duration position) async {
     _activeManager?.flickVideoManager?.videoPlayerController?.seekTo(position);
  }

  @override
  String toString() {
    // TODO: implement toString
    return _activeManager?.flickVideoManager?.videoPlayerController?.dataSource ?? 'null';
  }
}
