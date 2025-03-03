import 'package:flutter/foundation.dart';
import '../models/income_model.dart';
import '../models/expense_model.dart';
import '../services/finance_service.dart';
import '../models/space_model.dart';
import 'package:uuid/uuid.dart';

class FinanceProvider with ChangeNotifier {
  final FinanceService _financeService = FinanceService();
  List<IncomeModel> _incomes = [];
  Map<String, List<ExpenseModel>> _expensesByIncome = {};
  String? _userId;
  String? _currentSpaceId;

  List<IncomeModel> get incomes => _incomes;
  Map<String, List<ExpenseModel>> get expensesByIncome => _expensesByIncome;
  String? get currentSpaceId => _currentSpaceId;

  double get totalIncome {
    return _incomes.fold(0, (sum, income) => sum + income.amount);
  }

  double get totalExpenses {
    return _expensesByIncome.values
        .expand((expenses) => expenses)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  void initialize(String userId) {
    _userId = userId;
    _listenToIncomes();
  }

  void setCurrentSpace(String? spaceId) {
    if (_currentSpaceId != spaceId) {
      _currentSpaceId = spaceId;
      _incomes = []; // Clear current incomes
      _expensesByIncome = {}; // Clear current expenses
      _listenToIncomes();
    }
  }

  void _listenToIncomes() {
    if (_userId == null) return;

    // Cancel previous listeners if any
    _incomes = [];
    _expensesByIncome = {};
    notifyListeners();

    _financeService
        .getIncomes(_userId!, spaceId: _currentSpaceId)
        .listen((incomes) {
      _incomes = incomes;
      // Clear old expense listeners
      _expensesByIncome = {};
      // Listen to expenses for each income
      for (var income in incomes) {
        _listenToExpensesForIncome(income.id);
      }
      notifyListeners();
    });
  }

  void _listenToExpensesForIncome(String incomeId) {
    if (_userId == null) return;

    _financeService
        .getExpensesForIncome(_userId!, incomeId, spaceId: _currentSpaceId)
        .listen((expenses) {
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
      spaceId: _currentSpaceId,
      createdBy: _userId,
    );
  }

  Future<void> addExpense({
    required String description,
    required double amount,
    required DateTime dateTime,
    required String incomeId,
    String? notes,
    String? category,
  }) async {
    try {
      final expense = ExpenseModel(
        id: const Uuid().v4(),
        description: description,
        amount: amount,
        dateTime: dateTime,
        notes: notes,
        incomeId: incomeId,
        spaceId: _currentSpaceId,
        createdBy: _userId,
        category: category,
      );

      await _financeService.addExpense(expense);
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }

  Future<void> deleteIncome(String incomeId) async {
    if (_userId == null) return;
    await _financeService.deleteIncome(_userId!, incomeId,
        spaceId: _currentSpaceId);
  }

  Future<void> deleteExpense(String expenseId) async {
    if (_userId == null) return;
    await _financeService.deleteExpense(_userId!, expenseId,
        spaceId: _currentSpaceId);
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

  bool canManageFinances(SpaceModel space) {
    if (_userId == null) return false;
    final member = space.getMember(_userId!);
    return member != null &&
        (member.role == SpaceRole.owner || member.role == SpaceRole.editor);
  }
}
