import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get/route_manager.dart';
import 'package:ionicons/ionicons.dart';

import 'package:yugen/screens/auth/auth.dart';
import 'package:yugen/widgets/Recycled/error.dart';
import 'package:yugen/widgets/Recycled/mycard.dart';

import '../../assets/loading.dart';
import '../../widgets/Recycled/get_color.dart';

/// Screen that shows the favorites that are stored in the favourites subcollections depending on if it is a manga or anime
class Favorites extends StatefulWidget {
  final String collectionName, collectionFavorites;
  const Favorites(
      {super.key,
      required this.collectionName,
      required this.collectionFavorites});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  bool loading = false;

  late CollectionReference<Map<String, dynamic>> collection;

  /// Collects all favourites of the user depending of the collection passed
  @override
  void initState() {
    super.initState();

    collection = FirebaseFirestore.instance
        .collection('Users')
        .doc(Auth().getUser()!.uid)
        .collection(widget.collectionFavorites);
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Returns a widget depending on the current state
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          "favorites".tr,
          style: TextStyle(color: getCurrentColor(true)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.deepPurple),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: collection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loading();
              } else if (snapshot.data!.docs.isNotEmpty) {
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.all(10),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loading();
                    } else if (snapshot.data == null) {
                      return Container();
                    } else {
                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection(widget.collectionName)
                              .where(FieldPath.documentId,
                                  whereIn: snapshot.data!.docs[index]
                                      .data()
                                      .values
                                      .toList())
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Loading();
                            } else {
                              DocumentSnapshot doc = snapshot.data!.docs[0];
                              return Container(
                                padding: const EdgeInsets.only(left: 12),
                                child: MyCard(
                                  img: doc["cover"],
                                  title: doc["title"],
                                  desc: doc["description"],
                                  genres: doc["genres"],
                                  lang: doc["language"],
                                  status: doc["status"],
                                  chapters: doc["chapters"],
                                  year: doc["year"],
                                  numberChapters: doc["numberChapters"],
                                  collectionFavorites:
                                      widget.collectionFavorites,
                                ),
                              );
                            }
                          });
                    }
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
                );
              } else {
                return const CustomErrorWidget(
                    isError: false,
                    errorMessage: "No hay ningun elemento en favoritos");
              }
            }),
      ),
    );
  }
}
