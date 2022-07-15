import 'dart:io';

class Constants {
  // app header size
  static final headerSize = Platform.isAndroid ? 56 : 45 ;

  //Broadcast Receiver
  static const String updateVideoMuteReceiver = 'updateVideoMuteReceiver';


  //Post Type
  static const textPost = '0';
  static const imagePost = '1';
  static const videoPost = '2';

}