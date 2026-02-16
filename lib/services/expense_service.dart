import 'dart:async';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../config/config.dart';
import 'firestore_service.dart';

/// Central expense management service
/// Manages expenses with Hive persistence and Firestore cloud sync
class ExpenseService {
  // Singleton instance
  static final ExpenseService _instance = ExpenseService._internal();
  factory ExpenseService() => _instance;
  ExpenseService._internal();

  // Hive boxes (user-specific)
  Box<Expense>? _expensesBox;
  Box<Category>? _categoriesBox;
  String? _currentUserId;

  // Firestore integration
  final _firestoreService = FirestoreService();
  bool _syncEnabled = false;
  StreamSubscription<List<Expense>>? _expensesSubscription;
  StreamSubscription<List<Category>>? _categoriesSubscription;

  // Stream controllers for reactive updates
  final _expensesController = StreamController<List<Expense>>.broadcast();
  final _categoriesController = StreamController<List<Category>>.broadcast();
  final _syncStatusController = StreamController<bool>.broadcast();

  // Getters
  List<Expense> get expenses {
    if (_expensesBox == null) return [];
    return _expensesBox!.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Category> get categories {
    if (_categoriesBox == null) return [];
    return _categoriesBox!.values.toList();
  }

  Stream<List<Expense>> get expensesStream => _expensesController.stream;
  Stream<List<Category>> get categoriesStream => _categoriesController.stream;
  Stream<bool> get syncStatusStream => _syncStatusController.stream;
  bool get isSyncEnabled => _syncEnabled;
  String? get currentUserId => _currentUserId;

  // Initialize for a specific user
  Future<void> initForUser(String userId) async {
    // Close existing boxes if switching users
    if (_currentUserId != null && _currentUserId != userId) {
      await signOut();
    }

    // Set current user
    _currentUserId = userId;

    // Box names are user-specific
    final expensesBoxName = 'expenses_$userId';
    final categoriesBoxName = 'categories_$userId';

    // Open user-specific boxes
    if (!Hive.isBoxOpen(expensesBoxName)) {
      _expensesBox = await Hive.openBox<Expense>(expensesBoxName);
    } else {
      _expensesBox = Hive.box<Expense>(expensesBoxName);
    }

    if (!Hive.isBoxOpen(categoriesBoxName)) {
      _categoriesBox = await Hive.openBox<Category>(categoriesBoxName);
    } else {
      _categoriesBox = Hive.box<Category>(categoriesBoxName);
    }

    // Initialize with default categories if empty
    if (_categoriesBox!.isEmpty) {
      for (var cat in DefaultCategories.categories) {
        final category = Category(
          id: cat['name'] as String,
          name: cat['name'] as String,
          colorHex: cat['color'] as String,
          iconName: cat['icon'] as String,
          isDefault: true,
        );
        await _categoriesBox!.put(category.id, category);
      }
    }

    // Send initial data to streams
    _expensesController.add(expenses);
    _categoriesController.add(categories);

    // Enable Firestore sync
    _syncEnabled = true;
    _listenToFirestore(userId);

    // Check if first time - migrate Hive → Firestore
    final prefs = await SharedPreferences.getInstance();
    final hasMigrated = prefs.getBool('migrated_firestore_$userId') ?? false;
    if (!hasMigrated) {
      await _migrateToFirestore(userId);
      await prefs.setBool('migrated_firestore_$userId', true);
    }

    // Process recurring expenses (check for due payments)
    processRecurringExpenses().then((created) {
      if (created > 0) {
        print('✅ Created $created recurring expense(s)');
      }
    });
  }

  /// Listen to Firestore streams for real-time updates
  void _listenToFirestore(String userId) {
    print('🔄 Starting Firestore listeners for user: $userId');

    // Listen to expenses stream
    _expensesSubscription?.cancel();
    _expensesSubscription = _firestoreService.getExpensesStream(userId).listen(
      (firestoreExpenses) {
        if (!_syncEnabled) return;

        print('📥 Received ${firestoreExpenses.length} expenses from Firestore');

        // Update Hive cache with Firestore data
        for (var expense in firestoreExpenses) {
          _expensesBox?.put(expense.id, expense);
        }

        // Notify listeners
        _expensesController.add(expenses);
        _syncStatusController.add(false); // Sync complete
      },
      onError: (error) {
        print('❌ Firestore expenses stream error: $error');
      },
    );

    // Listen to categories stream
    _categoriesSubscription?.cancel();
    _categoriesSubscription = _firestoreService.getCategoriesStream(userId).listen(
      (firestoreCategories) {
        if (!_syncEnabled) return;

        print('📥 Received ${firestoreCategories.length} categories from Firestore');

        // Update Hive cache with Firestore data
        for (var category in firestoreCategories) {
          _categoriesBox?.put(category.id, category);
        }

        // Notify listeners
        _categoriesController.add(categories);
      },
      onError: (error) {
        print('❌ Firestore categories stream error: $error');
      },
    );
  }

  /// Migrate local Hive data to Firestore (one-time)
  Future<void> _migrateToFirestore(String userId) async {
    try {
      print('🔄 Migrating local data to Firestore for user: $userId');

      final expenses = this.expenses;
      final categories = this.categories;

      if (expenses.isNotEmpty || categories.isNotEmpty) {
        _syncStatusController.add(true); // Syncing

        await _firestoreService.migrateHiveToFirestore(
          userId,
          expenses,
          categories,
        );

        print('✅ Migration complete: ${expenses.length} expenses, ${categories.length} categories');
        _syncStatusController.add(false); // Sync complete
      }
    } catch (e) {
      print('❌ Migration error: $e');
      _syncStatusController.add(false); // Sync failed
      // Don't throw - allow app to continue
    }
  }

  // Sign out and close boxes
  Future<void> signOut() async {
    // Disable Firestore sync
    _syncEnabled = false;
    _expensesSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _expensesSubscription = null;
    _categoriesSubscription = null;

    // Close boxes
    if (_expensesBox != null && _expensesBox!.isOpen) {
      await _expensesBox!.close();
    }
    if (_categoriesBox != null && _categoriesBox!.isOpen) {
      await _categoriesBox!.close();
    }

    // Clear references
    _expensesBox = null;
    _categoriesBox = null;
    _currentUserId = null;

    // Send empty data to streams
    _expensesController.add([]);
    _categoriesController.add([]);
    _syncStatusController.add(false);
  }

  // Migrate data from old 'user123' boxes to new user-specific boxes
  Future<void> migrateUser123Data(String newUserId) async {
    try {
      // Check if old boxes exist
      final oldExpensesBoxName = 'expenses';
      final oldCategoriesBoxName = 'categories';

      if (!Hive.isBoxOpen(oldExpensesBoxName) ||
          !Hive.isBoxOpen(oldCategoriesBoxName)) {
        // No old data to migrate
        return;
      }

      final oldExpensesBox = Hive.box<Expense>(oldExpensesBoxName);
      final oldCategoriesBox = Hive.box<Category>(oldCategoriesBoxName);

      // Skip if old boxes are empty
      if (oldExpensesBox.isEmpty && oldCategoriesBox.isEmpty) {
        return;
      }

      print('Migrating user123 data to $newUserId...');

      // Copy expenses and update userId
      for (var expense in oldExpensesBox.values) {
        final updatedExpense = Expense(
          id: expense.id,
          amount: expense.amount,
          category: expense.category,
          description: expense.description,
          date: expense.date,
          createdAt: expense.createdAt,
          userId: newUserId, // Update userId
          person: expense.person,
          updatedAt: expense.createdAt, // Use createdAt as updatedAt for old data
        );
        await _expensesBox?.put(updatedExpense.id, updatedExpense);
      }

      // Copy categories
      for (var category in oldCategoriesBox.values) {
        await _categoriesBox?.put(category.id, category);
      }

      print('Migration complete: ${oldExpensesBox.length} expenses, ${oldCategoriesBox.length} categories');

      // Clear old boxes (optional - keep for safety)
      // await oldExpensesBox.clear();
      // await oldCategoriesBox.clear();

      // Send updated data to streams
      _expensesController.add(expenses);
      _categoriesController.add(categories);
    } catch (e) {
      print('Migration error: $e');
      // Don't throw - migration failure shouldn't block sign-in
    }
  }

  // Expense operations
  Future<void> addExpense(Expense expense) async {
    if (_expensesBox == null) return;

    // Write to Hive first (instant UI update)
    await _expensesBox!.put(expense.id, expense);
    _expensesController.add(expenses);

    // Sync to Firestore in background
    if (_syncEnabled && _currentUserId != null) {
      _syncStatusController.add(true); // Syncing
      _firestoreService.addExpense(expense).then((_) {
        _syncStatusController.add(false); // Sync complete
      }).catchError((e) {
        print('❌ Firestore sync error: $e');
        _syncStatusController.add(false); // Sync failed
        // TODO: Queue for retry
      });
    }
  }

  Future<void> updateExpense(Expense expense) async {
    if (_expensesBox == null) return;

    // Update with new timestamp
    final updatedExpense = expense.copyWith(updatedAt: DateTime.now());

    // Update in Hive
    await _expensesBox!.put(updatedExpense.id, updatedExpense);
    _expensesController.add(expenses);

    // Sync to Firestore
    if (_syncEnabled && _currentUserId != null) {
      _syncStatusController.add(true); // Syncing
      _firestoreService.updateExpense(updatedExpense).then((_) {
        _syncStatusController.add(false); // Sync complete
      }).catchError((e) {
        print('❌ Firestore sync error: $e');
        _syncStatusController.add(false); // Sync failed
      });
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    if (_expensesBox == null) return;

    // Delete from Hive
    await _expensesBox!.delete(expenseId);
    _expensesController.add(expenses);

    // Delete from Firestore
    if (_syncEnabled && _currentUserId != null) {
      _syncStatusController.add(true); // Syncing
      _firestoreService.deleteExpense(expenseId, _currentUserId!).then((_) {
        _syncStatusController.add(false); // Sync complete
      }).catchError((e) {
        print('❌ Firestore sync error: $e');
        _syncStatusController.add(false); // Sync failed
      });
    }
  }

  // Category operations
  Future<void> addCategory(Category category) async {
    if (_categoriesBox == null) return;

    // Write to Hive first
    await _categoriesBox!.put(category.id, category);
    _categoriesController.add(categories);

    // Sync to Firestore
    if (_syncEnabled && _currentUserId != null) {
      _firestoreService.addCategory(category, _currentUserId!).catchError((e) {
        print('❌ Firestore category sync error: $e');
      });
    }
  }

  Future<void> updateCategory(Category category) async {
    if (_categoriesBox == null) return;

    // Update with new timestamp
    final updatedCategory = category.copyWith(updatedAt: DateTime.now());

    // Update in Hive
    await _categoriesBox!.put(updatedCategory.id, updatedCategory);
    _categoriesController.add(categories);

    // Sync to Firestore
    if (_syncEnabled && _currentUserId != null) {
      _firestoreService.updateCategory(updatedCategory, _currentUserId!).catchError((e) {
        print('❌ Firestore category sync error: $e');
      });
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    if (_categoriesBox == null) return;

    // Delete from Hive
    await _categoriesBox!.delete(categoryId);
    _categoriesController.add(categories);

    // Delete from Firestore
    if (_syncEnabled && _currentUserId != null) {
      _firestoreService.deleteCategory(categoryId, _currentUserId!).catchError((e) {
        print('❌ Firestore category sync error: $e');
      });
    }
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

  // Get monthly average spending
  double getMonthlyAverage() {
    if (expenses.isEmpty) return 0.0;

    // Group expenses by month
    final Map<String, double> monthlyTotals = {};
    for (var expense in expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0.0) + expense.amount;
    }

    if (monthlyTotals.isEmpty) return 0.0;

    final totalSpent = monthlyTotals.values.reduce((a, b) => a + b);
    return totalSpent / monthlyTotals.length;
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

  // Get monthly spending trends for last N months
  Map<String, double> getMonthlySpendingTrends({int months = 6}) {
    final Map<String, double> trends = {};
    final now = DateTime.now();

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      final monthKey = '${month.month}/${month.year}';

      final monthlyTotal = expenses
          .where((e) => e.date.isAfter(month) && e.date.isBefore(monthEnd))
          .fold<double>(0.0, (sum, e) => sum + e.amount);

      trends[monthKey] = monthlyTotal;
    }

    return trends;
  }

  // Get category spending trends over time
  Map<String, Map<String, double>> getCategorySpendingTrends({int months = 6}) {
    final Map<String, Map<String, double>> trends = {};
    final now = DateTime.now();

    // Initialize categories
    for (var category in categories) {
      trends[category.name] = {};
    }

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      final monthKey = '${month.month}/${month.year}';

      for (var category in categories) {
        final categoryTotal = expenses
            .where((e) =>
                e.category == category.name &&
                e.date.isAfter(month) &&
                e.date.isBefore(monthEnd))
            .fold<double>(0.0, (sum, e) => sum + e.amount);

        trends[category.name]![monthKey] = categoryTotal;
      }
    }

    return trends;
  }

  // Get spending comparison (this month vs last month)
  Map<String, double> getMonthComparison() {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);

    final thisMonthTotal = expenses
        .where((e) => e.date.isAfter(thisMonthStart))
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final lastMonthTotal = expenses
        .where((e) => e.date.isAfter(lastMonthStart) && e.date.isBefore(lastMonthEnd))
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final difference = thisMonthTotal - lastMonthTotal;
    final percentChange = lastMonthTotal > 0 ? (difference / lastMonthTotal) * 100 : 0.0;

    return {
      'thisMonth': thisMonthTotal,
      'lastMonth': lastMonthTotal,
      'difference': difference,
      'percentChange': percentChange,
    };
  }

  // ========== RECURRING EXPENSES ==========

  // Get all recurring expense templates
  List<Expense> getRecurringTemplates() {
    return expenses.where((e) => e.isRecurring && e.recurringTemplateId == null).toList();
  }

  // Get recurring expenses by template ID
  List<Expense> getRecurringInstances(String templateId) {
    return expenses.where((e) => e.recurringTemplateId == templateId).toList();
  }

  // Check and create due recurring expenses
  Future<int> processRecurringExpenses() async {
    int created = 0;
    final templates = getRecurringTemplates();
    final now = DateTime.now();

    for (final template in templates) {
      // Check if recurring end date has passed
      if (template.recurringEndDate != null &&
          now.isAfter(template.recurringEndDate!)) {
        continue;
      }

      // Get last instance of this recurring expense
      final instances = getRecurringInstances(template.id);
      final lastDate = instances.isEmpty
          ? template.date
          : instances.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b);

      // Calculate next due date
      final nextDate = _calculateNextRecurringDate(lastDate, template.recurringFrequency!);

      // Create if due
      if (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
        final newExpense = Expense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: template.userId,
          amount: template.amount,
          category: template.category,
          description: template.description,
          person: template.person,
          date: nextDate,
          createdAt: DateTime.now(),
          isRecurring: false, // Instances are not recurring themselves
          recurringTemplateId: template.id, // Link to template
        );

        await addExpense(newExpense);
        created++;
      }
    }

