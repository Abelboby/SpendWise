import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeModel {
  final String id;
  final double amount;
  final String description;
  final DateTime dateTime;
  final String userId;
  final String? notes;
  final String? category;

  IncomeModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.dateTime,
    required this.userId,
    this.notes,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'userId': userId,
      'notes': notes,
      'category': category,
    };
  }

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      userId: map['userId'] as String,
      notes: map['notes'] as String?,
      category: map['category'] as String?,
    );
  }
}
