import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:yugen/screens/auth/auth.dart';
import 'package:yugen/widgets/Anime/detailanime.dart';

import 'package:yugen/widgets/Manga/detailmanga.dart';

/// The card used to represent the manga/anime
class MyCard extends StatefulWidget {
  final String img, title, lang, desc, status;
  final int year, numberChapters;
  final List<dynamic> genres;
  final chapters;
  final String collectionFavorites;
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
  });

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  bool _isFavorite = false;
  bool isInitialized = false;
  late final ScreenScaler scaler;
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  Object? miError;

  /// Removes the favorite from the collection
  removeFavorite(
      String currentUserID, String mangaTitle, String mangaLang) async {
    try {
      _database
          .collection("Users")
          .doc(currentUserID)
          .collection(widget.collectionFavorites)
          .where("title", isEqualTo: "$mangaTitle(${mangaLang.toLowerCase()})")
          .get()
          .then((favorites) {
        favorites.docs.forEach((element) async {
          await element.reference.delete();
        });
        setState(() {
          _isFavorite = false;
        });
      });
    } catch (e) {
      print("A");
    }
  }

  /// Adds the selected item to the collection
  addFavorite(String currentUserID, String mangaTitle, String mangaLang) async {
    try {
      var docRef = _database
          .collection("Users")
          .doc(currentUserID)
          .collection(widget.collectionFavorites)
          .doc();

      docRef.set({"title": "$mangaTitle(${mangaLang.toLowerCase()})"},
          SetOptions(merge: true));
      setState(() {
        _isFavorite = true;
      });
    } catch (e) {
      print("A");
    }
  }

  /// Checks if the item is favorite
  bool isFavorite(String userID, String mangaID, String mangaLang) {
    _database
        .collection("Users")
        .doc(userID)
        .collection(widget.collectionFavorites)
        .where("title", isEqualTo: "$mangaID(${mangaLang.toLowerCase()})")
        .snapshots()
        .forEach((element) {
      if (mounted) {
        setState(() {
          _isFavorite = element.docs.isNotEmpty;
        });
      }
    });
    return _isFavorite;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isInitialized == false) {
      scaler = ScreenScaler()..init(context);
      isInitialized = true;
    }
    String lang = "";
    if (widget.lang == "en") {
      lang = "us";
    } else if (widget.lang == "es") {
      lang = "es";
    }
    return GestureDetector(
      onTap: () {
        widget.collectionFavorites == "MangaFavorites"
            ? Get.to(
                () => DetailManga(
                  mangaDesc: widget.desc,
                  mangaGenres: widget.genres,
                  mangaChapters: widget.chapters,
                  mangaImg: widget.img,
                  mangaStatus: widget.status,
                  mangaTitle: widget.title,
                  mangaYear: widget.year,
                  mangaLang: widget.lang,
                  numberChapters: widget.numberChapters,
                ),
              )
            : Get.to(
                () => DetailAnime(
                  animeDesc: widget.desc,
                  animeGenres: widget.genres,
                  animeChapters: widget.chapters,
                  animeImg: widget.img,
                  animeStatus: widget.status,
                  animeTitle: widget.title,
                  animeYear: widget.year,
                  animeLang: widget.lang,
                  numberChapters: widget.numberChapters,
                ),
              );
      },
      child: SizedBox(
        height: 250,
        width: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  widget.img,
                  width: 125,
                  errorBuilder: (context, error, stackTrace) {
                    //setState() not needed, because the widget doesn´t even build
                    miError = error;

                    return const Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    );
                  },
                  fit: BoxFit.fill,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                        child: LoadingAnimationWidget.beat(
                      color: Colors.deepPurple,
                      size: 20,
                    ));
                  },
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: SizedBox(
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
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Image.asset('icons/flags/png/$lang.png',
                        width: 30, fit: BoxFit.fill, package: 'country_icons'),
                  ),
                  IconButton(
                    alignment: Alignment.topRight,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      miError == null
                          ? Auth().getUser() != null
                              ? isFavorite(Auth().getUser()!.uid, widget.title,
                                      widget.lang)
                                  ? removeFavorite(Auth().getUser()!.uid,
                                      widget.title, widget.lang)
                                  : addFavorite(Auth().getUser()!.uid,
                                      widget.title, widget.lang)
                              : null
                          : null;
                    },
                    icon: Auth().getUser() != null
                        ? isFavorite(Auth().getUser()!.uid, widget.title,
                                widget.lang)
                            ? const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              )
                            : const Icon(
                                Icons.favorite_border,
                                color: Colors.red,
                              )
                        : Container(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
