import 'dart:async';
import '../models/expense.dart';
import '../models/category.dart';
import '../config/config.dart';

/// Central expense management service
/// Manages expenses in-memory and provides streams for reactive updates
class ExpenseService {
  // Singleton instance
  static final ExpenseService _instance = ExpenseService._internal();
  factory ExpenseService() => _instance;
  ExpenseService._internal();

  // In-memory storage (will be replaced with Hive/Firestore later)
  final List<Expense> _expenses = [];
  final List<Category> _categories = [];

  // Stream controllers for reactive updates
  final _expensesController = StreamController<List<Expense>>.broadcast();
  final _categoriesController = StreamController<List<Category>>.broadcast();

  // Getters
  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<Category> get categories => List.unmodifiable(_categories);

  Stream<List<Expense>> get expensesStream => _expensesController.stream;
  Stream<List<Category>> get categoriesStream => _categoriesController.stream;

  // Initialize with default categories
  void init() {
    if (_categories.isEmpty) {
      _categories.addAll(
        DefaultCategories.categories.map((cat) {
          return Category(
            id: cat['name'] as String,
            name: cat['name'] as String,
            colorHex: cat['color'] as String,
            iconName: cat['icon'] as String,
            isDefault: true,
          );
        }),
      );
      _categoriesController.add(_categories);
    }
  }

  // Expense operations
  void addExpense(Expense expense) {
    _expenses.add(expense);
    _expenses.sort((a, b) => b.date.compareTo(a.date)); // Most recent first
    _expensesController.add(_expenses);
  }

  void updateExpense(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      _expenses.sort((a, b) => b.date.compareTo(a.date));
      _expensesController.add(_expenses);
    }
  }

  void deleteExpense(String expenseId) {
    _expenses.removeWhere((e) => e.id == expenseId);
    _expensesController.add(_expenses);
  }

  // Category operations
  void addCategory(Category category) {
    _categories.add(category);
    _categoriesController.add(_categories);
  }

  void updateCategory(Category category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      _categoriesController.add(_categories);
    }
  }

  void deleteCategory(String categoryId) {
    _categories.removeWhere((c) => c.id == categoryId);
    _categoriesController.add(_categories);
  }

  // Analytics
  double getTotalSpent({DateTime? startDate, DateTime? endDate}) {
    var filtered = _expenses;

    if (startDate != null) {
      filtered = filtered.where((e) => e.date.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      filtered = filtered.where((e) => e.date.isBefore(endDate)).toList();
    }

    return filtered.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double getMonthlyTotal() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getTotalSpent(startDate: startOfMonth, endDate: endOfMonth);
  }

  int getTransactionCount({DateTime? startDate, DateTime? endDate}) {
    var filtered = _expenses;

    if (startDate != null) {
      filtered = filtered.where((e) => e.date.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      filtered = filtered.where((e) => e.date.isBefore(endDate)).toList();
    }

    return filtered.length;
  }

  int getMonthlyTransactionCount() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getTransactionCount(startDate: startOfMonth, endDate: endOfMonth);
  }

  Map<String, double> getSpendingByCategory({DateTime? startDate, DateTime? endDate}) {
    var filtered = _expenses;

    if (startDate != null) {
      filtered = filtered.where((e) => e.date.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      filtered = filtered.where((e) => e.date.isBefore(endDate)).toList();
    }

    final Map<String, double> spending = {};
    for (var expense in filtered) {
      spending[expense.category] = (spending[expense.category] ?? 0.0) + expense.amount;
    }

    return spending;
  }

  Map<String, int> getCategoryTransactionCounts() {
    final Map<String, int> counts = {};
    for (var expense in _expenses) {
      counts[expense.category] = (counts[expense.category] ?? 0) + 1;
    }
    return counts;
  }

  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((e) => e.category == category).toList();
  }

  List<Expense> getRecentExpenses({int limit = 10}) {
    return _expenses.take(limit).toList();
  }

  // Get data for AI insights
  Map<String, dynamic> getExpenseDataForAI() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return {
      'totalSpent': getTotalSpent(),
      'monthlyTotal': getMonthlyTotal(),
      'transactionCount': _expenses.length,
      'monthlyTransactionCount': getMonthlyTransactionCount(),
      'averageTransaction': _expenses.isEmpty ? 0.0 : getTotalSpent() / _expenses.length,
      'spendingByCategory': getSpendingByCategory(startDate: startOfMonth),
      'categoryCounts': getCategoryTransactionCounts(),
      'recentExpenses': getRecentExpenses(limit: 5).map((e) => {
        'amount': e.amount,
        'category': e.category,
        'description': e.description,
        'date': e.formattedDate,
      }).toList(),
    };
  }

  // Cleanup
  void dispose() {
    _expensesController.close();
    _categoriesController.close();
  }
}
