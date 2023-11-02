import 'dart:async';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:ionicons/ionicons.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:yugen/screens/main/manga.dart';
import 'package:yugen/widgets/Recycled/error.dart';
import '../screens/main/preferences.dart';
import '../screens/main/anime.dart';
import '../screens/main/news.dart';
import '../screens/main/wallpapers.dart';

/// Just the top navigation bar which allows the user to change the screens
class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({super.key});

  @override
  State<MyNavigationBar> createState() => MyNavigationBarState();
}

class MyNavigationBarState extends State<MyNavigationBar> {
  static late ValueNotifier<bool> hideNavBar;
  int _selectedIndex = 0;
  StreamSubscription? connection;
  bool isoffline = false;
  final purpleColor = const Color.fromARGB(255, 150, 178, 67);
  final greyColor = Colors.grey;
  //Check if there is any connection available
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
    isConnected();
    super.initState();

    hideNavBar = ValueNotifier(false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isoffline == false
        ? Scaffold(
            body: Center(
              child: _buildScreens[_selectedIndex],
            ),
            bottomNavigationBar: FlashyTabBar(
              animationCurve: Curves.bounceIn,
              selectedIndex: _selectedIndex,
              iconSize: 22,
              showElevation: false, // use this to remove appBar's elevation
              onItemSelected: (index) => setState(() {
                _selectedIndex = index;
              }),
              items: [
                FlashyTabBarItem(
                  icon:
                      Icon(Ionicons.book, size: ScreenScaler().getHeight(1.25)),
                  activeColor: purpleColor,
                  inactiveColor: greyColor,
                  title: Text(
                    "Mangas",
                    style: TextStyle(fontSize: ScreenScaler().getTextSize(6.5)),
                  ),
                ),
                FlashyTabBarItem(
                  icon: Icon(Icons.video_library_rounded,
                      size: ScreenScaler().getHeight(1.25)),
                  title: Text(
                    "Animes",
                    style: TextStyle(fontSize: ScreenScaler().getTextSize(6.5)),
                  ),
                  activeColor: purpleColor,
                  inactiveColor: greyColor,
                ),
                FlashyTabBarItem(
                  icon: Icon(Ionicons.newspaper,
                      size: ScreenScaler().getHeight(1.25)),
                  title: Text(
                    "news".tr,
                    style: TextStyle(fontSize: ScreenScaler().getTextSize(6.5)),
                  ),
                  activeColor: purpleColor,
                  inactiveColor: greyColor,
                ),
                FlashyTabBarItem(
                  icon: Icon(Ionicons.image,
                      size: ScreenScaler().getHeight(1.25)),
                  title: Text(
                    "Wallpapers",
                    style: TextStyle(fontSize: ScreenScaler().getTextSize(6.5)),
                  ),
                  activeColor: purpleColor,
                  inactiveColor: greyColor,
                ),
                FlashyTabBarItem(
                  icon: Icon(Ionicons.settings,
                      size: ScreenScaler().getHeight(1.25)),
                  title: Text(
                    "settings".tr,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).orientation ==
                                Orientation.landscape
                            ? ScreenScaler().getTextSize(8)
                            : null),
                  ),
                  activeColor: purpleColor,
                  inactiveColor: greyColor,
                ),
              ],
            ),
          )
        : Scaffold(
            body: Center(
                child: CustomErrorWidget(
              errorMessage: "noInternet".tr,
              errorIcon: const Icon(Icons.wifi_off),
            )),
          );
  }

//List of all Widget Screens
  final List<Widget> _buildScreens = [
    const Manga(),
    const Anime(),
    const Center(child: News()),
    const Wallpapers(),
    const UserPreferences()
  ];
}
