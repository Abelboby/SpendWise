import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final bool isDefault;

  const Category({
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
      icon:
          _getIconData(json['iconCodePoint'], fontFamily: json['iconFontFamily'], fontPackage: json['iconFontPackage']),
      isDefault: json['isDefault'] ?? false,
    );
  }

  // Helper method to get constant IconData
  static IconData _getIconData(int codePoint, {String? fontFamily, String? fontPackage}) {
    // Create a const IconData
    return IconData(codePoint, fontFamily: fontFamily, fontPackage: fontPackage, matchTextDirection: false);
  }
}
