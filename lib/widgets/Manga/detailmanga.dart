import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_mlkit_translate_text/fl_mlkit_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:get/get.dart';
import 'package:yugen/apis/email.dart';
import 'package:yugen/config/preferences.dart';

import 'package:yugen/widgets/Recycled/genres.dart';
import 'package:yugen/widgets/Recycled/info.dart';
import 'package:yugen/widgets/Recycled/tabbar.dart';
import '../../assets/loading.dart';
import '../Recycled/get_color.dart';
import '../Recycled/permissions.dart';

/// Screen that shows the details about the selected manga
class DetailManga extends StatefulWidget {
  final String mangaImg, mangaTitle, mangaDesc, mangaStatus, mangaLang;
  final int mangaYear, numberChapters;

  final List<dynamic> mangaGenres, mangaChapters;
  const DetailManga({
    super.key,
    required this.mangaImg,
    required this.mangaTitle,
    required this.mangaDesc,
    required this.mangaGenres,
    required this.mangaStatus,
    required this.mangaChapters,
    required this.mangaYear,
    required this.numberChapters,
    required this.mangaLang,
  });

  @override
  State<DetailManga> createState() => _DetailMangaState();
}

class _DetailMangaState extends State<DetailManga> {
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

  final collection = FirebaseFirestore.instance.collection('Mangas');

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
    for (var i = 0; i < widget.mangaGenres.length; i++) {
      genres.add(await translate.translate(widget.mangaGenres[i],
          downloadModelIfNeeded: true));
    }
    var mangaStatus = "";
    if (Preferences().getLocale() == "en" &&
            widget.mangaStatus.toString() == "Finished" ||
        Preferences().getLocale() == "en" &&
            widget.mangaStatus.toString() == "Releasing") {
      mangaStatus = widget.mangaStatus.toString();
    } else if (Preferences().getLocale() == "es" &&
        widget.mangaStatus.toString() == "Releasing") {
      mangaStatus = "En emisión";
    } else if (Preferences().getLocale() == "es" &&
        widget.mangaStatus.toString() == "Finished") {
      mangaStatus = "Finalizado";
    }
    var mangaDesc = await translate.translate(widget.mangaDesc.toString(),
        downloadModelIfNeeded: true);
    translationsList.add(genres.join(","));
    translationsList.add(mangaStatus);
    translationsList.add(mangaDesc!);
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
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return FutureBuilder<List<String>>(
        future: _getTranslations(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: getCurrentColor(false),
              child: const Loading(),
            );
          } else {
            return Scaffold(
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
                          await getChapters("Mangas", widget.mangaTitle,
                              widget.mangaLang, true, false,
                              chapters: widget.mangaChapters);
                        } catch (error) {
                          sendErrorMail(true, "ERROR", error);
                        }
                      })
                ],
              ),
              body: SizedBox(
                height: screenSize.height,
                width: screenSize.width,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// mangaInfo - manga img, author, 3 button
                      InfoWidget(
                        img: widget.mangaImg,
                        title: widget.mangaTitle,
                        lang: widget.mangaLang,
                        year: widget.mangaYear.toString(),
                        status: snapshot.data![1].capitalize!.toString(),
                        numberChapters: widget.mangaChapters.length,
                        collectionName: "Mangas",
                      ),

                      /// genreswidget - just shows the anime genres inside Chip widgets
                      GenresWidget(genres: snapshot.data![0].split(",")),

                      /// Shows a tab with 3 items (Description, Chapters and Comments)
                      ItemInfo(
                        img: widget.mangaImg,
                        title: widget.mangaTitle,
                        year: widget.mangaYear.toString(),
                        status: snapshot.data![1].capitalize!.toString(),
                        description: snapshot.data![2].toString(),
                        chapters: widget.mangaChapters,
                        lang: widget.mangaLang,
                        collectionName: "Mangas",
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
