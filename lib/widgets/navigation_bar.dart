import 'dart:async';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:yugen/helpers/check_device.dart';
import 'package:yugen/screens/main/manga.dart';
import 'package:yugen/widgets/Recycled/error.dart';
import '../config/preferences.dart';
import '../screens/main/preferences.dart';
import '../screens/main/anime.dart';
import '../screens/main/news.dart';
import '../screens/main/wallpapers.dart';

/// Top navigation bar that allows the user to switch screens
class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({super.key});

  @override
  State<MyNavigationBar> createState() => MyNavigationBarState();
}

class MyNavigationBarState extends State<MyNavigationBar> {
  static late ValueNotifier<bool> hideNavBar;
  int _selectedIndex = 0;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final Connectivity _connectivity = Connectivity();
  bool isOffline = false;
  final Color purpleColor = const Color.fromARGB(255, 150, 178, 67);
  final Color greyColor = Colors.grey;

  /// Checks if there is any connection available
  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    hideNavBar = ValueNotifier(false);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel(); // Properly cancel subscription
    super.dispose();
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
      isOffline = results.contains(ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isOffline ? _buildOfflineWidget() : _buildScreens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildOfflineWidget() {
    return Center(
      child: CustomErrorWidget(
        errorMessage: "noInternet".tr,
        errorIcon: const Icon(Icons.wifi_off),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final themeMode = Preferences().getThemeMode();
    final isDarkMode = themeMode == ThemeMode.dark;
    final isTabletMode = isTablet;
    final iconSize = ScreenScaler().getHeight(1.25);
    final textSize = isTabletMode
        ? ScreenScaler().getTextSize(8)
        : ScreenScaler().getTextSize(6.5);

    return FlashyTabBar(
      backgroundColor: isDarkMode
          ? ThemeData.dark(useMaterial3: true).primaryColor
          : Colors.white,
      animationCurve: Curves.bounceIn,
      selectedIndex: _selectedIndex,
      iconSize: iconSize,
      showElevation: false, // Removes the appBar's elevation
      onItemSelected: (index) => setState(() {
        _selectedIndex = index;
      }),
      items: _buildTabBarItems(textSize, iconSize, context),
    );
  }

  List<FlashyTabBarItem> _buildTabBarItems(
      double textSize, double iconSize, BuildContext context) {
    return [
      _buildTabBarItem(Ionicons.book, "Mangas", textSize, iconSize),
      _buildTabBarItem(
          Icons.video_library_rounded, "Animes", textSize, iconSize),
      _buildTabBarItem(Ionicons.newspaper, "news".tr, textSize, iconSize),
      _buildTabBarItem(Ionicons.image, "Wallpapers", textSize, iconSize),
      _buildTabBarItem(Ionicons.settings, "settings".tr, textSize, iconSize),
    ];
  }

  FlashyTabBarItem _buildTabBarItem(
    IconData icon,
    String title,
    double textSize,
    double iconSize,
  ) {
    return FlashyTabBarItem(
      icon: Icon(icon, size: iconSize),
      activeColor: purpleColor,
      inactiveColor: greyColor,
      title: Text(
        title,
        style: TextStyle(
          fontSize: MediaQuery.of(context).orientation == Orientation.landscape
              ? ScreenScaler().getTextSize(8)
              : textSize,
        ),
      ),
    );
  }

  // List of all widget screens
  final List<Widget> _buildScreens = [
    const Manga(),
    const Anime(),
    const News(),
    const Wallpapers(),
    const UserPreferences(),
  ];
}
