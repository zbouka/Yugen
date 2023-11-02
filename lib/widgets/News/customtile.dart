import 'package:fl_mlkit_translate_text/fl_mlkit_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yugen/apis/email.dart';
import '../../config/preferences.dart';
import '../../models/article.dart';

FlMlKitTranslateText translate = FlMlKitTranslateText();
late Future<List<String>> translations;

Future<String> _getTranslations(String text) async {
  Preferences().getLocale() == "en"
      ? await translate.switchLanguage(
          TranslateLanguage.spanish, TranslateLanguage.english)
      : await translate.switchLanguage(
          TranslateLanguage.english, TranslateLanguage.spanish);
  String? resultado =
      await translate.translate(text, downloadModelIfNeeded: true);
  return resultado!;
}

List<Widget> _buildRowList(String element) {
  List<Widget> linesWidgets = [];
  List<String> lines = element.split(",");
  for (var line in lines) {
    List<Widget> placesForLine = []; // this will hold the places for each line

    placesForLine.add(
      Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Text(
          line,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );

    linesWidgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: placesForLine));
  }

  return linesWidgets;
}

/// Widget that shows the anime/manga news
Widget customListTile(Article article) {
  return InkWell(
    onTap: () {
      try {
        launchUrl(Uri.parse(article.url), mode: LaunchMode.externalApplication);
      } catch (e) {
        sendErrorMail(true, "ERROR", e.toString());
      }
    },
    child: Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0), boxShadow: const []),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          article.url != ""
              ? Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image.network(
                          article.image,
                        ).image),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                )
              : Container(
                  height: 200.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                          "https://img.icons8.com/fluency/344/image.png"),
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Text(
                  article.date,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _buildRowList(article.type)),
            ],
          ),
          const SizedBox(height: 8.0),
          FutureBuilder<String>(
              future: _getTranslations(article.title),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: LoadingAnimationWidget.beat(
                    color: Colors.deepPurple,
                    size: 20,
                  ));
                }
                if (!snapshot.hasData) {
                  return const Text("Error");
                } else {
                  return ReadMoreText(
                    snapshot.data!.toString(),
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'showMore'.tr,
                    trimExpandedText: 'showLess'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  );
                }
              }),
          const SizedBox(
            height: 20,
          ),
          FutureBuilder<String>(
              future: _getTranslations(article.description),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: LoadingAnimationWidget.beat(
                    color: Colors.deepPurple,
                    size: 20,
                  ));
                } else {
                  return ReadMoreText(
                    snapshot.data!.toString(),
                    trimLines: 4,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'showMore'.tr,
                    trimExpandedText: 'showLess'.tr,
                    style: const TextStyle(
                      fontSize: 12.0,
                    ),
                  );
                }
              }),
        ],
      ),
    ),
  );
}
