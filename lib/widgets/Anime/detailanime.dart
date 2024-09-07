import 'package:translator/translator.dart'; // Import the Google Translator package
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
          locale == "es" ? 'es' : 'en'; // Spanish to English or vice versa

      // Translate genres
      final genres = await Future.wait(
        widget.animeGenres.map(
          (genre) async =>
              (await translator.translate(genre, to: targetLanguage)).text,
        ),
      );

      // Translate anime status and description
      final animeStatus = _translateStatus(widget.animeStatus, targetLanguage);
      final animeDesc =
          (await translator.translate(widget.animeDesc, to: targetLanguage))
              .text;

      return [
        genres.join(", "), // Translated genres
        animeStatus, // Translated anime status
        animeDesc.isEmpty
            ? 'Description not available'
            : animeDesc // Translated description
      ];
    } catch (e) {
      debugPrint('Error translating text: $e');
      return ['Unknown genres', 'Unknown status', 'Description not available'];
    }
  }

  String _translateStatus(String status, String targetLanguage) {
    if (targetLanguage == "es") {
      switch (status) {
        case "Releasing":
          return "En emisión";
        case "Finished":
          return "Finalizado";
        default:
          return status; // Default to the original status if not recognized
      }
    }
    return status; // Default to the original status if target language is not Spanish
  }

  Future<void> _downloadChapters() async {
    try {
      await getChapters(
        "Animes",
        widget.animeTitle,
        widget.animeLang,
        false,
        false,
        chapters: widget.animeChapters,
      );
    } catch (error) {
      sendErrorMail(true, "CHAPTER DOWNLOAD ERROR", error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _translationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: getCurrentColor(false),
            child: const Loading(),
          );
        }

        if (snapshot.hasError) {
          return Container(
            color: getCurrentColor(false),
            child: Center(
              child: Text('Error loading translations: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Container(
            color: getCurrentColor(false),
            child: const Center(child: Text('Error loading translations')),
          );
        }

        final translations = snapshot.data!;

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
                  onPressed: _downloadChapters,
                ),
              ],
            ),
            body: SizedBox(
              height: Get.size.height,
              width: Get.size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// Anime Info - anime image, title, year, status, and number of chapters
                    InfoWidget(
                      img: widget.animeImg,
                      title: widget.animeTitle,
                      lang: widget.animeLang,
                      year: widget.animeYear.toString(),
                      status: translations[1].capitalizeFirst!,
                      numberChapters: widget.animeChapters.length,
                      collectionName: "Animes",
                    ),

                    /// Genres Widget - Shows the anime genres inside Chip widgets
                    GenresWidget(genres: translations[0].split(", ")),

                    /// Shows a tab with 3 items (Description, Chapters, and Comments)
                    ItemInfo(
                      img: widget.animeImg,
                      title: widget.animeTitle,
                      year: widget.animeYear.toString(),
                      status: translations[1].capitalizeFirst!,
                      description: translations[2],
                      chapters: widget.animeChapters,
                      lang: widget.animeLang,
                      collectionName: "Animes",
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
