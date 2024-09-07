import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Class for storing/reading cache in the phone using persistent key/value storage
class Preferences {
  static final GetStorage _getStorage = GetStorage();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Storage keys
  static const String _themeKey = "isDarkMode";
  static const String _firstSeenKey = "firstSeen";
  static const String _androidDialogKey = "androidDialog";
  static const String _localeKey = "locale";
  static const String _rememberCredKey = "rememberCred";
  static const String _emailKey = "email";
  static const String _passwordKey = "password";

  /// Returns the theme mode (dark or light)
  ThemeMode getThemeMode() {
    return isSavedDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }

  /// Checks if dark mode is saved, defaults to false
  bool isSavedDarkMode() {
    return _getStorage.read(_themeKey) ?? false;
  }

  /// Gets the locale string
  String getLocale() {
    return _getStorage.read(_localeKey) ??
        Get.deviceLocale?.languageCode ??
        'en';
  }

  /// Saves the theme mode using the [isDarkMode] boolean
  void saveThemeMode(bool isDarkMode) {
    _getStorage.write(_themeKey, isDarkMode);
  }

  /// Checks if the app is seen for the first time
  bool isFirstSeen() {
    return _getStorage.read(_firstSeenKey) ?? false;
  }

  /// Marks that the introduction screen has been seen
  void setFirstSeenTrue() {
    _getStorage.write(_firstSeenKey, true);
  }

  /// Marks that the special dialog has been opened
  void setDialogOpen() {
    _getStorage.write(_androidDialogKey, true);
  }

  /// Checks if the special dialog was opened
  bool wasDialogOpened() {
    return _getStorage.read(_androidDialogKey) ?? false;
  }

  /// Toggles the theme mode and updates the saved value
  void changeThemeMode() {
    final newThemeMode = isSavedDarkMode() ? ThemeMode.light : ThemeMode.dark;
    Get.changeThemeMode(newThemeMode);
    saveThemeMode(newThemeMode == ThemeMode.dark);
    Get.forceAppUpdate();
  }

  /// Saves the value of a switch to remember login credentials
  Future<void> saveIfRemember(bool save) async {
    await _getStorage.write(_rememberCredKey, save);
  }

  /// Saves the email and password if the user chooses to
  Future<void> saveCreds(String email, String password) async {
    await Future.wait([
      _secureStorage.write(key: _emailKey, value: email),
      _secureStorage.write(key: _passwordKey, value: password),
    ]);
  }

  /// Deletes the saved email and password
  Future<void> deleteCreds() async {
    await Future.wait([
      _secureStorage.delete(key: _emailKey),
      _secureStorage.delete(key: _passwordKey),
    ]);
  }

  /// Reads the value of rememberCred key, defaults to false
  Future<bool> readIfRemember() async {
    return _getStorage.read(_rememberCredKey) ?? false;
  }

  /// Retrieves saved credentials, returning null if they don't exist
  Future<List<String>?> readCredentials() async {
    final savedEmail = await _secureStorage.read(key: _emailKey);
    final savedPassword = await _secureStorage.read(key: _passwordKey);
    if (savedEmail == null || savedPassword == null) {
      return null;
    }
    return [savedEmail, savedPassword];
  }

  /// Updates the value of the locale key with the provided [locale]
  void saveLocale(String locale) {
    _getStorage.write(_localeKey, locale);
  }
}
