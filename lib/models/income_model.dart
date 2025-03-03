import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeModel {
  final String id;
  final double amount;
  final String description;
  final DateTime dateTime;
  final String? notes;
  final String? category;
  final String? spaceId;
  final String? createdBy;

  const IncomeModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.dateTime,
    this.notes,
    this.category,
    this.spaceId,
    this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'notes': notes,
      'category': category,
      'spaceId': spaceId,
      'createdBy': createdBy,
    };
  }

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      notes: map['notes'] as String?,
      category: map['category'] as String?,
      spaceId: map['spaceId'] as String?,
      createdBy: map['createdBy'] as String?,
    );
  }

  IncomeModel copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? dateTime,
    String? notes,
    String? category,
    String? spaceId,
    String? createdBy,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      spaceId: spaceId ?? this.spaceId,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
