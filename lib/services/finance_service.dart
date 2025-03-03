import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/income_model.dart';
import '../models/expense_model.dart';

class FinanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';
  final String _incomesCollection = 'incomes';
  final String _expensesCollection = 'expenses';

  // Add a new income
  Future<IncomeModel> addIncome({
    required double amount,
    required String description,
    required String userId,
    required DateTime dateTime,
    String? notes,
    String? category,
  }) async {
    final String id = const Uuid().v4();
    final income = IncomeModel(
      id: id,
      amount: amount,
      description: description,
      dateTime: dateTime,
      userId: userId,
      notes: notes,
      category: category,
    );

    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_incomesCollection)
        .doc(id)
        .set(income.toMap());

    return income;
  }

  // Add a new expense
  Future<ExpenseModel> addExpense({
    required String incomeId,
    required double amount,
    required String description,
    required String userId,
    required DateTime dateTime,
    String? notes,
    String? category,
    String? paymentMethod,
  }) async {
    final String id = const Uuid().v4();
    final expense = ExpenseModel(
      id: id,
      incomeId: incomeId,
      amount: amount,
      description: description,
      dateTime: dateTime,
      userId: userId,
      notes: notes,
      category: category,
      paymentMethod: paymentMethod,
    );

    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_expensesCollection)
        .doc(id)
        .set(expense.toMap());

    return expense;
  }

  // Get all incomes for a user
  Stream<List<IncomeModel>> getIncomes(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_incomesCollection)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IncomeModel.fromMap(doc.data()))
            .toList());
  }

  // Get expenses for a specific income
  Stream<List<ExpenseModel>> getExpensesForIncome(
      String userId, String incomeId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_expensesCollection)
        .where('incomeId', isEqualTo: incomeId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromMap(doc.data()))
            .toList());
  }

  // Delete an income and its associated expenses
  Future<void> deleteIncome(String userId, String incomeId) async {
    // Get all expenses for this income
    final expensesSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_expensesCollection)
        .where('incomeId', isEqualTo: incomeId)
        .get();

    // Delete all expenses
    final batch = _firestore.batch();
    for (var doc in expensesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the income
    batch.delete(
      _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_incomesCollection)
          .doc(incomeId),
    );

    await batch.commit();
  }

  // Delete a specific expense
  Future<void> deleteExpense(String userId, String expenseId) async {
    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_expensesCollection)
        .doc(expenseId)
        .delete();
  }
}
