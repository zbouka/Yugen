import 'package:flutter/material.dart';

import 'package:yugen/widgets/Recycled/mainWidget.dart';

/// Screen that shows the animes
class Anime extends StatefulWidget {
  const Anime({super.key});

  @override
  State<Anime> createState() => _AnimeState();
}

class _AnimeState extends State<Anime> {
  bool isInitialized = false;
  late bool isDarkTheme;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (context, orientation) => const MainWidget(
              collection: "Animes",
              collectionFavourites: "AnimeFavorites",
            ));
  }
}
