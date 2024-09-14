import 'package:translator/translator.dart'; // Import the Google Translator package
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yugen/apis/email.dart';
import '../../config/preferences.dart';
import '../../models/article.dart';

final translator = GoogleTranslator(); // Google Translator instance

Future<String> _getTranslation(String text) async {
  try {
    final locale = Preferences().getLocale();
    final targetLanguage =
        locale == "es" ? 'es' : 'en'; // Spanish to English or vice versa

    // Perform the translation
    final translation = await translator.translate(text, to: targetLanguage);
    return translation.text ?? ''; // Return the translated text
  } catch (e) {
    debugPrint('Error translating text: $e');
    return ''; // Return an empty string in case of an error
  }
}

List<Widget> _buildRowList(String element) {
  return element.split(",").map((line) {
    return Container(
      padding: const EdgeInsets.all(6.0), // Reduced padding for better spacing
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10.0, vertical: 4.0), // Reduced padding for label
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Text(
              line,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 6.0), // Reduced spacing between genre widgets
        ],
      ),
    );
  }).toList();
}

/// Widget that shows the anime/manga news
Widget customListTile(Article article) {
  return InkWell(
    onTap: () async {
      try {
        await launchUrl(Uri.parse(article.url),
            mode: LaunchMode.externalApplication);
      } catch (e) {
        sendErrorMail(true, "ERROR", e.toString());
      }
    },
    child: Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        // Removed shadow for a cleaner look
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          article.url.isNotEmpty
              ? Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(article.image),
                    ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Text(
                  article.date,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Row(children: _buildRowList(article.type)),
            ],
          ),
          const SizedBox(height: 8.0),
          FutureBuilder<String>(
            future: _getTranslation(article.title),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.beat(
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Text("Error");
              } else {
                return ReadMoreText(
                  snapshot.data!,
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
            },
          ),
          const SizedBox(height: 20),
          FutureBuilder<String>(
            future: _getTranslation(article.description),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.beat(
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                );
              } else {
                return ReadMoreText(
                  snapshot.data!,
                  trimLines: 4,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'showMore'.tr,
                  trimExpandedText: 'showLess'.tr,
                  style: const TextStyle(fontSize: 12.0),
                );
              }
            },
          ),
        ],
      ),
    ),
  );
}
