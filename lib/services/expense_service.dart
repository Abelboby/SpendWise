import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Get expenses collection reference for a user
  CollectionReference _getExpensesCollection(String userId) {
    return _firestore.collection('tracker').doc(userId).collection('expenses');
  }

  // Add new expense
  Future<String> addExpense(String userId, ExpenseModel expense) async {
    try {
      final String expenseId = _uuid.v4();
      final expenseWithId = expense.copyWith(id: expenseId);

      await _getExpensesCollection(userId).doc(expenseId).set(expenseWithId.toMap());

      return expenseId;
    } catch (e) {
      print('Error adding expense: $e');
      rethrow;
    }
  }

  // Update expense
  Future<void> updateExpense(String userId, ExpenseModel expense) async {
    try {
      await _getExpensesCollection(userId).doc(expense.id).update(expense.toMap());
    } catch (e) {
      print('Error updating expense: $e');
      rethrow;
    }
  }

  // Delete expense
  Future<void> deleteExpense(String userId, String expenseId) async {
    try {
      await _getExpensesCollection(userId).doc(expenseId).delete();
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }

  // Get all expenses for a user
  Stream<List<ExpenseModel>> getExpenses(String userId) {
    return _getExpensesCollection(userId).orderBy('date', descending: true).snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Get expenses for a specific date range
  Stream<List<ExpenseModel>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _getExpensesCollection(userId)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate), isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Get total expenses for a specific month
  Future<double> getMonthlyTotal(String userId, DateTime month) async {
    try {
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final querySnapshot = await _getExpensesCollection(userId)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate), isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      double total = 0.0;
      for (var doc in querySnapshot.docs) {
        total += (doc.data() as Map<String, dynamic>)['amount'] as double;
      }
      return total;
    } catch (e) {
      print('Error getting monthly total: $e');
      rethrow;
    }
  }
}
