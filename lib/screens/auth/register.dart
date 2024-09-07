import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:yugen/assets/loading.dart';
import 'package:yugen/config/preferences.dart';
import 'package:yugen/widgets/Recycled/error.dart';
import 'package:yugen/widgets/Recycled/get_color.dart';

import '../../apis/email.dart';
import '../../helpers/user_exists.dart';
import 'auth.dart';
import 'login.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Screen that shows several widgets for user enrollment (email and password or google sign-in)
class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _auth = Auth();
  Color purpleColor = Colors.deepPurple[700]!;
  var email = "", pass = "", username = "";
  bool loading = false;
  bool isInitialized = false;
  late final ScreenScaler scaler;
  late TextEditingController _emailController,
      _passwordController,
      _passwordController2,
      _usernameController;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final Connectivity _connectivity = Connectivity();
  bool isoffline = false;
  dynamic _validationMsg;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordController2.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordController2 = TextEditingController();
    _usernameController = TextEditingController();
  }

  void showDialogue(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const Loading(),
    );
  }

  Future<void> initConnectivity() async {
    List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint('Couldn\'t check connectivity status: $e');
      return;
    }

    if (!mounted) return;
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() {
      isoffline = results.contains(ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isInitialized == false) {
      scaler = ScreenScaler()..init(context);
      isInitialized = true;
    }
    return isoffline == false
        ? loading
            ? Container(color: getCurrentColor(false), child: const Loading())
            : Scaffold(
                body: SafeArea(
                    child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: _registerform(),
                  key: _formKey,
                )),
              )
        : Scaffold(
            body: Center(
              child: CustomErrorWidget(
                errorMessage: "noInternet".tr,
                errorIcon: const Icon(Icons.wifi_off),
              ),
            ),
          );
  }

  _checkFields() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<dynamic> checkUsername(String username) async {
    _validationMsg = null;
    setState(() {});

    if (username.isEmpty) {
      _validationMsg = "UserNameIsRequired".tr;
      setState(() {});
      return;
    }

    setState(() {});
    if (await userExists(username) == true) _validationMsg = "userIsValid".tr;

    setState(() {});
  }

  Widget usernameWidget() {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) checkUsername(username);
      },
      child: TextFormField(
          controller: _usernameController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
            label: Text('userName'.tr,
                style: TextStyle(fontSize: scaler.getTextSize(11))),
          ),
          onChanged: (value) => username = value,
          validator: (username) => _validationMsg),
    );
  }

  _registerform() {
    return Container(
        width: Get.width,
        height: Get.height,
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
              SizedBox(
                height: scaler.getHeight(10),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: Text(
                      'create1'.tr,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: scaler.getTextSize(19),
                      ),
                    )),
              ),
              SizedBox(height: scaler.getHeight(4)),
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
                      SizedBox(
                        height: scaler.getHeight(3),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: emailWidget(),
                      ),
                      SizedBox(height: scaler.getHeight(2)),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: usernameWidget(),
                      ),
                      SizedBox(
                        height: scaler.getHeight(3),
                      ),
                      FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: passwordWidget()),
                      SizedBox(
                        height: scaler.getHeight(3),
                      ),
                      FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: passwordWidget2()),
                      SizedBox(
                        height: scaler.getHeight(10),
                      ),
                      FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: loginButton()),
                      SizedBox(
                        height: scaler.getHeight(2),
                      ),
                      FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: loginButtonGoogle()),
                      SizedBox(
                        height: scaler.getHeight(4),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: Text('haveAccount'.tr,
                                style: TextStyle(
                                    fontSize: scaler.getTextSize(11))),
                          ),
                          SizedBox(
                            width: scaler.getWidth(1),
                          ),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: InkWell(
                              onTap: () {
                                Get.to(() => const Login(),
                                    transition: Transition.fadeIn);
                              },
                              child: Text(
                                'login'.tr,
                                style: TextStyle(
                                  color: Colors.deepPurple[400],
                                  fontSize: scaler.getTextSize(11),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget passwordWidget() {
    return TextFormField(
      controller: _passwordController,
      style: TextStyle(fontSize: scaler.getTextSize(11)),
      decoration: InputDecoration(
        fillColor: _passwordController.text.isNotEmpty
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
        label: Text(
          'password'.tr,
          style: TextStyle(fontSize: scaler.getTextSize(11)),
        ),
      ),
      obscureText: true,
      onSaved: (newValue) => pass = newValue!,
      onChanged: (value) => pass = value,
      validator: (value) =>
          value != null && value.length < 8 ? 'PassIsRequired'.tr : null,
    );
  }

  Widget passwordWidget2() {
    return TextFormField(
      controller: _passwordController2,
      style: TextStyle(fontSize: scaler.getTextSize(11)),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        floatingLabelStyle: const TextStyle(height: 4),
        filled: true,
        prefixIcon: const Icon(Icons.password_outlined),
        suffixIcon: IconButton(
          onPressed: () => _passwordController2.clear(),
          icon: const Icon(Ionicons.close),
        ),
        label: Text('password2'.tr,
            style: TextStyle(fontSize: scaler.getTextSize(11))),
      ),
      obscureText: true,
      onChanged: (value) => pass = value,
      validator: (value) => value!.length < 8
          ? 'PassIsRequired'.tr
          : _passwordController.text != value
              ? 'PassNotSame'.tr
              : null,
    );
  }

  Widget emailWidget() {
    return TextFormField(
        controller: _emailController,
        style: TextStyle(fontSize: scaler.getTextSize(11)),
        autofillHints: const [AutofillHints.email],
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
          label:
              Text('Email', style: TextStyle(fontSize: scaler.getTextSize(11))),
          floatingLabelStyle: const TextStyle(height: 4),
          filled: true,
          prefixIcon: const Icon(Icons.email_outlined),
          suffixIcon: IconButton(
            onPressed: () => _emailController.clear(),
            icon: const Icon(Ionicons.close),
          ),
        ),
        onChanged: (value) => email = value,
        validator: (value) =>
            value != null && !GetUtils.isEmail(value) ? 'validEmail'.tr : null);
  }

  Widget loginButton() {
    return MaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: purpleColor,
      onPressed: () async {
        if (_checkFields() && await userExists(username) == false) {
          if (mounted) {
            setState(() {
              loading = true;
            });
          }
          try {
            dynamic result = await _auth.register(email, pass, username);
            if (result == null) {
              if (mounted) {
                setState(() {
                  loading = false;
                });
              }
            }
          } catch (error) {
            sendErrorMail(true, "REGISTER ERROR", error);
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'register'.tr,
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
        setState(() {
          loading = true;
        });
        try {
          dynamic result = await _auth.signInWithGoogle();
          if (result != null) {
            setState(() {
              loading = false;
            });
          }
        } catch (error) {
          sendErrorMail(true, "REGISTER ERROR GOOGLE", error);
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
              'googleRegister'.tr,
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
