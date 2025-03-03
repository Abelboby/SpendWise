import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/space_model.dart';
import '../providers/space_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/add_income_dialog.dart';
import '../widgets/add_expense_dialog.dart';
import '../screens/income_details_screen.dart';

class SpaceDetailsScreen extends StatefulWidget {
  final SpaceModel space;

  const SpaceDetailsScreen({
    super.key,
    required this.space,
  });

  @override
  State<SpaceDetailsScreen> createState() => _SpaceDetailsScreenState();
}

class _SpaceDetailsScreenState extends State<SpaceDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Set current space for finance operations
    final financeProvider = context.read<FinanceProvider>();
    financeProvider.setCurrentSpace(widget.space.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Reset current space when leaving
    final financeProvider = context.read<FinanceProvider>();
    financeProvider.setCurrentSpace(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final spaceProvider = Provider.of<SpaceProvider>(context);
    final financeProvider = Provider.of<FinanceProvider>(context);
    final isOwner = widget.space.isOwner(authProvider.uid);
    final canManageFinances = financeProvider.canManageFinances(widget.space);

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.space.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.space.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.share_outlined),
                          title: const Text('Share Space'),
                          subtitle: const Text('Invite members to join'),
                          onTap: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Text(
                                  'Share Space',
                                  style: TextStyle(color: AppColors.navy),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Space ID:',
                                      style: TextStyle(
                                        color: AppColors.darkGrey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.navy.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.space.id,
                                              style: TextStyle(
                                                color: AppColors.navy,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.copy),
                                            color: AppColors.accent,
                                            onPressed: () {
                                              // Copy to clipboard
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.darkGrey,
                                    ),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        if (isOwner) ...[
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            title: const Text('Delete Space'),
                            subtitle:
                                const Text('This action cannot be undone'),
                            onTap: () {
                              // Handle delete
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Incomes'),
            Tab(text: 'Members'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Incomes Tab
          Consumer<FinanceProvider>(
            builder: (context, financeProvider, _) {
              final incomes = financeProvider.incomes;

              if (incomes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64,
                        color: AppColors.darkGrey.withOpacity(0.5),
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
                        canManageFinances
                            ? 'Add an income to get started'
                            : 'No incomes have been added yet',
                        style: TextStyle(color: AppColors.darkGrey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: incomes.length,
                itemBuilder: (context, index) {
                  final income = incomes[index];
                  final expenses =
                      financeProvider.getExpensesForIncome(income.id);
                  final remainingAmount =
                      financeProvider.getRemainingAmountForIncome(income.id);
                  final creator = widget.space.members
                      .firstWhere((m) => m.userId == income.createdBy);

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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IncomeDetailsScreen(
                                income: income,
                              ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          income.description,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.navy,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 10,
                                              backgroundColor: AppColors.accent
                                                  .withOpacity(0.2),
                                              child: Text(
                                                creator.displayName[0]
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: AppColors.accent,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              creator.displayName,
                                              style: TextStyle(
                                                color: AppColors.darkGrey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
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
                                      'Rs. ${income.amount.toStringAsFixed(2)}',
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
                              const SizedBox(height: 12),
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
                                        .format(income.dateTime),
                                    style: TextStyle(color: AppColors.darkGrey),
                                  ),
                                ],
                              ),
                              if (income.notes != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.navy.withOpacity(0.05),
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
                                          style: TextStyle(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                AppColors.navy.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.receipt_outlined,
                                            size: 16,
                                            color: AppColors.navy,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${expenses.length} Expenses',
                                          style: TextStyle(
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
                              if (canManageFinances) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AddExpenseDialog(
                                            income: income,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Add Expense'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.accent,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
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
                    ),
                  );
                },
              );
            },
          ),

          // Members Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.space.members.length,
            itemBuilder: (context, index) {
              final member = widget.space.members[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accent.withOpacity(0.2),
                    child: Text(
                      member.displayName[0].toUpperCase(),
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    member.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    member.role.name[0].toUpperCase() +
                        member.role.name.substring(1),
                    style: TextStyle(
                      color: AppColors.darkGrey,
                    ),
                  ),
                  trailing: member.role == SpaceRole.owner
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Owner',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: canManageFinances
          ? FloatingActionButton.extended(
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
            )
          : null,
    );
  }
}
