import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:yugen/config/preferences.dart';

import 'package:yugen/screens/welcome/welcome.dart';
import 'package:yugen/widgets/Recycled/get_color.dart';

import 'auth/auth.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () => checkFirstSeen());
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///Checks if is first time opening the app, if is affirmative loads the welcome screen otherwise calls the handle auth that returns the correspondent screen
  Future checkFirstSeen() async {
    bool seen = Preferences().isFirstSeen();

    if (seen) {
      Auth().handleAuth();
    } else {
      /// Here we set the first screen true because it is only an introductory screen to our app, it saves it in app cache
      Preferences().setFirstSeenTrue();
      Get.off(
        () => const Welcome(),
      );
    }
  }

  ///Triggers the loading animation when the app is opened
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getCurrentColor(false),
      body: Center(
        child: Lottie.asset('lib/assets/loading.json'),
      ),
    );
  }
}
