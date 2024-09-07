import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:yugen/assets/loading.dart';
import 'package:yugen/widgets/Recycled/error.dart';
import 'package:yugen/widgets/Recycled/mycard.dart';
import 'package:yugen/helpers/check_device.dart';

/// Class that shows all the animes or mangas in their respective screens
class WidgetList extends StatefulWidget {
  final String collectionName;
  final String collectionFavorites;
  const WidgetList({
    super.key,
    required this.collectionName,
    required this.collectionFavorites,
  });

  @override
  State<WidgetList> createState() => _WidgetListState();
}

class _WidgetListState extends State<WidgetList> {
  late CollectionReference<Map<String, dynamic>> collection =
      FirebaseFirestore.instance.collection(widget.collectionName);

  late final ScreenScaler scaler;

  bool isInitialized = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isInitialized == false) {
      scaler = ScreenScaler()..init(context);
      isInitialized = true;
    }

    /// We split the items in different categories
    return FutureBuilder(
      future: Future.wait([
        collection
            .orderBy("year", descending: true)
            .limit(isTablet ? 10 : 5)
            .get(),
        collection
            .orderBy("averageRating", descending: true)
            .limit(isTablet ? 10 : 5)
            .get(),
        collection
            .where("genres", arrayContains: "Action")
            .limit(isTablet ? 10 : 5)
            .get(),
        collection
            .orderBy("numberChapters", descending: true)
            .where("genres", arrayContains: "Drama")
            .limit(isTablet ? 10 : 5)
            .get(),
        collection
            .where("genres", arrayContains: "Mystery")
            .orderBy("year", descending: true)
            .limit(isTablet ? 10 : 5)
            .get(),
      ]),
      builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Loading());
        } else if (!snapshot.hasData || snapshot.data!.first.docs.isEmpty) {
          return Center(
              child: CustomErrorWidget(errorMessage: "noElements".tr));
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  "latestReleased".tr,
                  style: TextStyle(
                    fontSize: scaler.getTextSize(15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: SizedBox(
                  height: 225,
                  width: Get.size.width,
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: snapshot.data![0].docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data![0].docs[index];
                      return Container(
                        padding: const EdgeInsets.only(left: 12),
                        child: MyCard(
                          title: doc['title'],
                          img: doc["cover"],
                          lang: doc["language"],
                          desc: doc["description"],
                          genres: doc["genres"],
                          chapters: doc["chapters"],
                          status: doc["status"],
                          year: doc["year"],
                          numberChapters: doc["numberChapters"],
                          collectionFavorites: widget.collectionFavorites,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  "recommended".tr,
                  style: TextStyle(
                    fontSize: scaler.getTextSize(15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: snapshot.data![1].docs.isNotEmpty
                    ? SizedBox(
                        height: 225,
                        width: Get.size.width,
                        child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: snapshot.data![1].docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc =
                                snapshot.data![1].docs[index];

                            return Container(
                              padding: const EdgeInsets.only(left: 12),
                              child: MyCard(
                                title: doc['title'],
                                img: doc["cover"],
                                lang: doc["language"],
                                desc: doc["description"],
                                genres: doc["genres"],
                                chapters: doc["chapters"],
                                status: doc["status"],
                                year: doc["year"],
                                numberChapters: doc["numberChapters"],
                                collectionFavorites: widget.collectionFavorites,
                              ),
                            );
                          },
                        ),
                      )
                    : SizedBox(
                        height: 225,
                        width: Get.size.width,
                        child: CustomErrorWidget(
                            errorMessage: "noRecommended".tr)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  "action".tr,
                  style: TextStyle(
                    fontSize: scaler.getTextSize(15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: SizedBox(
                  height: 225,
                  width: Get.size.width,
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: snapshot.data![2].docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data![2].docs[index];
                      return Container(
                        padding: const EdgeInsets.only(left: 12),
                        child: MyCard(
                          title: doc['title'],
                          img: doc["cover"],
                          lang: doc["language"],
                          desc: doc["description"],
                          genres: doc["genres"],
                          chapters: doc["chapters"],
                          status: doc["status"],
                          year: doc["year"],
                          numberChapters: doc["numberChapters"],
                          collectionFavorites: widget.collectionFavorites,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  "Drama".tr,
                  style: TextStyle(
                    fontSize: scaler.getTextSize(15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: SizedBox(
                  height: 225,
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: snapshot.data![3].docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data![3].docs[index];
                      return Container(
                        padding: const EdgeInsets.only(left: 12),
                        child: MyCard(
                          title: doc['title'],
                          img: doc["cover"],
                          lang: doc["language"],
                          desc: doc["description"],
                          genres: doc["genres"],
                          chapters: doc["chapters"],
                          status: doc["status"],
                          year: doc["year"],
                          numberChapters: doc["numberChapters"],
                          collectionFavorites: widget.collectionFavorites,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  "mystery".tr,
                  style: TextStyle(
                    fontSize: scaler.getTextSize(15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: SizedBox(
                  height: 225,
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: snapshot.data![4].docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data![4].docs[index];
                      return Container(
                        padding: const EdgeInsets.only(left: 12),
                        child: MyCard(
                          title: doc['title'],
                          img: doc["cover"],
                          lang: doc["language"],
                          desc: doc["description"],
                          genres: doc["genres"],
                          chapters: doc["chapters"],
                          status: doc["status"],
                          year: doc["year"],
                          numberChapters: doc["numberChapters"],
                          collectionFavorites: widget.collectionFavorites,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
