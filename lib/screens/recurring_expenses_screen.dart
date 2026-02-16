import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import '../utils/animations.dart';

class RecurringExpensesScreen extends StatefulWidget {
  const RecurringExpensesScreen({super.key});

  @override
  State<RecurringExpensesScreen> createState() => _RecurringExpensesScreenState();
}

class _RecurringExpensesScreenState extends State<RecurringExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    final expenseService = ExpenseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Expenses'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateRecurringDialog(context),
            tooltip: 'Add Recurring Expense',
          ),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: expenseService.expensesStream,
        builder: (context, snapshot) {
          final templates = expenseService.getRecurringTemplates();

          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.repeat, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  const Text(
                    'No recurring expenses yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add subscriptions or regular bills',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return SlideUpAnimation(
                delay: Duration(milliseconds: index * 50),
                child: _buildRecurringCard(template, context, expenseService),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecurringCard(Expense template, BuildContext context, ExpenseService expenseService) {
    final instances = expenseService.getRecurringInstances(template.id);
    final isActive = template.recurringEndDate == null ||
        DateTime.now().isBefore(template.recurringEndDate!);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFFFFD60A) : Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD60A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.repeat, size: 16, color: Color(0xFFFFD60A)),
                    const SizedBox(width: 4),
                    Text(
                      template.recurringDisplayText,
                      style: const TextStyle(
                        color: Color(0xFFFFD60A),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'STOPPED',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            template.description,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            template.category,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                template.formattedAmount,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD60A),
                ),
              ),
              const Spacer(),
              Text(
                '${instances.length} payments made',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          if (template.recurringEndDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Ends: ${template.recurringEndDate!.month}/${template.recurringEndDate!.day}/${template.recurringEndDate!.year}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (isActive)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showStopDialog(context, template, expenseService),
                    icon: const Icon(Icons.stop, size: 16),
                    label: const Text('Stop'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              if (isActive) const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteDialog(context, template, expenseService),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateRecurringDialog(BuildContext context) {
    final expenseService = ExpenseService();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = expenseService.categories.first.name;
    String selectedFrequency = 'monthly';
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Recurring Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g., Netflix Subscription',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: expenseService.categories.map((cat) {
                    return DropdownMenuItem(value: cat.name, child: Text(cat.name));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedFrequency,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedFrequency = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(endDate == null
                      ? 'No end date'
                      : 'Ends: ${endDate!.month}/${endDate!.day}/${endDate!.year}'),
                  subtitle: const Text('Optional'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setState(() {
                        endDate = picked;
                      });
                    }
                  },
                  contentPadding: EdgeInsets.zero,
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

                final recurringExpense = Expense(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: expenseService.currentUserId ?? 'user123',
                  amount: amount,
                  category: selectedCategory,
                  description: descriptionController.text.trim(),
                  date: DateTime.now(),
                  createdAt: DateTime.now(),
                  isRecurring: true,
                  recurringFrequency: selectedFrequency,
                  recurringEndDate: endDate,
                );

                await expenseService.addExpense(recurringExpense);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recurring expense created')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStopDialog(BuildContext context, Expense template, ExpenseService expenseService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Recurring Expense'),
        content: Text('Stop "${template.description}"? No new payments will be created.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await expenseService.stopRecurringExpense(template.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recurring expense stopped')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Expense template, ExpenseService expenseService) {
    final instances = expenseService.getRecurringInstances(template.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Expense'),
        content: Text(
          'Delete "${template.description}"?\n\n'
          'This will delete the template and all ${instances.length} payment records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await expenseService.deleteRecurringTemplate(template.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recurring expense deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
