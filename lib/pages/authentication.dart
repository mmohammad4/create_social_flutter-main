        // Authentication screen

import 'package:create_social/forms/loginform.dart';
import 'package:create_social/forms/registerform.dart';
import 'package:flutter/material.dart';

class Authentication extends StatelessWidget {
  const Authentication({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: SafeArea(child: LoginForm())); // login screen
  }
}
