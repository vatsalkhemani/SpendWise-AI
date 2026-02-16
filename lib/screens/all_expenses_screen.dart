import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import '../utils/animations.dart';

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  DateTimeRange? _dateRange;
  double? _minAmount;
  double? _maxAmount;

  List<Expense> _filterExpenses(List<Expense> expenses) {
    return expenses.where((expense) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesDescription = expense.description
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final matchesPerson = expense.person
                ?.toLowerCase()
                .contains(_searchQuery.toLowerCase()) ??
            false;
        if (!matchesDescription && !matchesPerson) return false;
      }

      // Category filter
      if (_selectedCategory != null && expense.category != _selectedCategory) {
        return false;
      }

      // Date range filter
      if (_dateRange != null) {
        if (expense.date.isBefore(_dateRange!.start) ||
            expense.date.isAfter(_dateRange!.end)) {
          return false;
        }
      }

      // Amount range filter
      if (_minAmount != null && expense.amount < _minAmount!) {
        return false;
      }
      if (_maxAmount != null && expense.amount > _maxAmount!) {
        return false;
      }

      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = null;
      _dateRange = null;
      _minAmount = null;
      _maxAmount = null;
    });
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCategory != null ||
      _dateRange != null ||
      _minAmount != null ||
      _maxAmount != null;

  @override
  Widget build(BuildContext context) {
    final expenseService = ExpenseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        centerTitle: true,
        actions: [
          if (_hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearFilters,
              tooltip: 'Clear Filters',
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Active filters chips
          if (_hasActiveFilters)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedCategory != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedCategory!),
                        onDeleted: () {
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                      ),
                    ),
                  if (_dateRange != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(
                          '${_dateRange!.start.month}/${_dateRange!.start.day} - ${_dateRange!.end.month}/${_dateRange!.end.day}',
                        ),
                        onDeleted: () {
                          setState(() {
                            _dateRange = null;
                          });
                        },
                      ),
                    ),
                  if (_minAmount != null || _maxAmount != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(
                          '\$${_minAmount?.toStringAsFixed(0) ?? '0'} - \$${_maxAmount?.toStringAsFixed(0) ?? '∞'}',
                        ),
                        onDeleted: () {
                          setState(() {
                            _minAmount = null;
                            _maxAmount = null;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),

          // Expenses list
          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: expenseService.expensesStream,
              builder: (context, snapshot) {
                final allExpenses = expenseService.expenses;
                final filteredExpenses = _filterExpenses(allExpenses);

                if (filteredExpenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          _hasActiveFilters
                              ? 'No expenses match your filters'
                              : 'No expenses yet',
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        if (_hasActiveFilters) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    return SlideUpAnimation(
                      delay: Duration(milliseconds: index * 50),
                      child: _buildExpenseTile(expense, context, expenseService),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(Expense expense, BuildContext context, ExpenseService expenseService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        expense.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (expense.isRecurring)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD60A).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.repeat, size: 12, color: Color(0xFFFFD60A)),
                            const SizedBox(width: 4),
                            Text(
                              expense.recurringDisplayText,
                              style: const TextStyle(
                                color: Color(0xFFFFD60A),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${expense.category} • ${expense.formattedDate}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (expense.person != null)
                  Text(
                    'with ${expense.person}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                if (expense.recurringTemplateId != null)
                  Text(
                    'From recurring expense',
                    style: TextStyle(
                      color: const Color(0xFFFFD60A).withOpacity(0.7),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            expense.formattedAmount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final expenseService = ExpenseService();
    final categories = expenseService.categories.map((c) => c.name).toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Expenses'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category filter
                const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    hintText: 'All Categories',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Categories')),
                    ...categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Date range filter
                const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: _dateRange,
                    );
                    if (picked != null) {
                      setDialogState(() {
                        _dateRange = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _dateRange == null
                        ? 'Select Date Range'
                        : '${_dateRange!.start.month}/${_dateRange!.start.day} - ${_dateRange!.end.month}/${_dateRange!.end.day}',
                  ),
                ),
                if (_dateRange != null)
                  TextButton(
                    onPressed: () {
                      setDialogState(() {
                        _dateRange = null;
                      });
                    },
                    child: const Text('Clear Date Range'),
                  ),
                const SizedBox(height: 16),

                // Amount range filter
                const Text('Amount Range', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Min',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        controller: TextEditingController(
                          text: _minAmount?.toStringAsFixed(0) ?? '',
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            _minAmount = double.tryParse(value);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Max',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        controller: TextEditingController(
                          text: _maxAmount?.toStringAsFixed(0) ?? '',
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            _maxAmount = double.tryParse(value);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  _selectedCategory = null;
                  _dateRange = null;
                  _minAmount = null;
                  _maxAmount = null;
                });
              },
              child: const Text('Clear All'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Trigger rebuild with new filters
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
