import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yugen/config/preferences.dart';
import 'package:yugen/screens/auth/auth.dart';

import 'login.dart';

/// Screen for resetting password in case it got forgotten
class ResetPass extends StatefulWidget {
  const ResetPass({super.key});

  @override
  State<ResetPass> createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final ScreenScaler scaler;
  final _auth = Auth();
  bool isInitialized = false;
  var email = "";
  Color purpleColor = Colors.deepPurple[700]!;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
              child: _resetPassForm(),
              key: _formKey,
            ),
          ),
        ),
      ),
    );
  }

  /// Checks if the email provided is linked with an external provider
  Future<bool> checkIfGoogle(String email) async {
    var emailProviders =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    if (emailProviders.contains("google.com")) {
      Get.snackbar("ERROR", "invalidProvider".tr);
      return false;
    }
    return true;
  }

  _resetPassForm() {
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
                      "${'reset'.tr} ${'reset2'.tr}",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: scaler.getTextSize(19),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(height: scaler.getHeight(5)),
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
                    SizedBox(
                      height: scaler.getHeight(10),
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1400),
                      child: emailWidget(),
                    ),
                    SizedBox(height: scaler.getHeight(5)),
                    FadeInUp(
                        duration: const Duration(milliseconds: 1600),
                        child: restablishButton()),
                    SizedBox(
                      height: scaler.getHeight(4),
                    ),
                    SizedBox(
                      height: scaler.getHeight(2),
                    ),
                    SizedBox(
                      height: scaler.getHeight(5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: Text(
                              'returnToLogin'.tr,
                              style: TextStyle(
                                  fontSize: ScreenScaler().getTextSize(7.3)),
                            )),
                        const SizedBox(
                          width: 5.0,
                        ),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: InkWell(
                            onTap: () {
                              Get.to(() => const Login());
                            },
                            child: Text(
                              'return'.tr,
                              style: TextStyle(
                                fontSize: ScreenScaler().getTextSize(7.3),
                                color: Colors.deepPurple[400],
                                decoration: TextDecoration.underline,
                              ),
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

  checkFields() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget restablishButton() {
    return MaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: purpleColor,
      onPressed: () async {
        if (checkFields() && await checkIfGoogle(email) == false) {
          await _auth.resetPassword(email);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'reset'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget emailWidget() {
    return TextFormField(
        style: TextStyle(fontSize: scaler.getTextSize(11)),
        controller: _emailController,
        autofillHints: const [AutofillHints.email],
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
          floatingLabelStyle: const TextStyle(height: 4),
          filled: true,
          prefixIcon: const Icon(Icons.email_outlined),
          suffixIcon: IconButton(
            onPressed: () => _emailController.clear(),
            icon: const Icon(Icons.close),
          ),
          label: Text(
            'Email',
            style: TextStyle(fontSize: scaler.getTextSize(11)),
          ),
        ),
        onChanged: (value) {
          email = value;
        },
        validator: (email) =>
            email != null && !GetUtils.isEmail(email) ? 'validEmail'.tr : null);
  }
}
