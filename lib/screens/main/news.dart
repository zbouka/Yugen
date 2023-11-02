import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:yugen/apis/api_news.dart';
import 'package:yugen/widgets/News/customtile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yugen/widgets/Recycled/error.dart';
import 'package:yugen/widgets/Recycled/externalProviders.dart';
import '../../assets/loading.dart';
import '../../models/article.dart';

/// Screen for showing the news using the news API, here is where all the data collected takes form and shows it to the final user
class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  ApiServiceNews client = ApiServiceNews();
  bool error = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("YugenNews",
            style: TextStyle(
                fontSize: 30, fontFamily: GoogleFonts.playball().fontFamily)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: client.getNews(),
            builder: (context, AsyncSnapshot<List<Article>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Loading());
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                List<Article> articles = snapshot.data!;
                return SingleChildScrollView(
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: Column(
                      children: [
                        madeBy("animelist".tr,
                            "https://image.myanimelist.net/ui/OK6W_koKDTOqqqLDbIoPAiC8a86sHufn_jOI-JGtoCQ"),
                        ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: articles.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) =>
                              customListTile(articles[index]),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                error = true;

                return CustomErrorWidget(errorMessage: "noNews".tr);
              }
            }),
      ),
    );
  }
}
