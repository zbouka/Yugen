import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yugen/screens/auth/auth.dart';

class FavoritesController extends GetxController {
  // Observable list to hold favorite IDs
  var favoriteIds = <String>[].obs;

  // Firestore instance
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  // Load the user's favorite items from Firestore
  Future<void> _loadFavorites() async {
    final user = Auth().getUser();
    if (user == null) return;

    final snapshot = await _database
        .collection("Users")
        .doc(user.uid)
        .collection('Favorites') // Adjust this to the correct collection name
        .get();

    favoriteIds.value = snapshot.docs.map((doc) => doc.id).toList();
  }

  // Add a favorite item
  Future<void> addFavorite(String favoriteId) async {
    final user = Auth().getUser();
    if (user == null) return;

    final docRef = _database
        .collection("Users")
        .doc(user.uid)
        .collection('Favorites') // Adjust this to the correct collection name
        .doc(favoriteId);

    await docRef.set({"title": favoriteId}, SetOptions(merge: true));

    // Update the observable list
    if (!favoriteIds.contains(favoriteId)) {
      favoriteIds.add(favoriteId);
    }
  }

  // Remove a favorite item
  Future<void> removeFavorite(String favoriteId) async {
    final user = Auth().getUser();
    if (user == null) return;

    final docRef = _database
        .collection("Users")
        .doc(user.uid)
        .collection('Favorites') // Adjust this to the correct collection name
        .doc(favoriteId);

    await docRef.delete();

    // Update the observable list
    favoriteIds.remove(favoriteId);
  }

  // Check if an item is a favorite
  bool isFavorite(String favoriteId) {
    return favoriteIds.contains(favoriteId);
  }
}
