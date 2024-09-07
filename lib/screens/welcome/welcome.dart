import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:yugen/config/preferences.dart';
import 'package:yugen/screens/auth/login.dart';
import 'package:yugen/screens/welcome/changeLanguage.dart';

/// Initial screen when the app is opened, when is opened is no longer showed later.
class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  bool click = true;
  bool isInitialized = false;
  late final ScreenScaler scaler;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isInitialized == false) {
      scaler = ScreenScaler()..init(context);
      isInitialized = true;
    }
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Column(
              children: [
                Text(
                  'welcome'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: scaler.getTextSize(15),
                  ),
                ),
                Text(
                  "welcomeDescription".tr,
                  style: TextStyle(
                    fontSize: scaler.getTextSize(11),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Expanded(
              flex: 2,
              child: Lottie.asset("lib/assets/welcome.json"),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Preferences().changeThemeMode();
                    setState(() {
                      click = !click;
                    });
                  },
                  icon: (click == false)
                      ? const Icon(
                          Icons.wb_sunny,
                          color: Colors.yellow,
                        )
                      : const Icon(
                          Icons.nightlight_round,
                          color: Colors.black,
                        ),
                ),
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      backgroundColor:
                          WidgetStateProperty.all(Colors.deepPurple[700]),
                    ),
                    child: Text(
                      "getStarted".tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: scaler.getTextSize(11),
                      ),
                    ),
                    onPressed: () => Get.off(() => const Login(),
                        transition: Transition.fade),
                  ),
                ),
                IconButton(
                  onPressed: () => showDialogue(context),
                  icon: const Icon(
                    Icons.language,
                    color: Colors.blue,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
