import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:yugen/screens/auth/auth.dart';
import 'package:yugen/widgets/Anime/detailanime.dart';
import 'package:yugen/widgets/Manga/detailmanga.dart';
import 'package:yugen/widgets/Recycled/favorite_controller.dart';

/// The card used to represent the manga/anime
class MyCard extends StatefulWidget {
  final String img, title, lang, desc, status;
  final int year, numberChapters;
  final List<dynamic> genres;
  final dynamic chapters; // Dynamic type for clarity
  final String collectionFavorites;
  final VoidCallback? onDelete; // Add onDelete callback

  const MyCard({
    super.key,
    required this.img,
    required this.title,
    required this.desc,
    required this.genres,
    required this.lang,
    required this.status,
    required this.chapters,
    required this.year,
    required this.numberChapters,
    required this.collectionFavorites,
    this.onDelete, // Add onDelete callback
  });

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  bool _isFavorite = false;
  late ScreenScaler scaler;
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final FavoritesController favoritesController = Get.find();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scaler = ScreenScaler()..init(context);
    _checkFavoriteStatus();
  }

  /// Check if the manga/anime is marked as favorite
  Future<void> _checkFavoriteStatus() async {
    final user = Auth().getUser();
    if (user == null) return;

    final title = "${widget.title}(${widget.lang.toLowerCase()})";
    final docRef = _database
        .collection("Users")
        .doc(user.uid)
        .collection(widget.collectionFavorites)
        .doc(title);

    final docSnapshot = await docRef.get();

    if (mounted) {
      setState(() {
        _isFavorite = docSnapshot.exists;
      });
    }
  }

  /// Toggle favorite status
  Future<void> _toggleFavoriteStatus() async {
    final user = Auth().getUser();
    if (user == null) return;

    final title = "${widget.title}(${widget.lang.toLowerCase()})";
    final docRef = _database
        .collection("Users")
        .doc(user.uid)
        .collection(widget.collectionFavorites)
        .doc(title);

    if (_isFavorite) {
      await docRef.delete();
      favoritesController.removeFavorite(title); // Notify controller
    } else {
      await docRef.set({"title": title}, SetOptions(merge: true));
      favoritesController.addFavorite(title); // Notify controller
    }

    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final flagLang = _getFlagLang(widget.lang);

    return GestureDetector(
      onTap: () => _navigateToDetailPage(),
      child: SizedBox(
        height: scaler.getHeight(70),
        width: scaler.getWidth(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  widget.img,
                  width: scaler.getWidth(28),
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    );
                  },
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: LoadingAnimationWidget.beat(
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: Center(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: scaler.getTextSize(11)),
                ),
              ),
            ),
            Flexible(
              flex: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (flagLang.isNotEmpty)
                    Image.asset(
                      'icons/flags/png250px/$flagLang.png',
                      width: 30,
                      fit: BoxFit.cover,
                      package: 'country_icons',
                    ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _toggleFavoriteStatus();
                      if (widget.onDelete != null && _isFavorite) {
                        widget.onDelete!(); // Call the onDelete callback
                      }
                    },
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFlagLang(String lang) {
    switch (lang) {
      case 'en':
        return 'us';
      case 'es':
        return 'es';
      default:
        return '';
    }
  }

  void _navigateToDetailPage() {
    final detailPage = widget.collectionFavorites == "MangaFavorites"
        ? DetailManga(
            mangaDesc: widget.desc,
            mangaGenres: widget.genres,
            mangaChapters: widget.chapters,
            mangaImg: widget.img,
            mangaStatus: widget.status,
            mangaTitle: widget.title,
            mangaYear: widget.year,
            mangaLang: widget.lang,
            numberChapters: widget.numberChapters,
          )
        : DetailAnime(
            animeDesc: widget.desc,
            animeGenres: widget.genres,
            animeChapters: widget.chapters,
            animeImg: widget.img,
            animeStatus: widget.status,
            animeTitle: widget.title,
            animeYear: widget.year,
            animeLang: widget.lang,
            numberChapters: widget.numberChapters,
          );

    Get.to(() => detailPage);
  }
}
