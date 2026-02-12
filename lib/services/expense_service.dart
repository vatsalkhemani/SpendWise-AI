import 'dart:async';
import 'package:hive/hive.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../config/config.dart';

/// Central expense management service
/// Manages expenses with Hive persistence and provides streams for reactive updates
class ExpenseService {
  // Singleton instance
  static final ExpenseService _instance = ExpenseService._internal();
  factory ExpenseService() => _instance;
  ExpenseService._internal();

  // Hive boxes
  late Box<Expense> _expensesBox;
  late Box<Category> _categoriesBox;

  // Stream controllers for reactive updates
  final _expensesController = StreamController<List<Expense>>.broadcast();
  final _categoriesController = StreamController<List<Category>>.broadcast();

  // Getters
  List<Expense> get expenses => _expensesBox.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  List<Category> get categories => _categoriesBox.values.toList();

  Stream<List<Expense>> get expensesStream => _expensesController.stream;
  Stream<List<Category>> get categoriesStream => _categoriesController.stream;

  // Initialize with default categories
  Future<void> init() async {
    // Get boxes
    _expensesBox = Hive.box<Expense>('expenses');
    _categoriesBox = Hive.box<Category>('categories');

    // Initialize with default categories if empty
    if (_categoriesBox.isEmpty) {
      for (var cat in DefaultCategories.categories) {
        final category = Category(
          id: cat['name'] as String,
          name: cat['name'] as String,
          colorHex: cat['color'] as String,
          iconName: cat['icon'] as String,
          isDefault: true,
        );
        await _categoriesBox.put(category.id, category);
      }
    }

    // Send initial data to streams
    _expensesController.add(expenses);
    _categoriesController.add(categories);
  }

  // Expense operations
  Future<void> addExpense(Expense expense) async {
    await _expensesBox.put(expense.id, expense);
    _expensesController.add(expenses);
  }

  Future<void> updateExpense(Expense expense) async {
    await _expensesBox.put(expense.id, expense);
    _expensesController.add(expenses);
  }

  Future<void> deleteExpense(String expenseId) async {
    await _expensesBox.delete(expenseId);
    _expensesController.add(expenses);
  }

  // Category operations
  Future<void> addCategory(Category category) async {
    await _categoriesBox.put(category.id, category);
    _categoriesController.add(categories);
  }

  Future<void> updateCategory(Category category) async {
    await _categoriesBox.put(category.id, category);
    _categoriesController.add(categories);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoriesBox.delete(categoryId);
    _categoriesController.add(categories);
  }

  // Analytics
  double getTotalSpent({DateTime? startDate, DateTime? endDate}) {
    var filtered = expenses;

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
    var filtered = expenses;

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
    var filtered = expenses;

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
    for (var expense in expenses) {
      counts[expense.category] = (counts[expense.category] ?? 0) + 1;
    }
    return counts;
  }

  List<Expense> getExpensesByCategory(String category) {
    return expenses.where((e) => e.category == category).toList();
  }

  List<Expense> getRecentExpenses({int limit = 10}) {
    return expenses.take(limit).toList();
  }

  // Get data for AI insights
  Map<String, dynamic> getExpenseDataForAI() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final allExpenses = expenses;

    return {
      'totalSpent': getTotalSpent(),
      'monthlyTotal': getMonthlyTotal(),
      'transactionCount': allExpenses.length,
      'monthlyTransactionCount': getMonthlyTransactionCount(),
      'averageTransaction': allExpenses.isEmpty ? 0.0 : getTotalSpent() / allExpenses.length,
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
