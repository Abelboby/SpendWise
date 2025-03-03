import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String description;
  final double amount;
  final DateTime dateTime;
  final String? notes;
  final String incomeId;
  final String? spaceId;
  final String? createdBy;

  const ExpenseModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.dateTime,
    required this.incomeId,
    this.notes,
    this.spaceId,
    this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'dateTime': Timestamp.fromDate(dateTime),
      'notes': notes,
      'incomeId': incomeId,
      'spaceId': spaceId,
      'createdBy': createdBy,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      notes: map['notes'] as String?,
      incomeId: map['incomeId'] as String,
      spaceId: map['spaceId'] as String?,
      createdBy: map['createdBy'] as String?,
    );
  }

  ExpenseModel copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? dateTime,
    String? notes,
    String? incomeId,
    String? spaceId,
    String? createdBy,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      incomeId: incomeId ?? this.incomeId,
      spaceId: spaceId ?? this.spaceId,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
