import 'package:flutter/foundation.dart';
import '../models/income_model.dart';
import '../models/expense_model.dart';
import '../services/finance_service.dart';

class FinanceProvider with ChangeNotifier {
  final FinanceService _financeService = FinanceService();
  List<IncomeModel> _incomes = [];
  Map<String, List<ExpenseModel>> _expensesByIncome = {};
  String? _userId;

  List<IncomeModel> get incomes => _incomes;
  Map<String, List<ExpenseModel>> get expensesByIncome => _expensesByIncome;

  void initialize(String userId) {
    _userId = userId;
    _listenToIncomes();
  }

  void _listenToIncomes() {
    if (_userId == null) return;

    _financeService.getIncomes(_userId!).listen((incomes) {
      _incomes = incomes;
      // Listen to expenses for each income
      for (var income in incomes) {
        _listenToExpensesForIncome(income.id);
      }
      notifyListeners();
    });
  }

  void _listenToExpensesForIncome(String incomeId) {
    if (_userId == null) return;

    _financeService.getExpensesForIncome(_userId!, incomeId).listen((expenses) {
      _expensesByIncome[incomeId] = expenses;
      notifyListeners();
    });
  }

  Future<void> addIncome({
    required double amount,
    required String description,
    required DateTime dateTime,
    String? notes,
    String? category,
  }) async {
    if (_userId == null) return;

    await _financeService.addIncome(
      amount: amount,
      description: description,
      dateTime: dateTime,
      userId: _userId!,
      notes: notes,
      category: category,
    );
  }

  Future<void> addExpense({
    required String incomeId,
    required double amount,
    required String description,
    required DateTime dateTime,
    String? notes,
    String? category,
    String? paymentMethod,
  }) async {
    if (_userId == null) return;

    await _financeService.addExpense(
      incomeId: incomeId,
      amount: amount,
      description: description,
      dateTime: dateTime,
      userId: _userId!,
      notes: notes,
      category: category,
      paymentMethod: paymentMethod,
    );
  }

  Future<void> deleteIncome(String incomeId) async {
    if (_userId == null) return;
    await _financeService.deleteIncome(_userId!, incomeId);
  }

  Future<void> deleteExpense(String expenseId) async {
    if (_userId == null) return;
    await _financeService.deleteExpense(_userId!, expenseId);
  }

  List<ExpenseModel> getExpensesForIncome(String incomeId) {
    return _expensesByIncome[incomeId] ?? [];
  }

  double getTotalExpensesForIncome(String incomeId) {
    final expenses = _expensesByIncome[incomeId] ?? [];
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  double getRemainingAmountForIncome(String incomeId) {
    final income = _incomes.firstWhere((income) => income.id == incomeId);
    final totalExpenses = getTotalExpensesForIncome(incomeId);
    return income.amount - totalExpenses;
  }
}
