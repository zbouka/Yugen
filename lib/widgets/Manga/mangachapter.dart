import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:yugen/apis/email.dart';
import 'package:yugen/config/preferences.dart';
import 'package:yugen/widgets/Manga/images.dart';
import '../../config/themes/themes.dart';
import '../Recycled/permissions.dart';

/// Shows the manga chapters list
class MangaChapters extends StatelessWidget {
  final List<dynamic> mangaChapters;
  final String mangaTitle, mangaLang;

  const MangaChapters({
    super.key,
    required this.mangaChapters,
    required this.mangaTitle,
    required this.mangaLang,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: mangaChapters.length,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            Get.to(
              () => MangaImages(mangaImages: mangaChapters[index]["images"]),
            );
          },
          child: Card(
            elevation: 10,
            margin: const EdgeInsets.all(10),
            color: Preferences().getThemeMode() == ThemeMode.dark
                ? Themes().darkTheme.cardColor
                : Themes().lightTheme.cardColor,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text("${"chapter".tr} ${index + 1}",
                          style: TextStyle(
                              fontSize: ScreenScaler().getTextSize(8.5))),
                    ),
                    Row(
                      children: [
                        RawMaterialButton(
                          textStyle: const TextStyle(color: Colors.blueGrey),
                          onPressed: () async {
                            await getChapters(
                              "Mangas",
                              mangaTitle,
                              mangaLang,
                              true, // isManga
                              true, // isSingle
                              chapters:
                                  mangaChapters, // Pass the whole chapters list
                              chapter: index, // Pass the chapter index
                            );
                          },
                          child: Icon(
                            Icons.file_download,
                            size: ScreenScaler().getTextSize(10),
                          ),
                        ),
                        RawMaterialButton(
                          textStyle: const TextStyle(color: Colors.blueGrey),
                          onPressed: () async {
                            sendErrorMail(
                                true,
                                "ERROR",
                                "notAvailable".trParams(
                                    {"numCap": (index + 1).toString()}));
                          },
                          child: Icon(
                            Icons.error_outline,
                            size: ScreenScaler().getTextSize(10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
