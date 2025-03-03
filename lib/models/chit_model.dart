import 'package:cloud_firestore/cloud_firestore.dart';

class ChitModel {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final DateTime date;
  final String status;
  final DateTime? dueDate;

  ChitModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.date,
    required this.status,
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'status': status,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
    };
  }

  factory ChitModel.fromMap(Map<String, dynamic> map) {
    return ChitModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      dueDate: map['dueDate'] != null ? (map['dueDate'] as Timestamp).toDate() : null,
    );
  }

  ChitModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? description,
    DateTime? date,
    String? status,
    DateTime? dueDate,
  }) {
    return ChitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
