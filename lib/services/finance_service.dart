import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/income_model.dart';
import '../models/expense_model.dart';
import '../models/space_model.dart';
import 'package:flutter/foundation.dart';

class FinanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';
  final String _incomesCollection = 'incomes';
  final String _expensesCollection = 'expenses';
  final String _spacesCollection = 'spaces';

  // Get incomes stream
  Stream<List<IncomeModel>> getIncomes(String userId, {String? spaceId}) {
    final incomesRef = spaceId != null
        ? _firestore
            .collection(_spacesCollection)
            .doc(spaceId)
            .collection(_incomesCollection)
        : _firestore
            .collection(_usersCollection)
            .doc(userId)
            .collection(_incomesCollection)
            .where('spaceId', isNull: true); // Only get personal incomes

    return incomesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => IncomeModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Get expenses stream for a specific income
  Stream<List<ExpenseModel>> getExpensesForIncome(
    String userId,
    String incomeId, {
    String? spaceId,
  }) {
    final expensesRef = spaceId != null
        ? _firestore
            .collection(_spacesCollection)
            .doc(spaceId)
            .collection(_incomesCollection)
            .doc(incomeId)
            .collection(_expensesCollection)
        : _firestore
            .collection(_usersCollection)
            .doc(userId)
            .collection(_incomesCollection)
            .doc(incomeId)
            .collection(_expensesCollection);

    return expensesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Add a new income
  Future<void> addIncome({
    required double amount,
    required String description,
    required DateTime dateTime,
    required String userId,
    String? notes,
    String? category,
    String? spaceId,
    String? createdBy,
  }) async {
    final income = IncomeModel(
      id: const Uuid().v4(),
      amount: amount,
      description: description,
      dateTime: dateTime,
      notes: notes,
      category: category,
      spaceId: spaceId,
      createdBy: createdBy,
    );

    final incomeRef = spaceId != null
        ? _firestore
            .collection(_spacesCollection)
            .doc(spaceId)
            .collection(_incomesCollection)
            .doc(income.id)
        : _firestore
            .collection(_usersCollection)
            .doc(userId)
            .collection(_incomesCollection)
            .doc(income.id);

    await incomeRef.set(income.toMap());
  }

  // Add a new expense
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final expenseRef = expense.spaceId != null
          ? _firestore
              .collection(_spacesCollection)
              .doc(expense.spaceId)
              .collection(_incomesCollection)
              .doc(expense.incomeId)
              .collection(_expensesCollection)
              .doc(expense.id)
          : _firestore
              .collection(_usersCollection)
              .doc(expense.createdBy)
              .collection(_incomesCollection)
              .doc(expense.incomeId)
              .collection(_expensesCollection)
              .doc(expense.id);

      await expenseRef.set(expense.toMap());
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }

  // Delete an income
  Future<void> deleteIncome(String userId, String incomeId,
      {String? spaceId}) async {
    final incomeRef = spaceId != null
        ? _firestore
            .collection(_spacesCollection)
            .doc(spaceId)
            .collection(_incomesCollection)
            .doc(incomeId)
        : _firestore
            .collection(_usersCollection)
            .doc(userId)
            .collection(_incomesCollection)
            .doc(incomeId);

    // Delete all expenses for this income first
    final expensesSnapshot =
        await incomeRef.collection(_expensesCollection).get();

    final batch = _firestore.batch();
    for (var doc in expensesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(incomeRef);
    await batch.commit();
  }

  // Delete an expense
  Future<void> deleteExpense(String userId, String expenseId,
      {String? spaceId}) async {
    final expenseRef = spaceId != null
        ? _firestore
            .collection(_spacesCollection)
            .doc(spaceId)
            .collection(_expensesCollection)
            .doc(expenseId)
        : _firestore
            .collection(_usersCollection)
            .doc(userId)
            .collection(_expensesCollection)
            .doc(expenseId);

    await expenseRef.delete();
  }
}
