import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:yugen/assets/loading.dart';
import 'package:yugen/widgets/Recycled/error.dart';

import '../../widgets/Recycled/mycard.dart';

/// Search bar for search options in the correspondant collections
class MySearchBar extends StatefulWidget {
  final String collection;
  final String collectionFavorites;
  const MySearchBar(
      {super.key, required this.collection, required this.collectionFavorites});

  @override
  _MySearchBarState createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          await showSearch(
              context: context,
              useRootNavigator: true,
              delegate: MySearchDelegate(
                  widget.collection, widget.collectionFavorites));
        },
        icon: Icon(
          Ionicons.search,
          size: MediaQuery.of(context).orientation == Orientation.landscape
              ? ScreenScaler().getTextSize(11)
              : null,
        ));
  }
}

class MySearchDelegate extends SearchDelegate {
  late String collection;
  late String collectionFavorites;
  MySearchDelegate(this.collection, this.collectionFavorites) {
    collection = collection;
    collectionFavorites = collectionFavorites;
  }

  /// As it seems, Firebase does not have a search text option so i had to improvise in order to get that search to "work"
  /// Which makes the query matches all values that start with query using the unicode character uf8ff
  Widget getItems() {
    return StreamBuilder(
        stream: (query != "")
            ? FirebaseFirestore.instance
                .collection(collection)
                .where("title", isNotEqualTo: query.capitalizeFirst!)
                .orderBy("title")
                .startAt([
                query.capitalizeFirst!,
              ]).endAt([
                '${query.capitalizeFirst!}\uf8ff',
              ]).snapshots()
            : FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.hasData != true) {
            return const Center(
              child: Loading(),
            );
          } else if (snapshot.hasData == false ||
              snapshot.data == null ||
              snapshot.data!.docs.isEmpty) {
            return const CustomErrorWidget(
                isError: false,
                errorMessage: "No hay ningun resultado para la busqueda");
          } else {
            return Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
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
                          collectionFavorites: collectionFavorites,
                        ),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? 1.3
                          : 0.6,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 7,
                    ),
                  ),
                ),
              ],
            );
          }
        });
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Ionicons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return getItems();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return getItems();
  }
}
