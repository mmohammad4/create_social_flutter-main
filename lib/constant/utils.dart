import 'dart:math';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class Utils{
  // internet connection status
  static Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  // app loader
  static void showLoader() {
    EasyLoading.show(status: 'Loading ...');
  }

  static void hideLoader() {
    EasyLoading.dismiss();
  }

  // regex for email validation
  static bool isValidEmail(String em) {
    String p = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(p);
    return regExp.hasMatch(em);
  }

  //converting post timing to String
  static String convertToAgo(context, Timestamp input) {
    Duration diff = DateTime.now().difference(input.toDate());
    if (diff.inDays >= 7) {
      int week = diff.inDays ~/ 7;
      return '$week  week ago';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} seconds ago';
    } else {
      return 'just now';
    }
  }

  //date and time into minus
  static DateTime convertDateTimeToMinutes(String date) {
    DateTime convertedDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(date, true);
    return convertedDate;
  }

//widget for showing network image
  static Widget loadCachedNetworkImage(String? imageUrl, {int? memHeight,int? memWidth,
    int? height,int? width,BoxFit? fit,String? provider}) {

    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(
        provider != null ? provider :'assets/images/no_photo.png',
        fit: fit ?? BoxFit.cover,
      );
    } else {
      return memHeight != null && memWidth != null ? CachedNetworkImage(
        imageUrl: imageUrl,
        memCacheWidth: int.parse(memWidth.toString()),
        memCacheHeight: int.parse(memHeight.toString()),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit:  fit ?? BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => Image.asset(
          provider != null ? provider :'assets/images/no_photo.png',
          fit:  fit ?? BoxFit.cover,
        ),
        errorWidget: (context, url, error) => Image.asset(
          provider != null? provider :'assets/images/no_photo.png',
          fit:  fit ?? BoxFit.cover,
        ),
      ) :
      CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit:  fit ?? BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => Image.asset(
          provider ?? 'assets/images/no_photo.png',
          fit:  fit ?? BoxFit.cover,
        ),
        errorWidget: (context, url, error) => Image.asset(
          provider ?? 'assets/images/no_photo.png',
          fit:  fit ?? BoxFit.cover,
        ),
      );
    }
  }

  // dialog box
  static void showTwoButtonAlertDialog(
      {required BuildContext context,
        required String alertTitle,
        required String alertMsg,
        required String positiveText,
        required String negativeText,
        required Function() yesTap,
        Function()? noTap}) {
    // set up the buttons
    Widget noButton = TextButton(
      child: Text(
        negativeText,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
        ),
      ),
      onPressed: noTap != null
          ? noTap
          : () {
        Navigator.of(context).pop();
      },
    );
    Widget yesButton = TextButton(
      child: Text(
        positiveText,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.red,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        yesTap();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(alertTitle),
      content: Text(alertMsg),
      actions: [noButton, yesButton],
    );
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // random string generator
  static String generateRandomString1(int length) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

    return List.generate(length, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  // image compressor
  static Future<File?> compressImages(
      String absolutePath, String targetPath) async {
    print("*********Called compress image******");
    final result = await FlutterImageCompress.compressAndGetFile(
      absolutePath,
      targetPath,
      quality: 50,
    );
    // print("RESULT: "+result!.path);
    // print("targetPath: "+targetPath);
    return result;
  }

  // Toast messages
  static void showToastMessage(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        fontSize: 14,
        // backgroundColor: Colors.red,
        textColor: Colors.white);
  }


}