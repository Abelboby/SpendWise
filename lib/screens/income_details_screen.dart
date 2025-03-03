import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/income_model.dart';
import '../providers/finance_provider.dart';
import '../widgets/add_expense_dialog.dart';
import '../constants/app_colors.dart';
import '../models/space_model.dart';
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
            title: Text(
              'Delete Expense',
              style: TextStyle(color: AppColors.navy),
            ),
            content: Text(
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
    final expenses = financeProvider.getExpensesForIncome(income.id);
    final totalExpenses = financeProvider.getTotalExpensesForIncome(income.id);
    final remainingAmount =
        financeProvider.getRemainingAmountForIncome(income.id);

    // Check if this income is part of a space
    final space = income.spaceId != null
        ? spaceProvider.spaces.firstWhere((s) => s.id == income.spaceId)
        : null;

    // Only allow expense management if it's a personal income or user has proper permissions
    final canManageExpenses =
        space == null || financeProvider.canManageFinances(space);

    // Get creator info if this is a space income
    final creator =
        space?.members.firstWhere((m) => m.userId == income.createdBy);

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
        title: Text(
          'Income Details',
          style: TextStyle(color: AppColors.lightGrey),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
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
                      color: AppColors.lightGrey.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  DateFormat('MMMM dd, yyyy').format(income.dateTime),
                  style: TextStyle(color: AppColors.lightGrey.withOpacity(0.8)),
                ),
                if (income.notes != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.notes_outlined,
                        size: 16,
                        color: AppColors.lightGrey.withOpacity(0.8),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          income.notes!,
                          style: TextStyle(
                            color: AppColors.lightGrey.withOpacity(0.8),
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
                return Dismissible(
                  key: Key(expense.id),
                  direction: canManageExpenses
                      ? DismissDirection.endToStart
                      : DismissDirection.none,
                  confirmDismiss:
                      canManageExpenses ? (_) => _confirmDelete(context) : null,
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
                        color: AppColors.navy.withOpacity(0.1),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.navy,
                                          ),
                                    ),
                                    if (space != null &&
                                        expense.createdBy != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Added by ${space.members.firstWhere((m) => m.userId == expense.createdBy).displayName}',
                                        style: TextStyle(
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
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Rs. ${expense.amount.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: AppColors.darkGrey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('MMM dd, yyyy')
                                    .format(expense.dateTime),
                                style: TextStyle(color: AppColors.darkGrey),
                              ),
                            ],
                          ),
                          if (expense.notes != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.notes_outlined,
                                  size: 16,
                                  color: AppColors.darkGrey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    expense.notes!,
                                    style: TextStyle(
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
            color: AppColors.lightGrey.withOpacity(0.8),
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
