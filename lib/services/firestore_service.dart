import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import '../models/category.dart';

/// Firestore cloud sync service
/// Handles all Firestore operations for expenses and categories
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference _expensesCollection(String userId) =>
      _db.collection('users').doc(userId).collection('expenses');

  CollectionReference _categoriesCollection(String userId) =>
      _db.collection('users').doc(userId).collection('categories');

  // ========== EXPENSE OPERATIONS ==========

  /// Add expense to Firestore
  Future<void> addExpense(Expense expense) async {
    try {
      await _expensesCollection(expense.userId)
          .doc(expense.id)
          .set(expense.toJson());
      print('✅ Synced expense to Firestore: ${expense.id}');
    } catch (e) {
      print('❌ Firestore addExpense error: $e');
      rethrow;
    }
  }

  /// Update expense in Firestore
  Future<void> updateExpense(Expense expense) async {
    try {
      // Update with new updatedAt timestamp
      final updatedExpense = expense.copyWith(updatedAt: DateTime.now());
      await _expensesCollection(expense.userId)
          .doc(expense.id)
          .update(updatedExpense.toJson());
      print('✅ Updated expense in Firestore: ${expense.id}');
    } catch (e) {
      print('❌ Firestore updateExpense error: $e');
      rethrow;
    }
  }

  /// Delete expense from Firestore
  Future<void> deleteExpense(String expenseId, String userId) async {
    try {
      await _expensesCollection(userId).doc(expenseId).delete();
      print('✅ Deleted expense from Firestore: $expenseId');
    } catch (e) {
      print('❌ Firestore deleteExpense error: $e');
      rethrow;
    }
  }

  /// Get all expenses for a user (one-time fetch)
  Future<List<Expense>> getExpenses(String userId) async {
    try {
      final snapshot = await _expensesCollection(userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Expense.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Firestore getExpenses error: $e');
      return [];
    }
  }

  /// Stream expenses for real-time updates
  Stream<List<Expense>> getExpensesStream(String userId) {
    return _expensesCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Expense.fromJson(data);
      }).toList();
    }).handleError((error) {
      print('❌ Firestore expenses stream error: $error');
      return <Expense>[];
    });
  }

  // ========== CATEGORY OPERATIONS ==========

  /// Add category to Firestore
  Future<void> addCategory(Category category, String userId) async {
    try {
      await _categoriesCollection(userId).doc(category.id).set(category.toJson());
      print('✅ Synced category to Firestore: ${category.id}');
    } catch (e) {
      print('❌ Firestore addCategory error: $e');
      rethrow;
    }
  }

  /// Update category in Firestore
  Future<void> updateCategory(Category category, String userId) async {
    try {
      // Update with new updatedAt timestamp
      final updatedCategory = category.copyWith(updatedAt: DateTime.now());
      await _categoriesCollection(userId)
          .doc(category.id)
          .update(updatedCategory.toJson());
      print('✅ Updated category in Firestore: ${category.id}');
    } catch (e) {
      print('❌ Firestore updateCategory error: $e');
      rethrow;
    }
  }

  /// Delete category from Firestore
  Future<void> deleteCategory(String categoryId, String userId) async {
    try {
      await _categoriesCollection(userId).doc(categoryId).delete();
      print('✅ Deleted category from Firestore: $categoryId');
    } catch (e) {
      print('❌ Firestore deleteCategory error: $e');
      rethrow;
    }
  }

  /// Get all categories for a user (one-time fetch)
  Future<List<Category>> getCategories(String userId) async {
    try {
      final snapshot = await _categoriesCollection(userId).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Category.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Firestore getCategories error: $e');
      return [];
    }
  }

  /// Stream categories for real-time updates
  Stream<List<Category>> getCategoriesStream(String userId) {
    return _categoriesCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Category.fromJson(data);
      }).toList();
    }).handleError((error) {
      print('❌ Firestore categories stream error: $error');
      return <Category>[];
    });
  }

  // ========== BATCH OPERATIONS ==========

  /// Batch add expenses (for migration)
  Future<void> batchAddExpenses(List<Expense> expenses, String userId) async {
    if (expenses.isEmpty) return;

    try {
      // Firestore batches are limited to 500 operations
      const batchSize = 500;
      for (var i = 0; i < expenses.length; i += batchSize) {
        final batch = _db.batch();
        final end = (i + batchSize < expenses.length) ? i + batchSize : expenses.length;
        final batchExpenses = expenses.sublist(i, end);

        for (var expense in batchExpenses) {
          final docRef = _expensesCollection(userId).doc(expense.id);
          batch.set(docRef, expense.toJson());
        }

        await batch.commit();
        print('✅ Batch synced ${batchExpenses.length} expenses ($i-$end)');
      }
    } catch (e) {
      print('❌ Firestore batchAddExpenses error: $e');
      rethrow;
    }
  }

  /// Batch add categories (for migration)
  Future<void> batchAddCategories(List<Category> categories, String userId) async {
    if (categories.isEmpty) return;

    try {
      final batch = _db.batch();

      for (var category in categories) {
        final docRef = _categoriesCollection(userId).doc(category.id);
        batch.set(docRef, category.toJson());
      }

      await batch.commit();
      print('✅ Batch synced ${categories.length} categories');
    } catch (e) {
      print('❌ Firestore batchAddCategories error: $e');
      rethrow;
    }
  }

  // ========== MIGRATION ==========

  /// Migrate Hive data to Firestore (one-time)
  Future<void> migrateHiveToFirestore(
    String userId,
    List<Expense> expenses,
    List<Category> categories,
  ) async {
    try {
      print('🔄 Starting Hive → Firestore migration...');

      // Check if already migrated (check if any data exists)
      final expensesSnapshot = await _expensesCollection(userId).limit(1).get();
      if (expensesSnapshot.docs.isNotEmpty) {
        print('⚠️ Firestore already has data, skipping migration');
        return;
      }

      // Batch upload expenses
      if (expenses.isNotEmpty) {
        await batchAddExpenses(expenses, userId);
      }

      // Batch upload categories
      if (categories.isNotEmpty) {
        await batchAddCategories(categories, userId);
      }

      print('✅ Migration complete: ${expenses.length} expenses, ${categories.length} categories');
    } catch (e) {
      print('❌ Migration error: $e');
      // Don't throw - allow app to continue even if migration fails
    }
  }

  // ========== CONFLICT RESOLUTION ==========

  /// Check if Firestore version is newer than local (for conflict resolution)
  Future<bool> isFirestoreNewer(Expense localExpense) async {
    try {
      final doc = await _expensesCollection(localExpense.userId)
          .doc(localExpense.id)
          .get();

      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final firestoreExpense = Expense.fromJson({...data, 'id': doc.id});

      return firestoreExpense.updatedAt.isAfter(localExpense.updatedAt);
    } catch (e) {
      print('❌ Error checking Firestore version: $e');
      return false;
    }
  }
}
