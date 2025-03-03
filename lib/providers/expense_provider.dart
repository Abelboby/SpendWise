import 'package:flutter/foundation.dart';
import '../models/income.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Income> _incomes = [];
  final List<Expense> _expenses = [];
  final List<Expense> _fakeExpenses = [];
  final _uuid = const Uuid();
  final _firestoreService = FirestoreService();
  final _auth = FirebaseAuth.instance;

  ExpenseProvider() {
    _initializeData();
  }

  void _initializeData() {
    final user = _auth.currentUser;
    if (user != null) {
      // Listen to incomes
      _firestoreService.getIncomes(user.uid).listen((incomes) {
        _incomes.clear();
        _incomes.addAll(incomes);
        notifyListeners();
      });

      // Listen to real expenses
      _firestoreService.getExpenses(user.uid).listen((expenses) {
        _expenses.clear();
        _expenses.addAll(expenses);
        notifyListeners();
      });

      // Listen to fake expenses
      _firestoreService.getExpenses(user.uid, isFake: true).listen((expenses) {
        _fakeExpenses.clear();
        _fakeExpenses.addAll(expenses);
        notifyListeners();
      });
    }
  }

  List<Income> get incomes => [..._incomes];
  List<Expense> get expenses => [..._expenses];
  List<Expense> get fakeExpenses => [..._fakeExpenses];

  // Category-based methods
  List<Income> getIncomesByCategory(String categoryId) {
    return _incomes.where((income) => income.categoryId == categoryId).toList();
  }

  List<Expense> getExpensesByCategory(String categoryId, {bool isFake = false}) {
    final targetList = isFake ? _fakeExpenses : _expenses;
    return targetList.where((expense) => expense.categoryId == categoryId).toList();
  }

  double getTotalIncomeByCategory(String categoryId) {
    return _incomes.where((income) => income.categoryId == categoryId).fold(0.0, (sum, income) => sum + income.amount);
  }

  double getTotalExpensesByCategory(String categoryId, {bool isFake = false}) {
    final targetList = isFake ? _fakeExpenses : _expenses;
    return targetList
        .where((expense) => expense.categoryId == categoryId)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double getRemainingAmountByCategory(String categoryId, {bool isFake = false}) {
    final totalIncome = getTotalIncomeByCategory(categoryId);
    final totalExpenses = getTotalExpensesByCategory(categoryId, isFake: isFake);
    return totalIncome - totalExpenses;
  }

  // Income-based methods
  List<Income> getIncomesForCategory(String categoryId) {
    return _incomes.where((income) => income.categoryId == categoryId).toList();
  }

  List<Expense> getExpensesForIncome(String incomeId, {bool isFake = false}) {
    final targetList = isFake ? _fakeExpenses : _expenses;
    return targetList.where((expense) => expense.incomeId == incomeId).toList();
  }

  double getRemainingAmountForIncome(String incomeId, {bool isFake = false}) {
    final income = _incomes.firstWhere((inc) => inc.id == incomeId);
    if (!isFake) return income.remainingAmount;

    final fakeExpensesTotal = _fakeExpenses
        .where((expense) => expense.incomeId == incomeId)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    return income.amount - fakeExpensesTotal;
  }

  // Add methods
  Future<void> addIncome(double amount, String description, DateTime date, String categoryId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final income = Income(
      id: _uuid.v4(),
      categoryId: categoryId,
      amount: amount,
      description: description,
      date: date,
      remainingAmount: amount,
    );

    await _firestoreService.addIncome(user.uid, income);
  }

  Future<void> addExpense(
    String incomeId,
    double amount,
    String description,
    DateTime date,
    String categoryId, {
    bool isFake = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final income = _incomes.firstWhere((inc) => inc.id == incomeId);
    if (income.remainingAmount >= amount || isFake) {
      final expense = Expense(
        id: _uuid.v4(),
        incomeId: incomeId,
        categoryId: categoryId,
        amount: amount,
        description: description,
        date: date,
      );

      if (isFake) {
        await _firestoreService.addExpense(user.uid, expense, isFake: true);
      } else {
        await _firestoreService.updateIncomeRemainingAmount(
          user.uid,
          incomeId,
          income.remainingAmount - amount,
        );
        await _firestoreService.addExpense(user.uid, expense);
      }
    }
  }

  // Delete methods
  Future<void> deleteIncome(String incomeId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestoreService.deleteIncome(user.uid, incomeId);

    // Delete associated expenses
    final realExpenses = _expenses.where((e) => e.incomeId == incomeId).toList();
    final fakeExpenses = _fakeExpenses.where((e) => e.incomeId == incomeId).toList();

    for (final expense in realExpenses) {
      await _firestoreService.deleteExpense(user.uid, expense.id);
    }

    for (final expense in fakeExpenses) {
      await _firestoreService.deleteExpense(user.uid, expense.id, isFake: true);
    }
  }

  Future<void> deleteExpense(String expenseId, {bool isFake = false}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (isFake) {
      await _firestoreService.deleteExpense(user.uid, expenseId, isFake: true);
    } else {
      final expense = _expenses.firstWhere((e) => e.id == expenseId);
      final income = _incomes.firstWhere((i) => i.id == expense.incomeId);

      await _firestoreService.updateIncomeRemainingAmount(
        user.uid,
        income.id,
        income.remainingAmount + expense.amount,
      );
      await _firestoreService.deleteExpense(user.uid, expenseId);
    }
  }
}
