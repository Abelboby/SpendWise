import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';
  final String _categoriesCollection = 'categories';
  List<CategoryModel> _categories = [];
  bool _isEnabled = false;
  String? _userId;

  List<CategoryModel> get categories => _categories;
  bool get isEnabled => _isEnabled;

  void initialize(String userId) {
    _userId = userId;
    _loadSettings();
    _listenToCategories();
  }

  Future<void> _loadSettings() async {
    if (_userId == null) return;

    try {
      final userDoc =
          await _firestore.collection(_usersCollection).doc(_userId).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        _isEnabled = data?['categoriesEnabled'] ?? false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading category settings: $e');
    }
  }

  Future<void> toggleCategoryFeature(bool enabled) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection(_usersCollection)
          .doc(_userId)
          .set({'categoriesEnabled': enabled}, SetOptions(merge: true));

      _isEnabled = enabled;
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling category feature: $e');
      rethrow;
    }
  }

  void _listenToCategories() {
    if (_userId == null) return;

    _firestore
        .collection(_usersCollection)
        .doc(_userId)
        .collection(_categoriesCollection)
        .snapshots()
        .listen((snapshot) {
      _categories = snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data()))
          .toList();
      notifyListeners();
    });
  }

  Future<void> addDefaultCategories() async {
    if (_userId == null) return;

    final batch = _firestore.batch();
    final defaultCategories = [
      CategoryModel(
        id: const Uuid().v4(),
        name: 'Personal',
        description: 'Personal expenses and incomes',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: const Uuid().v4(),
        name: 'Business',
        description: 'Business related transactions',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
    ];

    for (var category in defaultCategories) {
      final docRef = _firestore
          .collection(_usersCollection)
          .doc(_userId)
          .collection(_categoriesCollection)
          .doc(category.id);
      batch.set(docRef, category.toMap());
    }

    await batch.commit();
  }

  Future<void> addCategory({
    required String name,
    String? description,
    IconData? icon,
  }) async {
    if (_userId == null) return;

    final category = CategoryModel(
      id: const Uuid().v4(),
      name: name,
      description: description,
      isDefault: false,
      createdBy: _userId,
      createdAt: DateTime.now(),
      iconCodePoint: icon?.codePoint,
      iconFontFamily: icon?.fontFamily,
    );

    await _firestore
        .collection(_usersCollection)
        .doc(_userId)
        .collection(_categoriesCollection)
        .doc(category.id)
        .set(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    if (_userId == null) return;

    final category = _categories.firstWhere((c) => c.id == categoryId);
    if (category.isDefault) {
      throw Exception('Cannot delete default categories');
    }

    await _firestore
        .collection(_usersCollection)
        .doc(_userId)
        .collection(_categoriesCollection)
        .doc(categoryId)
        .delete();
  }
}
