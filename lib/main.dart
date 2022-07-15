import 'dart:async';

import 'package:create_social/forms/loginform.dart';
import 'package:create_social/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'pages/authentication.dart';
import 'pages/home.dart';
late FirebaseAuth firebaseAuth;
Future<void> main() async {
  //Always needed for firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  firebaseAuth = FirebaseAuth.instance;
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SocialApp());
}

class SocialApp extends StatelessWidget {
  const SocialApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      home: firebaseAuth.currentUser == null ? (const Authentication()):(const HomePage()),
      builder: EasyLoading.init(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Authentication()));
    }
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/appLogo.png'),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Social App',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 40),
              ),
            )
          ],
        ),
      ),
    );
  }
}
