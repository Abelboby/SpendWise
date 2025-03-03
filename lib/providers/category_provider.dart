import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/firestore_service.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryProvider with ChangeNotifier {
  final List<Category> _categories = [];
  final _uuid = const Uuid();
  final _firestoreService = FirestoreService();
  final _auth = FirebaseAuth.instance;

  CategoryProvider() {
    _initializeData();
  }

  void _initializeData() {
    final user = _auth.currentUser;
    if (user != null) {
      // Listen to categories
      _firestoreService.getCategories(user.uid).listen((categories) {
        _categories.clear();
        _categories.addAll(categories);

        // Add default categories if none exist
        if (_categories.isEmpty) {
          _initializeDefaultCategories();
        }

        notifyListeners();
      });
    }
  }

  List<Category> get categories => [..._categories];

  Future<void> _initializeDefaultCategories() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await addCategory(
      name: 'Home',
      icon: Icons.home,
      isDefault: true,
    );
    await addCategory(
      name: 'Personal',
      icon: Icons.person,
      isDefault: true,
    );
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addCategory({
    required String name,
    required IconData icon,
    bool isDefault = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final category = Category(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      isDefault: isDefault,
    );

    await _firestoreService.addCategory(user.uid, category);
  }

  Future<void> addCustomCategory(String name, IconData icon) async {
    await addCategory(name: name, icon: icon);
  }

  Future<void> deleteCategory(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final category = getCategoryById(id);
    if (category != null && !category.isDefault) {
      await _firestoreService.deleteCategory(user.uid, id);
    }
  }

  Future<void> updateCategory(String id, String name, IconData icon) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final index = _categories.indexWhere((cat) => cat.id == id);
    if (index != -1 && !_categories[index].isDefault) {
      final category = Category(
        id: id,
        name: name,
        icon: icon,
        isDefault: false,
      );
      await _firestoreService.addCategory(user.uid, category);
    }
  }
}
