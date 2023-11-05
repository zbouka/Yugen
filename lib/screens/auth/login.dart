import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yugen/config/preferences.dart';

import 'package:yugen/screens/auth/auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:yugen/screens/auth/register.dart';
import 'package:yugen/screens/auth/reset_password.dart';
import 'package:yugen/widgets/Recycled/error.dart';
import 'package:yugen/widgets/Recycled/get_color.dart';

import '../../assets/loading.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';

import '../../apis/email.dart';

/// Screen that shows several widgets for user login (email, password or google sign-in)
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController _emailController, _passwordController;
  final _formKey = GlobalKey<FormState>();
  final _auth = Auth();
  late bool save;
  late final ScreenScaler scaler;
  StreamSubscription? connection;
  bool isoffline = false;
  Color purpleColor = Colors.deepPurple[700]!;
  String email = "", pass = "";
  String? savedEmail, savedPassword;
  bool loading = false;
  bool isInitialized = false;

  void isConnected() {
    connection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // whenevery connection status is changed.
      if (result == ConnectivityResult.none) {
        //there is no any connection
        setState(() {
          isoffline = true;
        });
      } else if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        //connection is mobile data network
        setState(() {
          isoffline = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    isConnected();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    checkCredentials().then((value) {
      save = value;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> checkCredentials() async {
    save = Preferences().readIfRemember();
    try {
      List<String>? credentials = await Preferences().readCredentials();
      if (credentials != null) {
        _emailController.text = credentials[0];
        _passwordController.text = credentials[1];
      }
    } catch (e) {
      sendErrorMail(true, "ERROR", e);
    }

    return save;
  }

  @override
  Widget build(BuildContext context) {
    if (isInitialized == false) {
      scaler = ScreenScaler()..init(context);
      isInitialized = true;
    }
    return isoffline == false
        ? loading
            ? Container(
                color: getCurrentColor(false),
                child: const Loading(),
              )
            : welcomeWidget()
        : Scaffold(
            body: Center(
                child: CustomErrorWidget(
            errorMessage: "noInternet".tr,
            errorIcon: const Icon(Icons.wifi_off),
          ))
            /* Image.asset(
                "lib/assets/no_internet.png",
                width: Get.width - 50,
              ),
            */
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

  void showDialogue(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const Loading(),
    );
  }

  Widget welcomeWidget() {
    return Scaffold(
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Colors.purple.shade900,
            Colors.purple.shade800,
            Colors.purple.shade400
          ])),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          duration: Duration(milliseconds: 1000),
                          child: Text(
                            'welcome1'.tr,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: scaler.getTextSize(19),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
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
                          child: emailWidget(),
                        ),
                        SizedBox(height: scaler.getHeight(2)),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1400),
                          child: passwordWidget(),
                        ),
                        FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: rememberLogin()),
                        FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: forgotPass()),
                        SizedBox(
                          height: scaler.getHeight(5),
                        ),
                        FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: loginButton()),
                        SizedBox(
                          height: scaler.getHeight(4),
                        ),
                        FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: loginButtonGoogle()),
                        SizedBox(
                          height: scaler.getHeight(2),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeInUp(
                              duration: const Duration(milliseconds: 1600),
                              child: Text(
                                'notAccount'.tr,
                                style:
                                    TextStyle(fontSize: scaler.getTextSize(11)),
                              ),
                            ),
                            SizedBox(
                              width: scaler.getHeight(2),
                            ),
                            FadeInUp(
                              duration: const Duration(milliseconds: 1600),
                              child: InkWell(
                                onTap: () {
                                  Get.to(() => const Register());
                                },
                                child: Text(
                                  'signUp'.tr,
                                  style: TextStyle(
                                      color: Colors.deepPurple[400],
                                      decoration: TextDecoration.underline,
                                      fontSize: scaler.getTextSize(11)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget emailWidget() {
    return ValueListenableBuilder(
        valueListenable: _emailController,
        builder: (context, TextEditingValue value, __) {
          return TextFormField(
              style: TextStyle(fontSize: scaler.getTextSize(11)),
              controller: _emailController,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                fillColor: savedEmail != null &&
                        savedPassword != null &&
                        _emailController.text.isNotEmpty
                    ? Preferences().getThemeMode() == ThemeMode.light
                        ? ThemeData.light(useMaterial3: true)
                            .colorScheme
                            .background
                        : ThemeData.dark(useMaterial3: true).hoverColor
                    : null,
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
              onSaved: (newValue) => email = newValue!,
              onChanged: (value) {
                email = value;
              },
              validator: (email) => email != null && !GetUtils.isEmail(email)
                  ? 'validEmail'.tr
                  : null);
        });
  }

  Widget passwordWidget() {
    return TextFormField(
      controller: _passwordController,
      style: TextStyle(fontSize: scaler.getTextSize(11)),
      decoration: InputDecoration(
        fillColor: savedEmail != null &&
                savedPassword != null &&
                _passwordController.text.isNotEmpty
            ? Preferences().getThemeMode() == ThemeMode.light
                ? ThemeData.light(useMaterial3: true).hoverColor
                : ThemeData.dark(useMaterial3: true).hoverColor
            : null,
        floatingLabelStyle: const TextStyle(height: 4),
        filled: true,
        prefixIcon: const Icon(Icons.password_outlined),
        suffixIcon: IconButton(
          onPressed: () => _passwordController.clear(),
          icon: const Icon(Icons.close),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        label: Text('password'.tr,
            style: TextStyle(fontSize: scaler.getTextSize(11))),
      ),
      obscureText: true,
      onSaved: (newValue) => pass = newValue!,
      onChanged: (value) => pass = value,
      validator: (value) => value!.length < 8 ? 'PassIsRequired'.tr : null,
    );
  }

  Widget rememberLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("rememberLogin".tr),
        SizedBox(
          width: scaler.getWidth(1),
        ),
        Switch.adaptive(
          // This bool value toggles the switch.
          value: save,
          onChanged: (bool value) {
            // This is called when the user toggles the switch.
            setState(() {
              save = value;
            });
          },
        ),
      ],
    );
  }

  Widget forgotPass() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          child: InkWell(
            onTap: () => Get.to(() => const ResetPass()),
            child: Text(
              'forgotPass'.tr,
              style: TextStyle(
                  color: Colors.deepPurple[400],
                  fontSize: scaler.getTextSize(11),
                  decoration: TextDecoration.underline),
            ),
          ),
        ),
      ],
    );
  }

  /// Login button
  Widget loginButton() {
    return MaterialButton(
      elevation: 2,
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: purpleColor,
      onPressed: () async {
        if (checkFields()) {
          setState(() {
            loading = true;
          });
          try {
            UserCredential? result = await _auth.signIn(email, pass, save);
            if (result == null) {
              setState(() {
                loading = false;
              });
            }
          } catch (error) {
            await sendErrorMail(true, "LOGGING ERROR", error);
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'login'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: scaler.getTextSize(13),
            ),
          ),
        ],
      ),
    );
  }

  Widget loginButtonGoogle() {
    return MaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: Colors.blue[600],
      onPressed: () async {
        showDialogue(context);
        try {
          dynamic result = await _auth.signInWithGoogle();
          if (result == null) {
            setState(() {
              loading = false;
            });
          }
        } catch (error) {
          sendErrorMail(true, "ERROR", error);
        }
      },
      elevation: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: ImageIcon(
              AssetImage("lib/assets/google.png"),
            ),
          ),
          const SizedBox(width: 10.0),
          Center(
            child: Text(
              'googleLogin'.tr,
              style: TextStyle(
                fontSize: scaler.getTextSize(13),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
