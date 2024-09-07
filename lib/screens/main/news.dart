import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:yugen/apis/api_news.dart';
import 'package:yugen/widgets/News/customtile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yugen/widgets/Recycled/error.dart';

import '../../assets/loading.dart';
import '../../models/article.dart';

/// Screen for showing the news using the news API, here is where all the data collected takes form and shows it to the final user
class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> with AutomaticKeepAliveClientMixin {
  ApiServiceNews client = ApiServiceNews();
  bool error = false;

  @override
  void dispose() {
    // Release resources if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "YugenNews",
          style: TextStyle(
            fontSize: 30,
            fontFamily: GoogleFonts.playball().fontFamily,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Article>>(
          future: client.getNews(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Loading());
            } else if (snapshot.hasError) {
              error = true;
              return CustomErrorWidget(errorMessage: "noNews".tr);
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<Article> articles = snapshot.data!;
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  return customListTile(articles[index]);
                },
              );
            } else {
              error = true;
              return CustomErrorWidget(errorMessage: "noNews".tr);
            }
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive =>
      true; // This keeps the state alive when switching tabs or pages
}
