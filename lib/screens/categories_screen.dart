import 'package:flutter/material.dart';
import '../config/config.dart';
import '../services/expense_service.dart';
import '../models/category.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseService = ExpenseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Categories'),
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

                ...categories.map((category) {
                  final spent = spendingByCategory[category.name] ?? 0.0;
                  final count = transactionCounts[category.name] ?? 0;
                  return _buildCategoryCard(
                    category.name,
                    category.colorHex,
                    spent,
                    count,
                    context,
                  );
                }),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new category
        },
        backgroundColor: const Color(0xFFFFD60A),
        child: const Icon(Icons.add, color: Colors.black),
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
