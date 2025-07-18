import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/finance_provider.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';
import '../screens/income_details_screen.dart';
import '../widgets/add_income_dialog.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: Icon(
              Icons.warning_rounded,
              color: Colors.red[400],
              size: 48,
            ),
            title: Text(
              'Delete Income',
              style: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warning: This action cannot be undone!',
                  style: TextStyle(
                    color: Color(0xFFEF5350),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete this income? All associated expenses will also be permanently deleted.',
                  style: TextStyle(color: AppColors.darkGrey),
                ),
              ],
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
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
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
    final incomes = financeProvider.incomes;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(38),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                AppIcons.wallet,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.lightGrey,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Personal Incomes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.navy,
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withAlpha(15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountColumn(
                  context,
                  'Total Income',
                  financeProvider.totalIncome,
                  AppColors.accent,
                ),
                _buildAmountColumn(
                  context,
                  'Total Spent',
                  financeProvider.totalExpenses,
                  const Color(0xFFEF5350),
                ),
                _buildAmountColumn(
                  context,
                  'Remaining',
                  financeProvider.totalIncome - financeProvider.totalExpenses,
                  financeProvider.totalIncome - financeProvider.totalExpenses >= 0
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE57373),
                ),
              ],
            ),
          ),
          Expanded(
            child: incomes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: AppColors.darkGrey.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Incomes Yet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.navy,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add an income to get started',
                          style: TextStyle(color: AppColors.darkGrey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: incomes.length,
                    itemBuilder: (context, index) {
                      final income = incomes[index];
                      final expenses = financeProvider.getExpensesForIncome(income.id);
                      final remainingAmount = financeProvider.getRemainingAmountForIncome(income.id);

                      return Dismissible(
                        key: Key(income.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _confirmDelete(context),
                        onDismissed: (_) => financeProvider.deleteIncome(income.id),
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
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.navy.withAlpha(25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IncomeDetailsScreen(income: income),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            income.description,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.navy,
                                                ),
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
                                            'Rs. ${income.amount.toStringAsFixed(2)}',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                          DateFormat('MMM dd, yyyy').format(income.dateTime),
                                          style: const TextStyle(color: AppColors.darkGrey),
                                        ),
                                      ],
                                    ),

                                    // Show category if available
                                    Builder(
                                      builder: (context) {
                                        final categoryProvider = context.watch<CategoryProvider>();
                                        if (!categoryProvider.isEnabled || income.category == null) {
                                          return const SizedBox.shrink();
                                        }

                                        final categoryName = categoryProvider.categories
                                            .firstWhere(
                                              (c) => c.id == income.category,
                                              orElse: () => CategoryModel(
                                                id: '',
                                                name: 'Unknown',
                                                isDefault: false,
                                                createdAt: DateTime.now(),
                                              ),
                                            )
                                            .name;

                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.category_outlined,
                                                size: 16,
                                                color: AppColors.darkGrey,
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.accent.withAlpha(25),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  categoryName,
                                                  style: const TextStyle(
                                                    color: AppColors.darkGrey,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 12),
                                    if (income.notes != null) ...[
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.navy.withAlpha(13),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.notes_outlined,
                                              size: 16,
                                              color: AppColors.darkGrey,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                income.notes!,
                                                style: const TextStyle(
                                                  color: AppColors.darkGrey,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.lightGrey,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.navy.withAlpha(25),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.receipt_outlined,
                                                  size: 16,
                                                  color: AppColors.navy,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${expenses.length} Expenses',
                                                style: const TextStyle(
                                                  color: AppColors.navy,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'Remaining: Rs. ${remainingAmount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: remainingAmount >= 0
                                                  ? const Color(0xFF4CAF50)
                                                  : const Color(0xFFE57373),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddIncomeDialog(),
          );
        },
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text('Add Income'),
      ),
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
