import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/income.dart';
import '../models/expense.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'tracker';

  // Get user document reference
  DocumentReference _userDoc(String userId) => _firestore.collection(_collection).doc(userId);

  // Categories
  CollectionReference _categoriesCollection(String userId) => _userDoc(userId).collection('categories');

  Future<void> addCategory(String userId, Category category) async {
    await _categoriesCollection(userId).doc(category.id).set({
      'name': category.name,
      'iconCodePoint': category.icon.codePoint,
      'iconFontFamily': category.icon.fontFamily,
      'iconFontPackage': category.icon.fontPackage,
      'isDefault': category.isDefault,
    });
  }

  Stream<List<Category>> getCategories(String userId) {
    return _categoriesCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    });
  }

  Future<void> deleteCategory(String userId, String categoryId) async {
    await _categoriesCollection(userId).doc(categoryId).delete();
  }

  // Incomes
  CollectionReference _incomesCollection(String userId) => _userDoc(userId).collection('incomes');

  Future<void> addIncome(String userId, Income income) async {
    await _incomesCollection(userId).doc(income.id).set({
      'categoryId': income.categoryId,
      'amount': income.amount,
      'description': income.description,
      'date': income.date.toIso8601String(),
      'remainingAmount': income.remainingAmount,
    });
  }

  Stream<List<Income>> getIncomes(String userId) {
    return _incomesCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Income.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    });
  }

  Future<void> updateIncomeRemainingAmount(
    String userId,
    String incomeId,
    double remainingAmount,
  ) async {
    await _incomesCollection(userId).doc(incomeId).update({
      'remainingAmount': remainingAmount,
    });
  }

  Future<void> deleteIncome(String userId, String incomeId) async {
    await _incomesCollection(userId).doc(incomeId).delete();
  }

  // Expenses
  CollectionReference _expensesCollection(String userId) => _userDoc(userId).collection('expenses');

  CollectionReference _fakeExpensesCollection(String userId) => _userDoc(userId).collection('fake_expenses');

  Future<void> addExpense(String userId, Expense expense, {bool isFake = false}) async {
    final collection = isFake ? _fakeExpensesCollection(userId) : _expensesCollection(userId);
    await collection.doc(expense.id).set({
      'incomeId': expense.incomeId,
      'categoryId': expense.categoryId,
      'amount': expense.amount,
      'description': expense.description,
      'date': expense.date.toIso8601String(),
    });
  }

  Stream<List<Expense>> getExpenses(String userId, {bool isFake = false}) {
    final collection = isFake ? _fakeExpensesCollection(userId) : _expensesCollection(userId);
    return collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Expense.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    });
  }

  Future<void> deleteExpense(String userId, String expenseId, {bool isFake = false}) async {
    final collection = isFake ? _fakeExpensesCollection(userId) : _expensesCollection(userId);
    await collection.doc(expenseId).delete();
  }
}