    return created;
  }

  // Calculate next recurring date
  DateTime _calculateNextRecurringDate(DateTime lastDate, String frequency) {
    switch (frequency) {
      case 'daily':
        return DateTime(lastDate.year, lastDate.month, lastDate.day + 1);
      case 'weekly':
        return DateTime(lastDate.year, lastDate.month, lastDate.day + 7);
      case 'monthly':
        return DateTime(lastDate.year, lastDate.month + 1, lastDate.day);
      case 'yearly':
        return DateTime(lastDate.year + 1, lastDate.month, lastDate.day);
      default:
        return lastDate;
    }
  }

  // Stop recurring expense (set end date to today)
  Future<void> stopRecurringExpense(String templateId) async {
    final template = expenses.firstWhere((e) => e.id == templateId);
    if (template.isRecurring) {
      final updated = template.copyWith(
        recurringEndDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await updateExpense(updated);
    }
  }

  // Update recurring template (affects future instances)
  Future<void> updateRecurringTemplate(Expense template) async {
    if (template.isRecurring) {
      await updateExpense(template);
    }
  }

  // Delete all instances of a recurring expense
  Future<void> deleteRecurringTemplate(String templateId) async {
    // Delete template
    await deleteExpense(templateId);

    // Delete all instances
    final instances = getRecurringInstances(templateId);
    for (final instance in instances) {
      await deleteExpense(instance.id);
    }
  }

  // Cleanup
  void dispose() {
    _expensesSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _expensesController.close();
    _categoriesController.close();
    _syncStatusController.close();
  }
}
