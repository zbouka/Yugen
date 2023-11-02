import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_mlkit_translate_text/fl_mlkit_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:get/get.dart';
import 'package:yugen/apis/email.dart';
import 'package:yugen/config/preferences.dart';
import 'package:yugen/widgets/Recycled/genres.dart';
import 'package:yugen/widgets/Recycled/get_color.dart';
import 'package:yugen/widgets/Recycled/tabbar.dart';
import '../../assets/loading.dart';
import 'package:yugen/widgets/Recycled/info.dart';
import '../Recycled/permissions.dart';

/// Screen that shows the details of the anime once the user enters
class DetailAnime extends StatefulWidget {
  final String animeImg, animeTitle, animeDesc, animeStatus, animeLang;
  final int animeYear, numberChapters;

  final List<dynamic> animeGenres, animeChapters;
  const DetailAnime({
    super.key,
    required this.animeImg,
    required this.animeTitle,
    required this.animeDesc,
    required this.animeGenres,
    required this.animeStatus,
    required this.animeChapters,
    required this.animeYear,
    required this.numberChapters,
    required this.animeLang,
  });

  @override
  State<DetailAnime> createState() => _DetailAnimeState();
}

class _DetailAnimeState extends State<DetailAnime> {
  FlMlKitTranslateText translate = FlMlKitTranslateText();
  late Future<List<String>> translations;
  @override
  void initState() {
    super.initState();

    if (mounted) {
      setState(() {
        translations = _getTranslations();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  final collection = FirebaseFirestore.instance.collection('Animes');

  /// The translation method of all the strings contained in the manga to the selected language
  /// with the exception of 3 strings which are manually translated because the provided translation was horrible
  Future<List<String>> _getTranslations() async {
    Preferences().getLocale() == "en"
        ? await translate.switchLanguage(
            TranslateLanguage.spanish, TranslateLanguage.english)
        : await translate.switchLanguage(
            TranslateLanguage.english, TranslateLanguage.spanish);
    List<String> translationsList = [];

    var genres = [];
    for (var i = 0; i < widget.animeGenres.length; i++) {
      genres.add(await translate.translate(widget.animeGenres[i],
          downloadModelIfNeeded: true));
    }
    var animeStatus = "";

    if (Preferences().getLocale() == "en") {
      animeStatus = widget.animeStatus.toString();
    } else if (Preferences().getLocale() == "es" &&
        widget.animeStatus.toString() == "Releasing") {
      animeStatus = "En emisión";
    } else if (Preferences().getLocale() == "es" &&
        widget.animeStatus.toString() == "Finished") {
      animeStatus = "Finalizado";
    }
    var animeDesc = await translate.translate(widget.animeDesc.toString(),
        downloadModelIfNeeded: true);
    translationsList.add(genres.join(","));
    translationsList.add(animeStatus);
    translationsList.add(animeDesc!);

    return translationsList;
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = const AlertDialog(
      content: Row(
        children: [
          Loading(),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: translations,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: getCurrentColor(false),
              child: const Loading(),
            );
          } else {
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Ionicons.arrow_back,
                      color: getCurrentColor(true),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Ionicons.cloud_download_outline,
                          color: getCurrentColor(true)),
                      onPressed: () async {
                        try {
                          await getChapters("Animes", widget.animeTitle,
                              widget.animeLang, false, false,
                              chapters: widget.animeChapters);
                        } catch (error) {
                          sendErrorMail(true, "CHAPTER DOWNLOAD ERROR", error);
                        }
                      },
                    )
                  ],
                ),
                body: SizedBox(
                  height: Get.size.height,
                  width: Get.size.width,
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      children: [
                        /// animeInfo - anime img, author, 3 button
                        InfoWidget(
                          img: widget.animeImg,
                          title: widget.animeTitle,
                          lang: widget.animeLang,
                          year: widget.animeYear.toString(),
                          status: snapshot.data![1].capitalize!.toString(),
                          numberChapters: widget.animeChapters.length,
                          collectionName: "Animes",
                        ),

                        /// genreswidget - just shows the anime genres inside Chip widgets
                        GenresWidget(genres: snapshot.data![0].split(",")),

                        /// Shows a tab with 3 items (Description, Chapters and Comments)
                        ItemInfo(
                          img: widget.animeImg,
                          title: widget.animeTitle,
                          year: widget.animeYear.toString(),
                          status: snapshot.data![1].capitalize!.toString(),
                          description: snapshot.data![2],
                          chapters: widget.animeChapters,
                          lang: widget.animeLang,
                          collectionName: "Animes",
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}
