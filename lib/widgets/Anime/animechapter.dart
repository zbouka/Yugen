import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';

import 'package:get/get.dart';
import 'package:yugen/apis/email.dart';

import 'package:yugen/widgets/Anime/animevideo.dart';

import '../Recycled/permissions.dart';

/// Shows the anime chapters list
class AnimeChapters extends StatelessWidget {
  final List<dynamic> animeChapters;
  final String animeTitle, animeLang;

  const AnimeChapters(
      {super.key,
      required this.animeChapters,
      required this.animeTitle,
      required this.animeLang});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: animeChapters.length,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Get.to(() => AnimeVideo(
                animeVideo: animeChapters[index],
              )),
          child: Card(
            elevation: 10,
            margin: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "${"chapter".tr} ${index + 1}",
                        style: TextStyle(
                          fontSize: ScreenScaler().getTextSize(8.5),
                        ),
                      ),
                    ),
                    Row(children: <Widget>[
                      RawMaterialButton(
                        textStyle: const TextStyle(color: Colors.blueGrey),
                        onPressed: () async {
                          try {
                            await getChapters(
                                "Animes", animeTitle, animeLang, false, true,
                                chapter: index, chapters: animeChapters);
                          } catch (error) {
                            sendErrorMail(true, "ERROR", error);
                          }
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
                      )
                    ])
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
