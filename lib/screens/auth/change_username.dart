import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:yugen/config/preferences.dart';
import 'package:yugen/screens/auth/auth.dart';

import '../../helpers/user_exists.dart';
import 'login.dart';

/// Screen to change username in case it existed
class ChangeUsername extends StatefulWidget {
  const ChangeUsername({super.key});

  @override
  State<ChangeUsername> createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final ScreenScaler scaler;
  final _auth = Auth();
  dynamic _validationMsg;
  var username = "";
  Color purpleColor = Colors.deepPurple[700]!;
  bool isInitialized = false;
  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isInitialized == false) {
      scaler = ScreenScaler()..init(context);
      isInitialized = true;
    }
    return OrientationBuilder(
      builder: (context, orientation) => Scaffold(
        body: SafeArea(
          child: SizedBox(
            height: Get.height,
            width: Get.width,
            child: Form(
              child: _changeUsernameForm(),
              key: _formKey,
            ),
          ),
        ),
      ),
    );
  }

  checkFields() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  _changeUsernameForm() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, colors: [
        Colors.purple.shade900,
        Colors.purple.shade800,
        Colors.purple.shade400
      ])),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 80,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: Text(
                      "${'username1'.tr} ${'username2'.tr}",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: scaler.getTextSize(17),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(height: scaler.getHeight(10)),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Preferences().getThemeMode() == ThemeMode.dark
                      ? ThemeData.dark(useMaterial3: true).primaryColor
                      : Colors.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60))),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  runSpacing: 10,
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1400),
                      child: usernameWidget(),
                    ),
                    SizedBox(height: scaler.getHeight(2)),
                    SizedBox(
                      height: scaler.getHeight(2),
                    ),
                    FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: checkButton()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'returnToLogin'.tr,
                          style: TextStyle(
                            fontSize: ScreenScaler().getTextSize(7.3),
                          ),
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => const Login(),
                                transition: Transition.fadeIn);
                          },
                          child: Text(
                            'return'.tr,
                            style: TextStyle(
                              color: Colors.deepPurple[400],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget checkButton() {
    return MaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: purpleColor,
      onPressed: () async {
        if (checkFields() == true && await userExists(username) == false) {
          await _auth.getUser()!.updateDisplayName(username);
          await _auth.changeUsername(_auth.getUser()!, username);
          await _auth.signOut();
          Get.snackbar("valid".tr, "userChanged".tr);
          Get.off(() => const Login());
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${'username1'.tr} ${'username2'.tr}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> checkUsername(String username) async {
    _validationMsg = null;
    setState(() {});

    //do all sync validation
    if (username.isEmpty) {
      _validationMsg = "UserNameIsRequired".tr;
      setState(() {});
      return;
    }

    // do async validation

    setState(() {});
    if (await userExists(username) == true) {
      _validationMsg = "userIsValid".tr;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Widget usernameWidget() {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) checkUsername(username);
      },
      child: TextFormField(
          controller: _usernameController,
          autovalidateMode: AutovalidateMode.always,
          autofillHints: const [AutofillHints.username],
          decoration: InputDecoration(
            floatingLabelStyle: const TextStyle(height: 4),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.person),
            suffixIcon: IconButton(
              onPressed: () => _usernameController.clear(),
              icon: const Icon(Ionicons.close),
            ),
            label: Text(
              'userName'.tr,
              style: TextStyle(fontSize: ScreenScaler().getTextSize(11)),
            ),
          ),
          onChanged: (value) => username = value,
          validator: (username) => _validationMsg),
    );
  }
}
