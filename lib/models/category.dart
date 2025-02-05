import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'isDefault': isDefault,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: IconData(
        json['iconCodePoint'],
        fontFamily: json['iconFontFamily'],
        fontPackage: json['iconFontPackage'],
      ),
      isDefault: json['isDefault'] ?? false,
    );
  }
}
