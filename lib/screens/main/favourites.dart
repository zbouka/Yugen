import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import 'package:yugen/screens/auth/auth.dart';
import 'package:yugen/widgets/Recycled/error.dart';
import 'package:yugen/widgets/Recycled/favorite_controller.dart';
import 'package:yugen/widgets/Recycled/mycard.dart';
import '../../assets/loading.dart';
import '../../widgets/Recycled/get_color.dart';

/// Screen that shows the favorites that are stored in the favourites subcollections depending on if it is a manga or anime
class Favorites extends StatefulWidget {
  final String collectionName, collectionFavorites;

  const Favorites({
    super.key,
    required this.collectionName,
    required this.collectionFavorites,
  });

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  late CollectionReference<Map<String, dynamic>> collection;
  final FavoritesController favoritesController = Get.find();

  @override
  void initState() {
    super.initState();
    collection = FirebaseFirestore.instance
        .collection('Users')
        .doc(Auth().getUser()!.uid)
        .collection(widget.collectionFavorites);
  }

  /// Retrieves the favorite items from the Firestore collection and builds the UI
  Widget _buildFavoritesGrid(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docs.isEmpty) {
      return CustomErrorWidget(
        isError: false,
        errorMessage: "noFavorites".tr,
      );
    }

    final favoriteIds = snapshot.docs.map((doc) => doc.id).toList();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(widget.collectionName)
          .where(FieldPath.documentId, whereIn: favoriteIds)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        }

        if (snapshot.hasError) {
          return CustomErrorWidget(
            isError: true,
            errorMessage: "Error fetching data: ${snapshot.error}",
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return CustomErrorWidget(
            isError: false,
            errorMessage: "noFavorites".tr,
          );
        }

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio:
                MediaQuery.of(context).orientation == Orientation.landscape
                    ? 1.3
                    : 0.6,
            crossAxisSpacing: 5,
            mainAxisSpacing: 7,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
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
                collectionFavorites: widget.collectionFavorites,
                onDelete: () {
                  // Remove from controller
                  favoritesController.removeFavorite(doc.id);
                },
              ),
            );
          },
        );
      },
    );
  }

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
            }

            if (snapshot.hasError) {
              return CustomErrorWidget(
                isError: true,
                errorMessage: "Error fetching data: ${snapshot.error}",
              );
            }

            if (!snapshot.hasData) {
              return CustomErrorWidget(
                isError: false,
                errorMessage: "noFavorites".tr,
              );
            }

            return _buildFavoritesGrid(snapshot.data!);
          },
        ),
      ),
    );
  }
}
