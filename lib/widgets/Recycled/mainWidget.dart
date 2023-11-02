import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:yugen/config/preferences.dart';
import 'package:yugen/screens/main/favourites.dart';
import 'package:yugen/screens/main/search_bar.dart';
import 'package:yugen/widgets/Recycled/listWidget.dart';

/// Main Widget used for showing all the UI in the mangas/animes screen, including the top bar with the favorites,search bar and change themes buttons
class MainWidget extends StatefulWidget {
  final String collection, collectionFavourites;
  final BuildContext context;

  const MainWidget(
      {super.key,
      required this.collection,
      required this.collectionFavourites,
      required this.context});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  ///Checks the current theme mode
  late bool isDarkTheme;
  @override
  void initState() {
    super.initState();
    isDarkTheme = Preferences().getThemeMode() == ThemeMode.dark ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.only(
            top: 20,
            left: 10,
            right: 10,
            bottom: 60,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Wrap(
              runSpacing: 10,
              spacing: 10,
              children: [
                /// Top bar with 3 icon buttons (Favourites, search bar and change theme) which lets to their corresponding widgets
                Container(
                  width: double.infinity,
                  alignment: Alignment.topRight,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: IconButton(
                          color: Colors.red,
                          onPressed: () => Get.to(() => Favorites(
                                collectionFavorites:
                                    widget.collectionFavourites,
                                collectionName: widget.collection,
                              )),
                          icon: Icon(Ionicons.heart,
                              color: Colors.red,
                              size: MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? ScreenScaler().getTextSize(11)
                                  : null),
                        ),
                      ),
                      Center(
                          child: searchBar(
                              widget.collection, widget.collectionFavourites)),
                      Expanded(
                        child: IconButton(
                          onPressed: () {
                            Preferences().changeThemeMode();
                            setState(() {
                              isDarkTheme = !isDarkTheme;
                            });
                          },
                          icon: (!isDarkTheme == false)
                              ? const Icon(
                                  Icons.wb_sunny,
                                  color: Colors.yellow,
                                )
                              : const Icon(
                                  Icons.nightlight_round,
                                  color: Colors.black,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                WidgetList(
                    collectionName: widget.collection,
                    collectionFavorites: widget.collectionFavourites),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Used to search in the database
Widget searchBar(String collection, String collectionFavorites) {
  return MySearchBar(
    collection: collection,
    collectionFavorites: collectionFavorites,
  );
}
