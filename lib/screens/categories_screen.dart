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
    final primaryColor = isFakeMode ? AppColors.orange : AppColors.navy;
    final categories = context.watch<CategoryProvider>().categories;
    final expenseProvider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
      ),
      body: ListView.builder(
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
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ExpansionTile(
              leading: Icon(category.icon, color: primaryColor),
              title: Text(
                category.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Income: ₹$totalIncome',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    'Remaining: ₹$remainingAmount',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: remainingAmount < 0 ? Colors.red : null,
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Expenses:',
                            style: theme.textTheme.bodyLarge,
                          ),
                          Text(
                            '₹$totalExpenses',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
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
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Income'),
                      ),
                      if (!category.isDefault) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            final totalAmount = expenseProvider.getTotalIncomeByCategory(category.id);
                            if (totalAmount > 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cannot delete category with existing incomes'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              context.read<CategoryProvider>().deleteCategory(category.id);
                            }
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text('Delete Category', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: !isFakeMode
          ? FloatingActionButton(
              onPressed: () => _showAddCategoryDialog(context, primaryColor),
              backgroundColor: primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
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
          style: TextStyle(color: primaryColor),
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
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
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
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
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
            child: Text('Cancel', style: TextStyle(color: primaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<CategoryProvider>().addCustomCategory(nameController.text, selectedIcon);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
