import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:yugen/widgets/Anime/animechapter.dart';
import 'package:yugen/widgets/Manga/mangachapter.dart';
import 'package:yugen/widgets/Recycled/comment_tab.dart';

import 'description.dart';
import 'get_color.dart';

/// Shows the description, chapters and comment sections
class ItemInfo extends StatefulWidget {
  final String img, status, title, year, description, lang, collectionName;
  final List<dynamic> chapters;

  const ItemInfo(
      {super.key,
      required this.img,
      required this.status,
      required this.title,
      required this.year,
      required this.description,
      required this.chapters,
      required this.collectionName,
      required this.lang});
  @override
  _ItemInfoState createState() => _ItemInfoState();
}

class _ItemInfoState extends State<ItemInfo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: getCurrentColor(false),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
      ),
      child: Column(
        children: [
          TabBar(
            // indicatorPadding: EdgeInsets.all(30),
            controller: _tabController,

            automaticIndicatorColorAdjustment: true,
            indicatorColor: Colors.white,
            padding: const EdgeInsets.all(10),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(
                25.0,
              ),
              color: Colors.purple,
            ),
            labelColor: getCurrentColor(false),
            unselectedLabelColor: getCurrentColor(true),

            tabs: [
              Tab(
                  child: Text(
                "Description".tr,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? ScreenScaler().getTextSize(8)
                        : 14),
              )),
              Tab(
                child: Text(
                  "Chapters".tr,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? ScreenScaler().getTextSize(8)
                          : 14),
                ),
              ),
              Tab(
                child: Text(
                  "Comments".tr,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? ScreenScaler().getTextSize(8)
                          : 14),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(controller: _tabController, children: [
              Container(
                child: Desc(
                    img: widget.img,
                    status: widget.status,
                    title: widget.title,
                    year: widget.year,
                    description: widget.description),
              ),
              // // chapters - chapters
              widget.collectionName == "Mangas"
                  ? Container(
                      child: MangaChapters(
                        mangaChapters: widget.chapters,
                        mangaTitle: widget.title,
                        mangaLang: widget.lang,
                      ),
                    )
                  : Container(
                      child: AnimeChapters(
                        animeChapters: widget.chapters,
                        animeTitle: widget.title,
                        animeLang: widget.lang,
                      ),
                    ),
              Container(
                child: CommentsTab(
                  title: widget.title,
                  lang: widget.lang,
                  collectionName: widget.collectionName,
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }
}
