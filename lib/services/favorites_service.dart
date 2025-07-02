import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's UID
  String? get userId => _auth.currentUser?.uid;

  Future<void> saveFavorite(Map<String, dynamic> meal) async {
    if (userId == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(meal['idMeal']);

    await docRef.set(meal);
  }

  Future<void> removeFavorite(String idMeal) async {
    if (userId == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(idMeal);

    await docRef.delete();
  }

  Future<bool> isFavorite(String idMeal) async {
    if (userId == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(idMeal)
        .get();

    return doc.exists;
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
