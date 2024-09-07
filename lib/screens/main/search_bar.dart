import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:yugen/assets/loading.dart';
import 'package:yugen/widgets/Recycled/error.dart';
import '../../widgets/Recycled/mycard.dart';

/// Search bar for search options in the corresponding collections
class MySearchBar extends StatelessWidget {
  final String collection;
  final String collectionFavorites;

  const MySearchBar({
    super.key,
    required this.collection,
    required this.collectionFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await showSearch(
          context: context,
          useRootNavigator: true,
          delegate: MySearchDelegate(
            collection: collection,
            collectionFavorites: collectionFavorites,
          ),
        );
      },
      icon: Icon(
        Ionicons.search,
        size: MediaQuery.of(context).orientation == Orientation.landscape
            ? ScreenScaler().getTextSize(11)
            : null,
      ),
    );
  }
}

class MySearchDelegate extends SearchDelegate {
  final String collection;
  final String collectionFavorites;

  MySearchDelegate({
    required this.collection,
    required this.collectionFavorites,
  });

  Stream<QuerySnapshot> _getQueryStream() {
    return (query.isNotEmpty)
        ? FirebaseFirestore.instance
            .collection(collection)
            .where(
              'title',
              isGreaterThanOrEqualTo: query,
              isLessThan: '$query\uf8ff',
            )
            .snapshots()
        : FirebaseFirestore.instance
            .collection(collection)
            .limit(20)
            .snapshots();
  }

  Widget _buildGridView(QuerySnapshot snapshot, BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(10),
      itemCount: snapshot.docs.length,
      itemBuilder: (context, index) {
        final doc = snapshot.docs[index];
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
        childAspectRatio:
            MediaQuery.of(context).orientation == Orientation.landscape
                ? 1.3
                : 0.6,
        crossAxisSpacing: 5,
        mainAxisSpacing: 7,
      ),
    );
  }

  Widget _buildStreamBuilder(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getQueryStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Loading());
        }

        if (snapshot.hasError) {
          print("Error fetching data: ${snapshot.error}");
          return const Center(
              child: CustomErrorWidget(errorMessage: "An error occurred."));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: CustomErrorWidget(errorMessage: "No elements found"));
        }

        return Column(
          children: [
            const SizedBox(height: 20),
            Expanded(child: _buildGridView(snapshot.data!, context)),
          ],
        );
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Ionicons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildStreamBuilder(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildStreamBuilder(context);
  }
}
