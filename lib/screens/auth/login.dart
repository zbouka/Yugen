import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yugen/config/preferences.dart';
import 'package:yugen/screens/auth/auth.dart';
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
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  final _auth = Auth();
  bool save = false;

  late ScreenScaler scaler;
  StreamSubscription? _connectionSubscription;
  bool isOffline = false;
  Color purpleColor = Colors.deepPurple[700]!;
  String email = "", pass = "";
  bool loading = false;
  bool isInitialized = false;
  bool _obscureText =
      true; // State variable to manage visibility of the password
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the ScreenScaler using MediaQuery safely here
    scaler = ScreenScaler()..init(context);
  }

  void _initialize() async {
    bool shouldSave =
        await _checkCredentials(); // Wait for async function to complete
    setState(() {
      save = shouldSave; // Set the new value and rebuild the UI
    });
  }

  Future<bool> _checkCredentials() async {
    bool shouldSave = await Preferences().readIfRemember();
    try {
      List<String>? credentials = await Preferences().readCredentials();
      if (credentials != null) {
        _emailController.text = credentials[0];
        _passwordController.text = credentials[1];
      }
    } catch (e) {
      await sendErrorMail(true, "ERROR", e);
    }
    return shouldSave;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      scaler = ScreenScaler()..init(context);
      isInitialized = true;
    }

    return isOffline
        ? Scaffold(
            body: Center(
              child: CustomErrorWidget(
                errorMessage: "noInternet".tr,
                errorIcon: const Icon(Icons.wifi_off),
              ),
            ),
          )
        : loading
            ? Container(
                color: getCurrentColor(false),
                child: const Loading(),
              )
            : _buildLoginScreen();
  }

  Widget _buildLoginScreen() {
    return Scaffold(
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Container(
          height: Get.height,
          width: Get.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.purple.shade900,
                Colors.purple.shade800,
                Colors.purple.shade400,
              ],
            ),
          ),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: scaler.getHeight(10)),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: Text(
                      'welcome1'.tr,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: scaler.getTextSize(19),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: scaler.getHeight(4)),
                Container(
                  decoration: BoxDecoration(
                    color: Preferences().getThemeMode() == ThemeMode.dark
                        ? ThemeData.dark(useMaterial3: true).primaryColor
                        : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      runSpacing: scaler.getHeight(1.5),
                      children: <Widget>[
                        SizedBox(height: scaler.getHeight(4)),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1400),
                          child: _buildEmailWidget(),
                        ),
                        SizedBox(height: scaler.getHeight(2)),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1400),
                          child: _buildPasswordWidget(),
                        ),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: _buildRememberLoginWidget(),
                        ),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: _buildForgotPassWidget(),
                        ),
                        SizedBox(height: scaler.getHeight(5)),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: _buildLoginButton(),
                        ),
                        SizedBox(height: scaler.getHeight(4)),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: _buildLoginButtonGoogle(),
                        ),
                        SizedBox(height: scaler.getHeight(2)),
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
                            SizedBox(width: scaler.getHeight(2)),
                            FadeInUp(
                              duration: const Duration(milliseconds: 1600),
                              child: InkWell(
                                onTap: () => Get.to(() => const Register()),
                                child: Text(
                                  'signUp'.tr,
                                  style: TextStyle(
                                    color: Colors.deepPurple[400],
                                    fontSize: scaler.getTextSize(11),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: scaler.getHeight(10)),
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

  Widget _buildEmailWidget() {
    return TextFormField(
      style: TextStyle(fontSize: scaler.getTextSize(11)),
      controller: _emailController,
      autofillHints: const [AutofillHints.email],
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        fillColor: _emailController.text.isNotEmpty
            ? Preferences().getThemeMode() == ThemeMode.light
                ? ThemeData.light(useMaterial3: true).colorScheme.surface
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
      onChanged: (value) => email = value,
      validator: (email) =>
          email != null && !GetUtils.isEmail(email) ? 'validEmail'.tr : null,
    );
  }

  Widget _buildPasswordWidget() {
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
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText; // Toggle password visibility
                });
              },
              icon: Icon(
                _obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            IconButton(
              onPressed: () => _passwordController.clear(),
              icon: const Icon(Icons.close),
            ),
          ],
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
      obscureText:
          _obscureText, // Use the state variable to control password visibility
      onSaved: (newValue) => pass = newValue!,
      onChanged: (value) => pass = value,
      validator: (value) =>
          value != null && value.length < 8 ? 'PassIsRequired'.tr : null,
    );
  }

  Widget _buildRememberLoginWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "rememberLogin".tr,
          style: TextStyle(fontSize: scaler.getTextSize(11.2)),
        ),
        SizedBox(width: scaler.getWidth(1)),
        Switch.adaptive(
          value: save,
          onChanged: (bool value) {
            setState(() {
              save = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildForgotPassWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => Get.to(() => const ResetPass()),
          child: Text(
            'forgotPass'.tr,
            style: TextStyle(
              color: Colors.deepPurple[400],
              fontSize: scaler.getTextSize(11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return MaterialButton(
      elevation: 2,
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: purpleColor,
      onPressed: _login,
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

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
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
  }

  Widget _buildLoginButtonGoogle() {
    return MaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: Colors.blue[600],
      elevation: 2,
      onPressed: _loginWithGoogle,
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

  Future<void> _loginWithGoogle() async {
    _showLoadingDialog(context);
    try {
      dynamic result = await _auth.signInWithGoogle();
      if (result == null) {
        setState(() {
          loading = false;
        });
      }
    } catch (error) {
      await sendErrorMail(true, "ERROR", error);
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const Loading(),
    );
  }
}
