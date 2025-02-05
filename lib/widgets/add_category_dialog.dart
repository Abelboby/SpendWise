import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/app_state_provider.dart';
import '../constants/app_colors.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.folder;

  final List<IconData> _availableIcons = [
    Icons.home,
    Icons.person,
    Icons.work,
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_hospital,
    Icons.school,
    Icons.directions_car,
    Icons.flight,
    Icons.sports_esports,
    Icons.movie,
    Icons.fitness_center,
    Icons.pets,
    Icons.child_care,
    Icons.local_grocery_store,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      Provider.of<CategoryProvider>(context, listen: false).addCategory(
        name: name,
        icon: _selectedIcon,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFakeMode = context.watch<AppStateProvider>().isFakeMode;
    final primaryColor = isFakeMode ? AppColors.orange : AppColors.navy;

    return AlertDialog(
      title: Text(
        'Add New Category',
        style: theme.textTheme.titleLarge?.copyWith(color: primaryColor),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
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
              style: TextStyle(color: primaryColor),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Select Icon',
              style: TextStyle(color: primaryColor),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: primaryColor.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = _availableIcons[index];
                  final isSelected = icon == _selectedIcon;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? primaryColor : primaryColor.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        icon,
                        color: primaryColor,
                      ),
                    ),
                  );
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
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
