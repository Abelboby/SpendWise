import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/add_income_dialog.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/add_category_dialog.dart';
import '../constants/app_colors.dart';
import 'package:intl/intl.dart';

class CategoryViewScreen extends StatelessWidget {
  const CategoryViewScreen({super.key});

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${DateFormat('hh:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('hh:mm a').format(date)}';
    } else if (difference.inDays < 7) {
      return '${DateFormat('EEEE').format(date)} at ${DateFormat('hh:mm a').format(date)}';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final isFakeMode = appState.isFakeMode;
    final theme = Theme.of(context);
    final categories = categoryProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onDoubleTap: () {
            appState.toggleFakeMode();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isFakeMode ? 'Showing real expenses' : 'Showing fake expenses',
                  style: TextStyle(
                    color: isFakeMode ? AppColors.orange : AppColors.navy,
                  ),
                ),
                duration: const Duration(seconds: 1),
                backgroundColor: isFakeMode ? AppColors.yellow : AppColors.purple,
              ),
            );
          },
          child: Text(
            isFakeMode ? 'Categories (Fake)' : 'Categories',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: isFakeMode ? AppColors.orange : AppColors.navy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const AddCategoryDialog(),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final incomes = expenseProvider.getIncomesByCategory(category.id);
              final totalIncome = expenseProvider.getTotalIncomeByCategory(category.id);
              final totalExpenses = expenseProvider.getTotalExpensesByCategory(
                category.id,
                isFake: isFakeMode,
              );
              final remainingAmount = expenseProvider.getRemainingAmountByCategory(
                category.id,
                isFake: isFakeMode,
              );

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  leading: Icon(
                    category.icon,
                    color: isFakeMode ? AppColors.orange : AppColors.navy,
                  ),
                  title: Text(
                    category.name,
                    style: theme.textTheme.titleLarge,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Income: ₹$totalIncome',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        'Total Expenses: ₹$totalExpenses',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        'Remaining: ₹$remainingAmount',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: remainingAmount < 0
                              ? Colors.red
                              : isFakeMode
                                  ? AppColors.orange
                                  : AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    ...incomes.map((income) {
                      final expenses = expenseProvider.getExpensesForIncome(
                        income.id,
                        isFake: isFakeMode,
                      );
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ExpansionTile(
                          title: Text(
                            'Income: ₹${income.amount}',
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(income.description),
                              Text(
                                _formatDateTime(income.date),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          children: [
                            ...expenses.map(
                              (expense) => ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₹${expense.amount}',
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    Text(
                                      _formatDateTime(expense.date),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isFakeMode
                                            ? AppColors.orange.withOpacity(0.7)
                                            : AppColors.navy.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(expense.description),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AddExpenseDialog(
                                      incomeId: income.id,
                                      remainingAmount: income.remainingAmount,
                                      isFakeMode: isFakeMode,
                                      categoryId: category.id,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFakeMode ? AppColors.orange : AppColors.navy,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Add Expense'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AddIncomeDialog(
                              categoryId: category.id,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFakeMode ? AppColors.orange : AppColors.navy,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add Income'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (isFakeMode)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: AppColors.yellow,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'FAKE MODE',
                      style: TextStyle(
                        color: AppColors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
