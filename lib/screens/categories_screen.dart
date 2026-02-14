import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../services/auth_service.dart';
import '../models/category.dart';
import '../utils/animations.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseService = ExpenseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Categories'),
        actions: [
          _buildUserMenu(context),
        ],
      ),
      body: StreamBuilder<List<Category>>(
        stream: expenseService.categoriesStream,
        builder: (context, snapshot) {
          final categories = expenseService.categories;
          final spendingByCategory = expenseService.getSpendingByCategory();
          final transactionCounts = expenseService.getCategoryTransactionCounts();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // AI Category Assistant
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 AI Category Assistant',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD60A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(
                      hintText: 'Ask AI to suggest categories, merge similar ones...',
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSuggestedPrompt('Suggest new categories'),
                      _buildSuggestedPrompt('Which categories are unused?'),
                      _buildSuggestedPrompt('Should I merge any categories?'),
                      _buildSuggestedPrompt('Analyze my category usage'),
                    ],
                  ),
                ],
              ),
            ),

                const SizedBox(height: 24),

                // Categories list
                const Text(
                  'Your Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ...categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final spent = spendingByCategory[category.name] ?? 0.0;
                  final count = transactionCounts[category.name] ?? 0;
                  return SlideUpAnimation(
                    delay: Duration(milliseconds: 100 + (index * 50)),
                    child: _buildCategoryCard(
                      category.name,
                      category.colorHex,
                      spent,
                      count,
                      context,
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: const Color(0xFFFFD60A),
        child: const Icon(Icons.add, color: Colors.black),
        tooltip: 'Add Category',
      ),
    );
  }

  Widget _buildSuggestedPrompt(String text) {
    return Chip(
      label: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.grey[800],
    );
  }

  Widget _buildCategoryCard(
    String name,
    String colorHex,
    double totalSpent,
    int transactionCount,
    BuildContext context,
  ) {
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${totalSpent.toStringAsFixed(2)} • $transactionCount ${transactionCount == 1 ? 'transaction' : 'transactions'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditCategoryDialog(context, name, colorHex),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteCategoryDialog(context, name),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  // Add Category Dialog
  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final expenseService = ExpenseService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g., Travel, Utilities',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final newCategory = Category(
                id: name,
                name: name,
                colorHex: '#${(0xFF000000 + (name.hashCode % 0xFFFFFF)).toRadixString(16).substring(2)}',
                iconName: 'category',
                isDefault: false,
              );

              await expenseService.addCategory(newCategory);
              if (context.mounted) Navigator.pop(context);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added category: $name')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Edit Category Dialog
  void _showEditCategoryDialog(BuildContext context, String oldName, String colorHex) {
    final nameController = TextEditingController(text: oldName);
    final expenseService = ExpenseService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty || newName == oldName) {
                Navigator.pop(context);
                return;
              }

              // Create updated category
              final updatedCategory = Category(
                id: oldName, // Keep same ID
                name: newName,
                colorHex: colorHex,
                iconName: 'category',
                isDefault: false,
              );

              await expenseService.updateCategory(updatedCategory);
              if (context.mounted) Navigator.pop(context);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated to: $newName')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Delete Category Dialog
  void _showDeleteCategoryDialog(BuildContext context, String name) {
    final expenseService = ExpenseService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$name"?\n\nExpenses in this category will not be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await expenseService.deleteCategory(name);
              if (context.mounted) Navigator.pop(context);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted: $name')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Build user menu with sign-out option
  static Widget _buildUserMenu(BuildContext context) {
    final authService = AuthService();
    final photoUrl = authService.getUserPhotoUrl();
    final displayName = authService.getUserDisplayName();
    final email = authService.userEmail ?? '';

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'signout') {
          _showSignOutDialog(context);
        }
      },
      offset: const Offset(0, 50),
      itemBuilder: (context) => [
        // User info header (disabled, not selectable)
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF98989D),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // Sign out option
        const PopupMenuItem<String>(
          value: 'signout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20),
              SizedBox(width: 12),
              Text('Sign Out'),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFFFD60A),
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null
              ? Text(
                  authService.getUserInitials(),
                  style: const TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  /// Show sign-out confirmation dialog
  static void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Sign out from both services
              await ExpenseService().signOut();
              await AuthService().signOut();

              // Auth state change will trigger navigation to LoginScreen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
