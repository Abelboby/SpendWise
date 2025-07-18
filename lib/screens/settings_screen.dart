import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.category_outlined,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Category',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'Enter category name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter category description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.darkGrey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        final categoryProvider = context.read<CategoryProvider>();
                        categoryProvider.addCategory(
                          name: nameController.text,
                          description: descController.text.isNotEmpty ? descController.text : null,
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, CategoryModel category) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete the category "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.darkGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<CategoryProvider>().deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.accent),
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
          'Settings',
          style: TextStyle(color: AppColors.lightGrey),
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.navy,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        value: categoryProvider.isEnabled,
                        onChanged: (value) {
                          categoryProvider.toggleCategoryFeature(value);
                          if (value && categoryProvider.categories.isEmpty) {
                            categoryProvider.addDefaultCategories();
                          }
                        },
                        title: Text(
                          'Enable Categories',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Allow categorization of incomes and expenses',
                          style: TextStyle(color: AppColors.darkGrey),
                        ),
                      ),
                      if (categoryProvider.isEnabled) ...[
                        const Divider(),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categoryProvider.categories.length,
                          itemBuilder: (context, index) {
                            final category = categoryProvider.categories[index];
                            return ListTile(
                              title: Text(
                                category.name,
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: category.description != null
                                  ? Text(
                                      category.description!,
                                      style: TextStyle(color: AppColors.darkGrey),
                                    )
                                  : null,
                              trailing: category.isDefault
                                  ? Chip(
                                      label: const Text('Default'),
                                      backgroundColor: AppColors.accent.withAlpha((0.1 * 255).toInt()),
                                      labelStyle: TextStyle(color: AppColors.accent),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: AppColors.accent,
                                      onPressed: () => _confirmDelete(context, category),
                                    ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddCategoryDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Category'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
