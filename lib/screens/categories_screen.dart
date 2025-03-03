import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/app_state_provider.dart';
import '../constants/app_colors.dart';
import '../widgets/add_income_dialog.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFakeMode = context.watch<AppStateProvider>().isFakeMode;
    final primaryColor = isFakeMode ? AppColors.darkGrey : AppColors.navy;
    final categories = context.watch<CategoryProvider>().categories;
    final expenseProvider = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Categories',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
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
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: primaryColor.withOpacity(0.1),
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                leading: Icon(
                  category.icon,
                  color: AppColors.accent,
                  size: 24,
                ),
                iconColor: AppColors.accent,
                collapsedIconColor: AppColors.accent,
                title: Text(
                  category.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Total Income: ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '₹${totalIncome.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Remaining: ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '₹${remainingAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: remainingAmount >= 0 ? AppColors.accent : Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Expenses:',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '₹${totalExpenses.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AddIncomeDialog(categoryId: category.id),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Add Income'),
                        ),
                        if (!category.isDefault) ...[
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              final totalAmount = expenseProvider.getTotalIncomeByCategory(category.id);
                              if (totalAmount > 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Cannot delete category with existing incomes',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red[700],
                                  ),
                                );
                              } else {
                                context.read<CategoryProvider>().deleteCategory(category.id);
                              }
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red[300],
                              size: 20,
                            ),
                            label: Text(
                              'Delete Category',
                              style: TextStyle(
                                color: Colors.red[300],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: !isFakeMode
          ? FloatingActionButton(
              onPressed: () => _showAddCategoryDialog(context, primaryColor),
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              child: const Icon(Icons.add, size: 20),
            )
          : null,
    );
  }

  void _showAddCategoryDialog(BuildContext context, Color primaryColor) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    IconData selectedIcon = Icons.category;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Add New Category',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: TextStyle(color: primaryColor),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<IconData>(
                  value: selectedIcon,
                  decoration: InputDecoration(
                    labelText: 'Icon',
                    labelStyle: TextStyle(color: primaryColor),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: Icons.category,
                      child: Icon(Icons.category),
                    ),
                    DropdownMenuItem(
                      value: Icons.work,
                      child: Icon(Icons.work),
                    ),
                    DropdownMenuItem(
                      value: Icons.shopping_cart,
                      child: Icon(Icons.shopping_cart),
                    ),
                    DropdownMenuItem(
                      value: Icons.school,
                      child: Icon(Icons.school),
                    ),
                    DropdownMenuItem(
                      value: Icons.family_restroom,
                      child: Icon(Icons.family_restroom),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedIcon = value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<CategoryProvider>().addCustomCategory(nameController.text, selectedIcon);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
