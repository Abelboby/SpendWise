import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/add_income_dialog.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/add_category_dialog.dart';
import '../constants/app_colors.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategoryId;

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
    final isFakeMode = appState.isFakeMode;
    final theme = Theme.of(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    // Set first category as selected if none is selected
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

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
            isFakeMode ? 'Expense Tracker (Fake)' : 'Income & Expense Tracker',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: isFakeMode ? AppColors.orange : AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + (!isFakeMode ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == categories.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => const AddCategoryDialog(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isFakeMode ? AppColors.orange : AppColors.navy,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.add,
                          color: isFakeMode ? AppColors.orange : AppColors.navy,
                        ),
                      ),
                    ),
                  );
                }

                final category = categories[index];
                final isSelected = category.id == _selectedCategoryId;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = category.id;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? (isFakeMode ? AppColors.orange : AppColors.navy) : Colors.transparent,
                        border: Border.all(
                          color: isFakeMode ? AppColors.orange : AppColors.navy,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            category.icon,
                            color: isSelected ? Colors.white : (isFakeMode ? AppColors.orange : AppColors.navy),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : (isFakeMode ? AppColors.orange : AppColors.navy),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedCategoryId != null) ...[
            Expanded(
              child: Consumer<ExpenseProvider>(
                builder: (context, expenseProvider, child) {
                  final incomes = expenseProvider.getIncomesByCategory(_selectedCategoryId!);
                  if (incomes.isEmpty) {
                    return Center(
                      child: Text(
                        'No incomes added yet. Add your first income!',
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: incomes.length,
                    itemBuilder: (context, index) {
                      final income = incomes[index];
                      final expenses = expenseProvider.getExpensesForIncome(income.id, isFake: isFakeMode);
                      final remainingAmount =
                          expenseProvider.getRemainingAmountForIncome(income.id, isFake: isFakeMode);

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ExpansionTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${income.amount}',
                                style: theme.textTheme.titleLarge,
                              ),
                              Text(
                                _formatDateTime(income.date),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      isFakeMode ? AppColors.orange.withOpacity(0.7) : AppColors.navy.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Remaining: ₹$remainingAmount',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: remainingAmount < 0 ? Colors.red : null,
                                ),
                              ),
                              Text(
                                income.description,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          iconColor: isFakeMode ? AppColors.orange : AppColors.navy,
                          collapsedIconColor: isFakeMode ? AppColors.orange : AppColors.navy,
                          children: [
                            ...expenses.map((expense) => ListTile(
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
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    expense.description,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () {
                                      expenseProvider.deleteExpense(expense.id, isFake: isFakeMode);
                                    },
                                    color: Colors.red,
                                  ),
                                )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () => _showAddExpenseDialog(
                                  context,
                                  income.id,
                                  remainingAmount,
                                  isFakeMode,
                                  _selectedCategoryId!,
                                ),
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
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: _selectedCategoryId != null
          ? FloatingActionButton(
              onPressed: () => _showAddIncomeDialog(context, _selectedCategoryId!),
              backgroundColor: isFakeMode ? AppColors.orange : AppColors.navy,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddIncomeDialog(BuildContext context, String categoryId) {
    showDialog(
      context: context,
      builder: (ctx) => AddIncomeDialog(categoryId: categoryId),
    );
  }

  void _showAddExpenseDialog(
    BuildContext context,
    String incomeId,
    double remainingAmount,
    bool isFakeMode,
    String categoryId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AddExpenseDialog(
        incomeId: incomeId,
        remainingAmount: remainingAmount,
        isFakeMode: isFakeMode,
        categoryId: categoryId,
      ),
    );
  }
}
