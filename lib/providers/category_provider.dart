import 'package:flutter/material.dart';
import '../models/category.dart';
import 'package:uuid/uuid.dart';

class CategoryProvider with ChangeNotifier {
  final List<Category> _categories = [];
  final _uuid = const Uuid();

  CategoryProvider() {
    _initializeDefaultCategories();
  }

  List<Category> get categories => [..._categories];

  void _initializeDefaultCategories() {
    // Add default categories if they don't exist
    if (_categories.isEmpty) {
      addCategory(
        name: 'Home',
        icon: Icons.home,
        isDefault: true,
      );
      addCategory(
        name: 'Personal',
        icon: Icons.person,
        isDefault: true,
      );
    }
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  void addCategory({
    required String name,
    required IconData icon,
    bool isDefault = false,
  }) {
    final category = Category(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      isDefault: isDefault,
    );
    _categories.add(category);
    notifyListeners();
  }

  void addCustomCategory(String name, IconData icon) {
    addCategory(name: name, icon: icon);
  }

  void deleteCategory(String id) {
    final category = getCategoryById(id);
    if (category != null && !category.isDefault) {
      _categories.removeWhere((cat) => cat.id == id);
      notifyListeners();
    }
  }

  void updateCategory(String id, String name, IconData icon) {
    final index = _categories.indexWhere((cat) => cat.id == id);
    if (index != -1 && !_categories[index].isDefault) {
      final category = Category(
        id: id,
        name: name,
        icon: icon,
        isDefault: false,
      );
      _categories[index] = category;
      notifyListeners();
    }
  }
}
