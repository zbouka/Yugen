import 'dart:async';
import 'package:translator/translator.dart'; // Import the Google Translator package
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
  final translator = GoogleTranslator(); // Google Translator instance
  late Future<List<String>> _translationsFuture;

  @override
  void initState() {
    super.initState();
    _translationsFuture = _getTranslations();
  }

  Future<List<String>> _getTranslations() async {
    try {
      final locale = Preferences().getLocale();
      final targetLanguage =
          locale == "es" ? 'es' : 'en'; // English to Spanish or vice versa

      // Translate genres
      final genres = await Future.wait(
        widget.mangaGenres.map(
          (genre) async =>
              (await translator.translate(genre, to: targetLanguage)).text,
        ),
      );

      // Translate manga status and description
      final mangaStatus = _translateStatus(widget.mangaStatus, targetLanguage);
      final mangaDesc =
          (await translator.translate(widget.mangaDesc, to: targetLanguage))
              .text;

      return [
        genres.join(", "), // Translated genres
        mangaStatus, // Translated manga status
        mangaDesc.isEmpty
            ? 'Description not available'
            : mangaDesc // Translated description
      ];
    } catch (e) {
      debugPrint('Error translating text: $e');
      return ['Unknown genres', 'Unknown status', 'Description not available'];
    }
  }

  String _translateStatus(String status, String targetLanguage) {
    if (targetLanguage == "es") {
      return status == "Releasing" ? "En emisión" : "Finalizado";
    }
    return status; // Default to the original status
  }

  Future<void> _downloadChapters() async {
    try {
      await getChapters(
        "Mangas",
        widget.mangaTitle,
        widget.mangaLang,
        true,
        false,
        chapters: widget.mangaChapters,
      );
    } catch (error) {
      sendErrorMail(true, "ERROR", error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return FutureBuilder<List<String>>(
      future: _translationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: getCurrentColor(false),
            body: const Center(child: Loading()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: getCurrentColor(false),
            body: Center(
                child: Text('Error loading translations: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: getCurrentColor(false),
            body: const Center(child: Text('Error loading translations')),
          );
        }

        final translations = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Ionicons.arrow_back, color: getCurrentColor(true)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Ionicons.cloud_download_outline,
                    color: getCurrentColor(true)),
                onPressed: _downloadChapters,
              ),
            ],
          ),
          body: SizedBox(
            height: screenSize.height,
            width: screenSize.width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// Manga Info - manga image, author, 3 buttons
                  InfoWidget(
                    img: widget.mangaImg,
                    title: widget.mangaTitle,
                    lang: widget.mangaLang,
                    year: widget.mangaYear.toString(),
                    status: translations[1].capitalizeFirst!,
                    numberChapters: widget.mangaChapters.length,
                    collectionName: "Mangas",
                  ),

                  /// Genres Widget - Shows the manga genres inside Chip widgets
                  GenresWidget(genres: translations[0].split(", ")),

                  /// Tab with 3 items (Description, Chapters, and Comments)
                  ItemInfo(
                    img: widget.mangaImg,
                    title: widget.mangaTitle,
                    year: widget.mangaYear.toString(),
                    status: translations[1].capitalizeFirst!,
                    description: translations[2],
                    chapters: widget.mangaChapters,
                    lang: widget.mangaLang,
                    collectionName: "Mangas",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
