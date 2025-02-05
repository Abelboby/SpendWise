import 'package:flutter/foundation.dart';
import '../models/income.dart';
import '../models/expense.dart';
import 'package:uuid/uuid.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Income> _incomes = [];
  final List<Expense> _expenses = [];
  final List<Expense> _fakeExpenses = [];
  final _uuid = const Uuid();

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
  void addIncome(double amount, String description, DateTime date, String categoryId) {
    final income = Income(
      id: _uuid.v4(),
      categoryId: categoryId,
      amount: amount,
      description: description,
      date: date,
      remainingAmount: amount,
    );
    _incomes.add(income);
    notifyListeners();
  }

  void addExpense(
    String incomeId,
    double amount,
    String description,
    DateTime date,
    String categoryId, {
    bool isFake = false,
  }) {
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
        _fakeExpenses.add(expense);
      } else {
        income.remainingAmount -= amount;
        _expenses.add(expense);
      }
      notifyListeners();
    }
  }

  // Delete methods
  void deleteIncome(String incomeId) {
    _incomes.removeWhere((income) => income.id == incomeId);
    _expenses.removeWhere((expense) => expense.incomeId == incomeId);
    _fakeExpenses.removeWhere((expense) => expense.incomeId == incomeId);
    notifyListeners();
  }

  void deleteExpense(String expenseId, {bool isFake = false}) {
    if (isFake) {
      _fakeExpenses.removeWhere((expense) => expense.id == expenseId);
    } else {
      final expense = _expenses.firstWhere((e) => e.id == expenseId);
      final income = _incomes.firstWhere((i) => i.id == expense.incomeId);
      income.remainingAmount += expense.amount;
      _expenses.removeWhere((e) => e.id == expenseId);
    }
    notifyListeners();
  }
}
