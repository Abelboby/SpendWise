import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/income_model.dart';
import '../models/category_model.dart';
import '../providers/finance_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/add_expense_dialog.dart';
import '../constants/app_colors.dart';
import '../providers/space_provider.dart';

class IncomeDetailsScreen extends StatelessWidget {
  final IncomeModel income;

  const IncomeDetailsScreen({
    super.key,
    required this.income,
  });

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.lightGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Delete Expense',
              style: TextStyle(color: AppColors.navy),
            ),
            content: const Text(
              'Are you sure you want to delete this expense?',
              style: TextStyle(color: AppColors.darkGrey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.darkGrey,
                ),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final spaceProvider = Provider.of<SpaceProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final expenses = financeProvider.getExpensesForIncome(income.id);
    final totalExpenses = financeProvider.getTotalExpensesForIncome(income.id);
    final remainingAmount = financeProvider.getRemainingAmountForIncome(income.id);

    // Check if this income is part of a space
    final space = income.spaceId != null ? spaceProvider.spaces.firstWhere((s) => s.id == income.spaceId) : null;

    // Only allow expense management if it's a personal income or user has proper permissions
    final canManageExpenses = space == null || financeProvider.canManageFinances(space);

    // Get creator info if this is a space income
    final creator = space?.members.firstWhere((m) => m.userId == income.createdBy);

    // Get category info if available
    final categoryName = income.category != null && categoryProvider.isEnabled
        ? categoryProvider.categories
            .firstWhere(
              (c) => c.id == income.category,
              orElse: () => CategoryModel(
                id: '',
                name: 'Unknown',
                isDefault: false,
                createdAt: DateTime.now(),
              ),
            )
            .name
        : null;

    // Define colors for remaining amount
    final remainingAmountColor = remainingAmount >= 0
        ? const Color(0xFF4CAF50) // Material Green 500
        : const Color(0xFFE57373); // Material Red 300

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Income Details',
          style: TextStyle(color: AppColors.lightGrey),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.navy,
                  AppColors.darkGrey,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.description,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.lightGrey,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (creator != null) ...[
                  Text(
                    'Added by ${creator.displayName}',
                    style: TextStyle(
                      color: AppColors.lightGrey.withAlpha(204),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (categoryName != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(51),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: AppColors.lightGrey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          categoryName,
                          style: const TextStyle(
                            color: AppColors.lightGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  DateFormat('MMMM dd, yyyy').format(income.dateTime),
                  style: TextStyle(color: AppColors.lightGrey.withAlpha(204)),
                ),
                if (income.notes != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.notes_outlined,
                        size: 16,
                        color: AppColors.lightGrey.withAlpha(204),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          income.notes!,
                          style: TextStyle(
                            color: AppColors.lightGrey.withAlpha(204),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAmountColumn(
                      context,
                      'Total Amount',
                      income.amount,
                      AppColors.accent,
                    ),
                    _buildAmountColumn(
                      context,
                      'Spent',
                      totalExpenses,
                      const Color(0xFFEF5350), // Material Red 400
                    ),
                    _buildAmountColumn(
                      context,
                      'Remaining',
                      remainingAmount,
                      remainingAmountColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];

                // Get expense category info if available
                final expenseCategoryName = expense.category != null && categoryProvider.isEnabled
                    ? categoryProvider.categories
                        .firstWhere(
                          (c) => c.id == expense.category,
                          orElse: () => CategoryModel(
                            id: '',
                            name: 'Unknown',
                            isDefault: false,
                            createdAt: DateTime.now(),
                          ),
                        )
                        .name
                    : null;

                return Dismissible(
                  key: Key(expense.id),
                  direction: canManageExpenses ? DismissDirection.endToStart : DismissDirection.none,
                  confirmDismiss: canManageExpenses ? (_) => _confirmDelete(context) : null,
                  onDismissed: (_) => financeProvider.deleteExpense(expense.id),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.navy.withAlpha(25),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.description,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.navy,
                                          ),
                                    ),
                                    if (space != null && expense.createdBy != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Added by ${space.members.firstWhere((m) => m.userId == expense.createdBy).displayName}',
                                        style: const TextStyle(
                                          color: AppColors.darkGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withAlpha(25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Rs. ${expense.amount.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16,
                                    color: AppColors.darkGrey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(expense.dateTime),
                                    style: const TextStyle(color: AppColors.darkGrey),
                                  ),
                                ],
                              ),
                              if (expenseCategoryName != null) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withAlpha(25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.category_outlined,
                                        size: 14,
                                        color: AppColors.darkGrey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        expenseCategoryName,
                                        style: const TextStyle(
                                          color: AppColors.darkGrey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (expense.notes != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.notes_outlined,
                                  size: 16,
                                  color: AppColors.darkGrey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    expense.notes!,
                                    style: const TextStyle(
                                      color: AppColors.darkGrey,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: canManageExpenses
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AddExpenseDialog(income: income),
                );
              },
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            )
          : null,
    );
  }

  Widget _buildAmountColumn(
    BuildContext context,
    String label,
    double amount,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.lightGrey.withAlpha(204),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rs. ${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
