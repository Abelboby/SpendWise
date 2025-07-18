import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../providers/category_provider.dart';
import '../constants/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  Widget _buildAnalyticCard({
    required BuildContext context,
    required String title,
    required Widget child,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.accent),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final totalIncome = financeProvider.totalIncome;
    final totalExpenses = financeProvider.totalExpenses;
    final remainingAmount = totalIncome - totalExpenses;
    final spendingPercentage = totalIncome > 0 ? (totalExpenses / totalIncome * 100) : 0;

    return _buildAnalyticCard(
      context: context,
      title: 'Financial Overview',
      icon: Icons.analytics_outlined,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem(
                  context,
                  'Total Income',
                  'Rs. ${NumberFormat('#,##0.00').format(totalIncome)}',
                  Icons.arrow_upward,
                  AppColors.accent,
                ),
                _buildMetricItem(
                  context,
                  'Total Expenses',
                  'Rs. ${NumberFormat('#,##0.00').format(totalExpenses)}',
                  Icons.arrow_downward,
                  Colors.red[400]!,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem(
                  context,
                  'Balance',
                  'Rs. ${NumberFormat('#,##0.00').format(remainingAmount)}',
                  Icons.account_balance_wallet_outlined,
                  remainingAmount >= 0 ? Colors.green[400]! : Colors.red[400]!,
                ),
                _buildMetricItem(
                  context,
                  'Spending',
                  '${spendingPercentage.toStringAsFixed(1)}%',
                  Icons.pie_chart_outline,
                  AppColors.navy,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Flexible(
                    flex: totalExpenses.toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: spendingPercentage > 90
                            ? Colors.red[400]
                            : spendingPercentage > 70
                                ? Colors.orange[400]
                                : Colors.green[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: (totalIncome - totalExpenses).toInt(),
                    child: Container(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAnalyticsCard(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final financeProvider = Provider.of<FinanceProvider>(context);
    final categories = categoryProvider.categories;
    final isEnabled = categoryProvider.isEnabled;

    if (!isEnabled || categories.isEmpty) {
      return Container();
    }

    return _buildAnalyticCard(
      context: context,
      title: 'Category Analysis',
      icon: Icons.category_outlined,
      child: Column(
        children: categories.map((category) {
          final incomes = financeProvider.incomes.where((income) => income.category == category.id).toList();
          final totalIncome = incomes.fold(0.0, (sum, income) => sum + income.amount);

          final expenses = financeProvider.expensesByIncome.values
              .expand((expenses) => expenses)
              .where((expense) => expense.category == category.id)
              .toList();
          final totalExpenses = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

          final percentage = totalIncome > 0 ? (totalExpenses / totalIncome * 100) : 0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.name,
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Income: Rs. ${NumberFormat('#,##0.00').format(totalIncome)}',
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Expenses: Rs. ${NumberFormat('#,##0.00').format(totalExpenses)}',
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          child: Stack(
                            children: [
                              Center(
                                child: CircularProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: AppColors.lightGrey,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    percentage > 90
                                        ? Colors.red[400]!
                                        : percentage > 70
                                            ? Colors.orange[400]!
                                            : Colors.green[400]!,
                                  ),
                                  strokeWidth: 8,
                                ),
                              ),
                              const Center(
                                child: Icon(
                                  Icons.category,
                                  size: 24,
                                  color: AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (categories.last.id != category.id) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Analytics',
          style: TextStyle(color: AppColors.lightGrey),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOverviewCard(context),
          _buildCategoryAnalyticsCard(context),
        ],
      ),
    );
  }
}
