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
import 'package:yugen/widgets/Recycled/favorite_controller.dart';
import 'config/themes/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize FlutterDownloader
    await FlutterDownloader.initialize(
      debug: true, // Enable or disable debug logs
      ignoreSsl: true, // Allow HTTP links
    );

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize GetStorage
    await GetStorage.init();

    // Configure Firestore settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Register FavoritesController with GetX
    Get.put(FavoritesController());
  } catch (e) {
    // Handle initialization errors
    print('Initialization Error: $e');
  }

  runApp(
    GetMaterialApp(
      title: 'Yugen',
      builder: (context, widget) => ResponsiveBreakpoints.builder(
        child: widget!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
        ],
      ),
      theme: Themes().lightTheme,
      darkTheme: Themes().darkTheme,
      debugShowCheckedModeBanner: false,
      themeMode: Preferences().getThemeMode(),
      translations: Language(
        enLanguage: EnLanguage(),
        esLanguage: EsLanguage(),
      ),
      locale: Locale(Preferences().getLocale()),
      fallbackLocale: const Locale('en'),
      home: const Yugen(),
    ),
  );
}

class Yugen extends StatelessWidget {
  const Yugen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Splash();
  }
}
