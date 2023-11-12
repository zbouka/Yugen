import 'package:flutter/material.dart';

import 'package:yugen/widgets/Recycled/mainWidget.dart';

import '../../config/preferences.dart';

/// Screen that shows the mangas
class Manga extends StatefulWidget {
  const Manga({super.key});

  @override
  State<Manga> createState() => _MangaState();
}

class _MangaState extends State<Manga> {
  bool? validado;
  late bool isDarkTheme;
  @override
  void initState() {
    super.initState();
    isDarkTheme = Preferences().getThemeMode() == ThemeMode.dark ? true : false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (context, orientation) => MainWidget(
            collection: "Mangas",
            collectionFavourites: "MangaFavorites",
            context: context));
  }
}
