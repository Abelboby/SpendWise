import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String incomeId; // Reference to the parent income
  final double amount;
  final String description;
  final DateTime dateTime;
  final String userId;
  final String? notes;
  final String? category;
  final String? paymentMethod;

  ExpenseModel({
    required this.id,
    required this.incomeId,
    required this.amount,
    required this.description,
    required this.dateTime,
    required this.userId,
    this.notes,
    this.category,
    this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'incomeId': incomeId,
      'amount': amount,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'userId': userId,
      'notes': notes,
      'category': category,
      'paymentMethod': paymentMethod,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      incomeId: map['incomeId'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      userId: map['userId'] as String,
      notes: map['notes'] as String?,
      category: map['category'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
    );
  }

  ExpenseModel copyWith({
    String? id,
    String? incomeId,
    double? amount,
    String? description,
    DateTime? dateTime,
    String? userId,
    String? notes,
    String? category,
    String? paymentMethod,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      incomeId: incomeId ?? this.incomeId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
