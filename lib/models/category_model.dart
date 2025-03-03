import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final bool isDefault;
  final String? createdBy;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.isDefault,
    this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isDefault': isDefault,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      isDefault: map['isDefault'] as bool,
      createdBy: map['createdBy'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isDefault,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
