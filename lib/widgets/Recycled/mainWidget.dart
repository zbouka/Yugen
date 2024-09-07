import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:yugen/config/preferences.dart';
import 'package:yugen/screens/main/favourites.dart';
import 'package:yugen/screens/main/search_bar.dart';
import 'package:yugen/widgets/Recycled/favorite_controller.dart';
import 'package:yugen/widgets/Recycled/listWidget.dart';

class MainWidget extends StatefulWidget {
  final String collection;
  final String collectionFavourites;

  const MainWidget({
    super.key,
    required this.collection,
    required this.collectionFavourites,
  });

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  late bool isDarkTheme;
  late ScreenScaler scaler;
  final FavoritesController favoritesController = Get.find();

  @override
  void initState() {
    super.initState();
    isDarkTheme = Preferences().getThemeMode() == ThemeMode.dark;
    // ScreenScaler initialization should be moved to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scaler = ScreenScaler()..init(context);
  }

  void _toggleTheme() {
    Preferences().changeThemeMode();
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Top bar with icon buttons for favorites, search bar, and theme change
                SizedBox(
                  width: double.infinity,
                  height: scaler.getHeight(6), // Adjust height as needed
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        color: Colors.red,
                        onPressed: () => Get.to(() => Favorites(
                              collectionFavorites: widget.collectionFavourites,
                              collectionName: widget.collection,
                            )),
                        icon: Icon(
                          Ionicons.heart,
                          color: Colors.red,
                          size: scaler.getTextSize(15), // Adjust size as needed
                        ),
                      ),
                      searchBar(widget.collection, widget.collectionFavourites),
                      IconButton(
                        onPressed: _toggleTheme,
                        icon: Icon(
                          isDarkTheme ? Icons.wb_sunny : Icons.nightlight_round,
                          color: isDarkTheme ? Colors.yellow : Colors.black,
                          size: scaler.getTextSize(15), // Adjust size as needed
                        ),
                      ),
                    ],
                  ),
                ),
                WidgetList(
                  collectionName: widget.collection,
                  collectionFavorites: widget.collectionFavourites,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget to create the search bar
  Widget searchBar(String collection, String collectionFavorites) {
    return MySearchBar(
      collection: collection,
      collectionFavorites: collectionFavorites,
    );
  }
}
