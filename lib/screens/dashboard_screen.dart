import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/expense_service.dart';
import '../services/export_service.dart';
import '../models/expense.dart';
import '../utils/animations.dart';
import 'all_expenses_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseService = ExpenseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'all_expenses') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllExpensesScreen()),
                );
              } else if (value == 'export_csv') {
                _exportToCSV(context, expenseService);
              } else if (value == 'export_report') {
                _exportToReport(context, expenseService);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all_expenses',
                child: Row(
                  children: [
                    Icon(Icons.list_alt, size: 20),
                    SizedBox(width: 12),
                    Text('All Expenses'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_csv',
                child: Row(
                  children: [
                    Icon(Icons.file_download, size: 20),
                    SizedBox(width: 12),
                    Text('Export to CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_report',
                child: Row(
                  children: [
                    Icon(Icons.description, size: 20),
                    SizedBox(width: 12),
                    Text('Export Report'),
                  ],
                ),
              ),
            ],
          ),
          _buildSyncStatusIndicator(expenseService),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: expenseService.expensesStream,
        builder: (context, snapshot) {
          final monthlyTotal = expenseService.getMonthlyTotal();
          final spendingByCategory = expenseService.getSpendingByCategory(
            startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
          );
          final transactionCount = expenseService.getMonthlyTransactionCount();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards with animation
                Row(
                  children: [
                    Expanded(
                      child: SlideUpAnimation(
                        delay: const Duration(milliseconds: 0),
                        child: _buildSummaryCard(
                          'Monthly Total',
                          '\$${monthlyTotal.toStringAsFixed(2)}',
                          Icons.trending_up,
                          context,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SlideUpAnimation(
                        delay: const Duration(milliseconds: 100),
                        child: _buildSummaryCard(
                          'Transactions',
                          '$transactionCount',
                          Icons.receipt_long,
                          context,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 24),

                // Pie Chart for Spending by Category
                SlideUpAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: const Text(
                    'Spending by Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                if (spendingByCategory.isEmpty)
                  SlideUpAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: _buildEmptyState('No expenses yet', context),
                  )
                else
                  SlideUpAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                      children: [
                        // Pie Chart
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              sections: _buildPieChartSections(spendingByCategory),
                              sectionsSpace: 2,
                              centerSpaceRadius: 50,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                        // Legend
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildLegend(spendingByCategory),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Category Breakdown with bars
                SlideUpAnimation(
                  delay: const Duration(milliseconds: 400),
                  child: const Text(
                    'Category Breakdown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                if (spendingByCategory.isEmpty)
                  SlideUpAnimation(
                    delay: const Duration(milliseconds: 500),
                    child: _buildEmptyState('Add expenses to see breakdown', context),
                  )
                else
                  ...spendingByCategory.entries.toList().asMap().entries.map((mapEntry) {
                    final index = mapEntry.key;
                    final entry = mapEntry.value;
                    final percentage = (entry.value / monthlyTotal * 100);
                    return SlideUpAnimation(
                      delay: Duration(milliseconds: 500 + (index * 50)),
                      child: _buildCategoryBar(
                        entry.key,
                        entry.value,
                        percentage,
                        context,
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                // Recent Expenses
                const Text(
                  'Recent Expenses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (expenseService.expenses.isEmpty)
                  _buildEmptyState('No recent expenses', context)
                else
                  ...expenseService.getRecentExpenses(limit: 5).map((expense) {
                    return _buildExpenseTile(expense, context);
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> spendingByCategory) {
    final total = spendingByCategory.values.reduce((a, b) => a + b);
    final colors = _getCategoryColors();

    return spendingByCategory.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = colors[entry.key] ?? Colors.grey;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: color,
      );
    }).toList();
  }

  List<Widget> _buildLegend(Map<String, double> spendingByCategory) {
    final colors = _getCategoryColors();

    return spendingByCategory.entries.map((entry) {
      final color = colors[entry.key] ?? Colors.grey;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.key,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Map<String, Color> _getCategoryColors() {
    return {
      'Food & Dining': const Color(0xFFFF9F40),
      'Transportation': const Color(0xFF4A90E2),
      'Groceries': const Color(0xFF4CAF50),
      'Entertainment': const Color(0xFF9B59B6),
      'Shopping': const Color(0xFFE91E63),
      'Healthcare': const Color(0xFFF44336),
      'Other': const Color(0xFF9E9E9E),
    };
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFFD60A), size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(
    String category,
    double amount,
    double percentage,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD60A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD60A)),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(Expense expense, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '${expense.category} • ${expense.formattedDate}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            expense.formattedAmount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _showEditExpenseDialog(context, expense),
            color: Colors.blue,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => _showDeleteExpenseDialog(context, expense),
            color: Colors.red,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusIndicator(ExpenseService expenseService) {
    if (!expenseService.isSyncEnabled) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<bool>(
      stream: expenseService.syncStatusStream,
      initialData: false,
      builder: (context, snapshot) {
        final isSyncing = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: isSyncing ? 'Syncing...' : 'Synced to cloud',
            child: Icon(
              isSyncing ? Icons.cloud_upload : Icons.cloud_done,
              color: isSyncing ? const Color(0xFFFFD60A) : Colors.green,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  void _showEditExpenseDialog(BuildContext context, Expense expense) {
    final expenseService = ExpenseService();
    final amountController = TextEditingController(text: expense.amount.toString());
    final descriptionController = TextEditingController(text: expense.description);
    String selectedCategory = expense.category;
    DateTime selectedDate = expense.date;
    final personController = TextEditingController(text: expense.person ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Amount field
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                // Description field
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(height: 16),
                // Category dropdown
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: expenseService.categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.name,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Date picker
                ListTile(
                  title: Text('Date: ${_formatDate(selectedDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                // Person field (optional)
                TextField(
                  controller: personController,
                  decoration: const InputDecoration(
                    labelText: 'Person (optional)',
                    hintText: 'Who was this with?',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                  return;
                }

                if (descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a description')),
                  );
                  return;
                }

                // Update expense
                final updatedExpense = expense.copyWith(
                  amount: amount,
                  description: descriptionController.text.trim(),
                  category: selectedCategory,
                  date: selectedDate,
                  person: personController.text.trim().isEmpty
                      ? null
                      : personController.text.trim(),
                );

                await expenseService.updateExpense(updatedExpense);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense updated successfully')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteExpenseDialog(BuildContext context, Expense expense) {
    final expenseService = ExpenseService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text(
          'Are you sure you want to delete this expense?\n\n'
          '${expense.description}\n'
          '${expense.formattedAmount}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await expenseService.deleteExpense(expense.id);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Expense deleted successfully')),
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _exportToCSV(BuildContext context, ExpenseService expenseService) {
    final expenses = expenseService.expenses;

    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No expenses to export')),
      );
      return;
    }

    ExportService.exportToCSV(expenses);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported ${expenses.length} expenses to CSV')),
    );
  }

  void _exportToReport(BuildContext context, ExpenseService expenseService) {
    final expenses = expenseService.expenses;

    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No expenses to export')),
      );
      return;
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final categoryTotals = expenseService.getSpendingByCategory(startDate: startOfMonth);

    ExportService.exportToTextReport(expenses, categoryTotals);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exported detailed report')),
    );
  }
}
