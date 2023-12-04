import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_storage/get_storage.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yugen/config/lang/languages.dart';
import 'package:yugen/config/preferences.dart';
import 'package:yugen/firebase_options.dart';
import 'package:yugen/screens/splash.dart';
import 'package:get/get.dart';
import 'config/themes/themes.dart';

void main() async {
  ///Wait and inicialize firebase (for database) and getstorage (persistance data)
  WidgetsFlutterBinding.ensureInitialized();

  // Plugin must be initialized before using
  // Initialize
  // Plugin must be initialized before using

  await FlutterDownloader.initialize(
      debug:
          true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GetStorage.init();
  FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  runApp(
    ///In order to use routes/snackbars/dialogs/bottomsheets without context i need to use a getmaterialapp instead of materialapp
    GetMaterialApp(
      title: 'Yugen',
      builder: (context, widget) => ResponsiveBreakpoints.builder(
          child: widget!,

          ///Breakpoint depending on the size of screen
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          ]),
      //default light and dark theme, and disable banner (debug)
      theme: Themes().lightTheme,
      darkTheme: Themes().darkTheme,

      debugShowCheckedModeBanner: false,
      themeMode: Preferences().getThemeMode(),

      ///Set up the translations and put the translations available with the fallback (in case of not founding one)
      translations:
          Language(enLanguage: EnLanguage(), esLanguage: EsLanguage()),
      locale: Locale(Preferences().getLocale()),
      fallbackLocale: const Locale('en'),

      home: const Yugen(),
    ),
  );
}

///Loads the splash screen
class Yugen extends StatelessWidget {
  const Yugen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Splash();
  }
}
