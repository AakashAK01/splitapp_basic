import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_basic/authenication_screen.dart';
import 'package:splitwise_basic/home_screen.dart';

class SplashService {
  void isLogined(BuildContext context) {
    final auth = FirebaseAuth.instance;

    final user = auth.currentUser;

    if (user != null) {
      Timer(
          Duration(seconds: 1),
          () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
              (route) => false));
    } else {
      Timer(
          Duration(seconds: 1),
          () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => Authentication())));
    }
  }
}
