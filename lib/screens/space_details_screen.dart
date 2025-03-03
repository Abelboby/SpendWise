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

class _SpaceDetailsScreenState extends State<SpaceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Set current space for finance operations
    final financeProvider = context.read<FinanceProvider>();
    financeProvider.setCurrentSpace(widget.space.id);
  }

  @override
  void dispose() {
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.lightGrey,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          elevation: 0,
          title: Text(
            'Space Details',
            style: TextStyle(color: AppColors.lightGrey),
          ),
          iconTheme: IconThemeData(color: AppColors.lightGrey),
          actions: [
            if (isOwner)
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.lightGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        'Delete Space',
                        style: TextStyle(color: AppColors.navy),
                      ),
                      content: Text(
                        'Are you sure you want to delete this space? This action cannot be undone.',
                        style: TextStyle(color: AppColors.darkGrey),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.darkGrey,
                          ),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await spaceProvider.deleteSpace(widget.space.id);
                              if (context.mounted) {
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(
                                    context); // Go back to spaces list
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Error deleting space: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline),
              ),
          ],
          bottom: TabBar(
            labelColor: AppColors.lightGrey,
            unselectedLabelColor: AppColors.lightGrey.withOpacity(0.7),
            indicatorColor: AppColors.accent,
            tabs: const [
              Tab(text: 'Incomes'),
              Tab(text: 'Members'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Incomes Tab
            Column(
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
                        widget.space.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.lightGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.space.description,
                        style: TextStyle(
                          color: AppColors.lightGrey.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            widget.space.isPublic
                                ? Icons.public
                                : Icons.lock_outline,
                            size: 16,
                            color: AppColors.lightGrey.withOpacity(0.8),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.space.isPublic
                                ? 'Public Space'
                                : 'Private Space',
                            style: TextStyle(
                              color: AppColors.lightGrey.withOpacity(0.8),
                            ),
                          ),
                          const Spacer(),
                          if (widget.space.isOwner(authProvider.uid))
                            TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: AppColors.lightGrey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: Text(
                                      'Share Space',
                                      style: TextStyle(color: AppColors.navy),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Share this code with others to join your space:',
                                          style: TextStyle(
                                            color: AppColors.darkGrey,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                AppColors.navy.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                widget.space.inviteCode,
                                                style: TextStyle(
                                                  color: AppColors.navy,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              IconButton(
                                                onPressed: () {
                                                  // TODO: Implement copy to clipboard
                                                },
                                                icon: Icon(
                                                  Icons.copy,
                                                  color: AppColors.accent,
                                                ),
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
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.lightGrey,
                              ),
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Share'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<FinanceProvider>(
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
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
                          final remainingAmount = financeProvider
                              .getRemainingAmountForIncome(income.id);
                          final creator = widget.space.members
                              .firstWhere((m) => m.userId == income.createdBy);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: AppColors.navy.withOpacity(0.1),
                              ),
                            ),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.navy,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Added by ${creator.displayName}',
                                                style: TextStyle(
                                                  color: AppColors.darkGrey,
                                                  fontSize: 12,
                                                ),
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
                                            color: AppColors.accent
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                          style: TextStyle(
                                              color: AppColors.darkGrey),
                                        ),
                                      ],
                                    ),
                                    if (income.notes != null) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        income.notes!,
                                        style: TextStyle(
                                          color: AppColors.darkGrey,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.lightGrey,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              AppColors.navy.withOpacity(0.1),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.receipt_outlined,
                                                size: 18,
                                                color: AppColors.darkGrey,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${expenses.length} Expenses',
                                                style: TextStyle(
                                                    color: AppColors.darkGrey),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'Remaining: Rs. ${remainingAmount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: remainingAmount >= 0
                                                  ? AppColors.accent
                                                  : Colors.red[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (canManageFinances) ...[
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    AddExpenseDialog(
                                                  income: income,
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.add),
                                            label: const Text('Add Expense'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.accent,
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
                      );
                    },
                  ),
                ),
              ],
            ),
            // Members Tab
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Members',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.space.members.length,
                    itemBuilder: (context, index) {
                      final member = widget.space.members[index];
                      final isCurrentUser = member.userId == authProvider.uid;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.navy.withOpacity(0.1),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              if (member.photoUrl != null)
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(member.photoUrl!),
                                  radius: 20,
                                )
                              else
                                CircleAvatar(
                                  backgroundColor:
                                      AppColors.accent.withOpacity(0.1),
                                  radius: 20,
                                  child: Text(
                                    member.displayName[0].toUpperCase(),
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${member.displayName}${isCurrentUser ? ' (You)' : ''}',
                                          style: TextStyle(
                                            color: AppColors.navy,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (widget.space
                                            .isOwner(member.userId)) ...[
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.star_rounded,
                                            color: AppColors.accent,
                                            size: 16,
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: member.role == SpaceRole.owner
                                            ? AppColors.accent.withOpacity(0.1)
                                            : member.role == SpaceRole.editor
                                                ? AppColors.navy
                                                    .withOpacity(0.1)
                                                : AppColors.darkGrey
                                                    .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        member.role.toString().split('.').last,
                                        style: TextStyle(
                                          color: member.role == SpaceRole.owner
                                              ? AppColors.accent
                                              : member.role == SpaceRole.editor
                                                  ? AppColors.navy
                                                  : AppColors.darkGrey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isOwner && !isCurrentUser)
                                PopupMenuButton<SpaceRole>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: AppColors.darkGrey,
                                  ),
                                  onSelected: (SpaceRole role) {
                                    spaceProvider.updateMemberRole(
                                      widget.space.id,
                                      member.userId,
                                      role,
                                    );
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(
                                      value: SpaceRole.editor,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit_outlined,
                                            color: AppColors.navy,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Make Editor',
                                            style: TextStyle(
                                                color: AppColors.navy),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: SpaceRole.viewer,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.visibility_outlined,
                                            color: AppColors.navy,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Make Viewer',
                                            style: TextStyle(
                                                color: AppColors.navy),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
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
        bottomNavigationBar: !isOwner
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: AppColors.lightGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(
                            'Leave Space',
                            style: TextStyle(color: AppColors.navy),
                          ),
                          content: Text(
                            'Are you sure you want to leave this space?',
                            style: TextStyle(color: AppColors.darkGrey),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.darkGrey,
                              ),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await spaceProvider
                                      .leaveSpace(widget.space.id);
                                  if (context.mounted) {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(
                                        context); // Go back to spaces list
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Error leaving space: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Leave'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Leave Space'),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
