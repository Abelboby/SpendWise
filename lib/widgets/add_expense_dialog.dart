import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../constants/app_colors.dart';
import 'package:intl/intl.dart';

class AddExpenseDialog extends StatefulWidget {
  final String incomeId;
  final double remainingAmount;
  final bool isFakeMode;
  final String categoryId;

  const AddExpenseDialog({
    super.key,
    required this.incomeId,
    required this.remainingAmount,
    required this.isFakeMode,
    required this.categoryId,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.isFakeMode ? AppColors.orange : AppColors.navy,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: widget.isFakeMode ? AppColors.orange : AppColors.navy,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text;

      Provider.of<ExpenseProvider>(context, listen: false).addExpense(
        widget.incomeId,
        amount,
        description,
        _selectedDateTime,
        widget.categoryId,
        isFake: widget.isFakeMode,
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.isFakeMode ? AppColors.orange : AppColors.navy;

    return AlertDialog(
      title: Text(
        widget.isFakeMode ? 'Add New Fake Expense' : 'Add New Expense',
        style: theme.textTheme.titleLarge?.copyWith(color: primaryColor),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remaining Amount: ₹${widget.remainingAmount}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '₹',
                labelStyle: TextStyle(color: primaryColor),
                prefixStyle: TextStyle(color: primaryColor),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
                ),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: primaryColor),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'Please enter a valid number';
                }
                if (amount <= 0) {
                  return 'Amount must be greater than 0';
                }
                if (amount > widget.remainingAmount) {
                  return 'Amount cannot be greater than remaining amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: primaryColor),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
                ),
              ),
              style: TextStyle(color: primaryColor),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDateTime,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: primaryColor.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy hh:mm a').format(_selectedDateTime),
                      style: TextStyle(color: primaryColor),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: primaryColor,
                      size: 20,
                    ),
                  ],
                ),
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
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.isFakeMode ? 'Add Fake' : 'Add'),
        ),
      ],
    );
  }
}
