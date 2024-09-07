import 'package:flutter/material.dart';

import '../../config/preferences.dart';

/// Get the current color theme (and in some cases we reverse it)
Color getCurrentColor(bool reverse) {
  if (reverse) {
    return Preferences().getThemeMode() == ThemeMode.dark
        ? Colors.white
        : Colors.black;
  }
  return Preferences().getThemeMode() == ThemeMode.dark
      ? Colors.black
      : Colors.white;
}
