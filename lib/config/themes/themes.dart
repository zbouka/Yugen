import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Class to customize the dark and light theme used in the app
class Themes {
  final lightTheme = ThemeData(
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
    useMaterial3: true,
    primaryColor: Colors.white,
    brightness: Brightness.light,
    primaryColorDark: Colors.black,
    canvasColor: Colors.white,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.blue,
    ),
  );
  final darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
    primaryColor: Colors.black,
    primaryColorLight: Colors.black,
    brightness: Brightness.dark,
    primaryColorDark: Colors.black,
    indicatorColor: Colors.white,
    canvasColor: Colors.black,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.blue,
    ),
  );
}
