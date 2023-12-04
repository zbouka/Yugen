import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

/// Class for storing/reading cache in the phone using persistent key/value storage
class Preferences {
  static final _getStorage = GetStorage("storage");
  final themeKey = "isDarkMode";
  final firstSeen = "firstSeen";
  final androidDialog = "androidDialog";
  final localeKey = "locale";
  final savedLocale = 'localeSaved';
  final rememberCred = 'remembercred';
  final email = 'email';
  final password = 'password';
  final _storage = const FlutterSecureStorage();

  /// Return the thememode (dark or light)
  ThemeMode getThemeMode() {
    return isSavedDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }

  /// Check if is saved dark mode, setting the default value to false
  bool isSavedDarkMode() {
    return _getStorage.read(themeKey) ?? false;
  }

  /// Get the string of the locale
  String getLocale() {
    return _getStorage.read(localeKey) ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  }

  /// Saves the actual theme mode using the [isDarkMode] boolean
  void saveThemeMode(bool isDarkMode) {
    _getStorage.write(themeKey, isDarkMode);
  }

  /// Check if is the first time that the app is seen
  bool isFirstSeen() {
    return _getStorage.read(firstSeen) ?? false;
  }

  /// Check if is the first time seeing the introduction screen
  void setFirstSeenTrue() {
    _getStorage.write(firstSeen, true);
  }

  /// Check if an special dialog was ever opened
  void setDialogOpen() {
    _getStorage.write(androidDialog, true);
  }

  /// Check if is the first time that the app is seen
  bool wasDialogOpened() {
    return _getStorage.read(androidDialog) ?? false;
  }

  /// Changes the theme putting the opposite that is currently saved, and updates the value saved in the theme key
  void changeThemeMode() {
    Get.changeThemeMode(isSavedDarkMode() ? ThemeMode.light : ThemeMode.dark);
    saveThemeMode(!isSavedDarkMode());
    Get.forceAppUpdate();
  }

  /// This method saves the value of a switch which function is to remember the login credentials
  void saveIfRemember(bool save) async {
    _getStorage.write(rememberCred, save);
  }

  /// This method saves the email and password in case the user triggers it activating a switch in login page
  Future<void> saveCreds(String email2, String password2) async {
    await _storage.write(
      key: email,
      value: email2,
    ); // Saves the email
    await _storage.write(
      key: password,
      value: password2,
    ); // Saves the password
  }

  /// This method deletes the saved email and password in case the user triggers it activating a switch in login page
  Future<void> deleteCreds() async {
    await _storage.delete(
      key: email,
    ); // Delete the email
    await _storage.delete(
      key: password,
    ); // Deletes the password
  }

  /// Reads the value of rememberCred key, which value must be a boolean
  bool readIfRemember() {
    return _getStorage.read(rememberCred) ?? false;
  }

  /// Retrieves saved credentials, returning null if they don't exist
  Future<List<String>?> readCredentials() async {
    String? savedEmail = await _storage.read(key: email);

    String? savedPassword = await _storage.read(key: password);
    if (savedEmail == null || savedPassword == null) {
      return null;
    }
    return List.from([savedEmail, savedPassword]);
  }

  /// Updates the value of the locale key by the [locale] string passed
  void saveLocale(String locale) {
    _getStorage.write(localeKey, locale);
  }
}
