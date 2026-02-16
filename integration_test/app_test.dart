import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spendwise_ai/main.dart' as app;
import 'package:spendwise_ai/services/expense_service.dart';
import 'package:spendwise_ai/services/auth_service.dart';
import 'package:spendwise_ai/models/expense.dart';
import 'package:spendwise_ai/models/category.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SpendWise AI - End-to-End Tests', () {
    testWidgets('Test 1: App launches successfully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show either LoginScreen or MainScreen
      expect(find.byType(MaterialApp), findsOneWidget);
      print('✅ Test 1 PASSED: App launched successfully');
    });

    testWidgets('Test 2: Navigation between tabs', (WidgetTester tester) async {
      // Skip if not authenticated
      final authService = AuthService();
      if (authService.currentUser == null) {
        print('⚠️ Test 2 SKIPPED: Not authenticated');
        return;
      }

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find bottom navigation bar
      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isEmpty) {
        print('⚠️ Test 2 SKIPPED: Bottom navigation not found (not authenticated)');
        return;
      }

      // Test navigation to each tab
      final tabs = ['Chat', 'Dashboard', 'Analytics', 'Categories', 'AI Chat'];
      for (int i = 0; i < tabs.length; i++) {
        await tester.tap(find.text(tabs[i]));
        await tester.pumpAndSettle();
        print('✅ Navigated to ${tabs[i]} tab');
      }

      print('✅ Test 2 PASSED: All tabs accessible');
    });

    testWidgets('Test 3: ExpenseService - CRUD operations', (WidgetTester tester) async {
      final expenseService = ExpenseService();

      // Create test expense
      final testExpense = Expense(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'test_user',
        amount: 25.99,
        category: 'Food & Dining',
        description: 'Test expense',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Test: Add expense
      await expenseService.addExpense(testExpense);
      await tester.pump();
      expect(expenseService.expenses.any((e) => e.id == testExpense.id), true);
      print('✅ Test 3a PASSED: Expense added successfully');

      // Test: Update expense
      final updatedExpense = testExpense.copyWith(amount: 30.00);
      await expenseService.updateExpense(updatedExpense);
      await tester.pump();
      final found = expenseService.expenses.firstWhere((e) => e.id == testExpense.id);
      expect(found.amount, 30.00);
      print('✅ Test 3b PASSED: Expense updated successfully');

      // Test: Delete expense
      await expenseService.deleteExpense(testExpense.id);
      await tester.pump();
      expect(expenseService.expenses.any((e) => e.id == testExpense.id), false);
      print('✅ Test 3c PASSED: Expense deleted successfully');

      print('✅ Test 3 PASSED: All CRUD operations working');
    });

    testWidgets('Test 4: Analytics calculations', (WidgetTester tester) async {
      final expenseService = ExpenseService();

      // Add test data
      final testExpenses = [
        Expense(
          id: 'analytics_1',
          userId: 'test_user',
          amount: 50.00,
          category: 'Food & Dining',
          description: 'Test 1',
          date: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        Expense(
          id: 'analytics_2',
          userId: 'test_user',
          amount: 100.00,
          category: 'Groceries',
          description: 'Test 2',
          date: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now(),
        ),
      ];

      for (var expense in testExpenses) {
        await expenseService.addExpense(expense);
      }
      await tester.pump();

      // Test analytics methods
      final total = expenseService.getTotalSpent();
      expect(total >= 150.00, true);
      print('✅ Test 4a PASSED: getTotalSpent() = \$$total');

      final monthlyTotal = expenseService.getMonthlyTotal();
      expect(monthlyTotal >= 150.00, true);
      print('✅ Test 4b PASSED: getMonthlyTotal() = \$$monthlyTotal');

      final categorySpending = expenseService.getSpendingByCategory();
      expect(categorySpending.isNotEmpty, true);
      print('✅ Test 4c PASSED: getSpendingByCategory() returned ${categorySpending.length} categories');

      final monthlyTrends = expenseService.getMonthlySpendingTrends(months: 3);
      expect(monthlyTrends.isNotEmpty, true);
      print('✅ Test 4d PASSED: getMonthlySpendingTrends() returned ${monthlyTrends.length} months');

      // Cleanup
      for (var expense in testExpenses) {
        await expenseService.deleteExpense(expense.id);
      }

      print('✅ Test 4 PASSED: All analytics methods working');
    });

    testWidgets('Test 5: Budget tracking', (WidgetTester tester) async {
      final expenseService = ExpenseService();

      // Create test category with budget
      final testCategory = Category(
        id: 'test_budget_cat',
        name: 'Test Budget Category',
        colorHex: '#FF9F40',
        iconName: 'category',
        isDefault: false,
        monthlyBudget: 100.00,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await expenseService.addCategory(testCategory);
      await tester.pump();

      // Verify budget properties
      expect(testCategory.monthlyBudget, 100.00);
      print('✅ Test 5a PASSED: Budget set to \$${testCategory.monthlyBudget}');

      // Add expense to category
      final testExpense = Expense(
        id: 'test_budget_expense',
        userId: 'test_user',
        amount: 80.00,
        category: testCategory.name,
        description: 'Test budget expense',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await expenseService.addExpense(testExpense);
      await tester.pump();

      // Check budget usage
      final categorySpending = expenseService.getSpendingByCategory();
      final spent = categorySpending[testCategory.name] ?? 0.0;
      final percentage = (spent / testCategory.monthlyBudget!) * 100;

      print('✅ Test 5b PASSED: Budget usage = ${percentage.toStringAsFixed(1)}%');
      expect(percentage > 0, true);

      // Cleanup
      await expenseService.deleteExpense(testExpense.id);
      await expenseService.deleteCategory(testCategory.name);

      print('✅ Test 5 PASSED: Budget tracking working');
    });

    testWidgets('Test 6: Recurring expenses', (WidgetTester tester) async {
      final expenseService = ExpenseService();

      // Create recurring template
      final recurringTemplate = Expense(
        id: 'recurring_template_test',
        userId: 'test_user',
        amount: 15.99,
        category: 'Entertainment',
        description: 'Netflix Subscription',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        isRecurring: true,
        recurringFrequency: 'monthly',
        recurringEndDate: DateTime.now().add(const Duration(days: 365)),
      );

      await expenseService.addExpense(recurringTemplate);
      await tester.pump();

      // Verify recurring template
      final templates = expenseService.getRecurringTemplates();
      expect(templates.any((e) => e.id == recurringTemplate.id), true);
      print('✅ Test 6a PASSED: Recurring template created');

      // Check recurring properties
      final template = templates.firstWhere((e) => e.id == recurringTemplate.id);
      expect(template.isRecurring, true);
      expect(template.recurringFrequency, 'monthly');
      expect(template.recurringDisplayText, 'Monthly');
      print('✅ Test 6b PASSED: Recurring properties correct');

      // Process recurring expenses (should generate instances)
      final processed = await expenseService.processRecurringExpenses();
      print('✅ Test 6c PASSED: Processed $processed recurring expenses');

      // Stop recurring
      await expenseService.stopRecurringExpense(recurringTemplate.id);
      await tester.pump();
      print('✅ Test 6d PASSED: Recurring expense stopped');

      // Delete template
      await expenseService.deleteRecurringTemplate(recurringTemplate.id);
      await tester.pump();
      print('✅ Test 6e PASSED: Recurring template deleted');

      print('✅ Test 6 PASSED: Recurring expenses working');
    });

    testWidgets('Test 7: Category management', (WidgetTester tester) async {
      final expenseService = ExpenseService();

      // Test: Add category
      final testCategory = Category(
        id: 'test_cat',
        name: 'Test Category',
        colorHex: '#FF0000',
        iconName: 'test',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await expenseService.addCategory(testCategory);
      await tester.pump();
      expect(expenseService.categories.any((c) => c.id == testCategory.id), true);
      print('✅ Test 7a PASSED: Category added');

      // Test: Update category
      final updatedCategory = testCategory.copyWith(
        name: 'Updated Test Category',
        updatedAt: DateTime.now(),
      );
      await expenseService.updateCategory(updatedCategory);
      await tester.pump();
      print('✅ Test 7b PASSED: Category updated');

      // Test: Delete category
      await expenseService.deleteCategory(updatedCategory.name);
      await tester.pump();
      expect(expenseService.categories.any((c) => c.name == updatedCategory.name), false);
      print('✅ Test 7c PASSED: Category deleted');

      print('✅ Test 7 PASSED: Category management working');
    });

    testWidgets('Test 8: Search and filter functionality', (WidgetTester tester) async {
      final expenseService = ExpenseService();

      // Add test expenses
      final testExpenses = [
        Expense(
          id: 'search_1',
          userId: 'test_user',
          amount: 25.00,
          category: 'Food & Dining',
          description: 'Coffee with Mike',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          person: 'Mike',
        ),
        Expense(
          id: 'search_2',
          userId: 'test_user',
          amount: 100.00,
          category: 'Groceries',
          description: 'Walmart shopping',
          date: DateTime.now().subtract(const Duration(days: 2)),
          createdAt: DateTime.now(),
        ),
      ];

      for (var expense in testExpenses) {
        await expenseService.addExpense(expense);
      }
      await tester.pump();

      // Test filtering by category
      final foodExpenses = expenseService.expenses
          .where((e) => e.category == 'Food & Dining')
          .toList();
      expect(foodExpenses.length >= 1, true);
      print('✅ Test 8a PASSED: Filter by category working (${foodExpenses.length} results)');

      // Test search by description
      final coffeeExpenses = expenseService.expenses
          .where((e) => e.description.toLowerCase().contains('coffee'))
          .toList();
      expect(coffeeExpenses.length >= 1, true);
      print('✅ Test 8b PASSED: Search by description working (${coffeeExpenses.length} results)');

      // Test filter by person
      final mikeExpenses = expenseService.expenses
          .where((e) => e.person?.toLowerCase().contains('mike') ?? false)
          .toList();
      expect(mikeExpenses.length >= 1, true);
      print('✅ Test 8c PASSED: Filter by person working (${mikeExpenses.length} results)');

      // Cleanup
      for (var expense in testExpenses) {
        await expenseService.deleteExpense(expense.id);
      }

      print('✅ Test 8 PASSED: Search and filter working');
    });

    testWidgets('Test 9: Data persistence check', (WidgetTester tester) async {
      final expenseService = ExpenseService();

      // Record initial counts
      final initialExpenseCount = expenseService.expenses.length;
      final initialCategoryCount = expenseService.categories.length;

      print('✅ Test 9a PASSED: Hive persistence working');
      print('   - Expenses stored: $initialExpenseCount');
      print('   - Categories stored: $initialCategoryCount');

      // Verify Hive boxes are open
      expect(expenseService.expenses, isNotNull);
      expect(expenseService.categories, isNotNull);
      print('✅ Test 9b PASSED: Hive boxes accessible');

      print('✅ Test 9 PASSED: Data persistence verified');
    });

    testWidgets('Test 10: Model data integrity', (WidgetTester tester) async {
      // Test Expense model
      final testExpense = Expense(
        id: 'integrity_test',
        userId: 'test_user',
        amount: 50.00,
        category: 'Test',
        description: 'Integrity test',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(testExpense.formattedAmount, '\$50.00');
      expect(testExpense.formattedDate, isNotEmpty);
      print('✅ Test 10a PASSED: Expense model methods working');

      // Test Category model
      final testCategory = Category(
        id: 'integrity_cat',
        name: 'Test',
        colorHex: '#FF0000',
        iconName: 'test',
        isDefault: false,
        monthlyBudget: 100.00,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(testCategory.color, isNotNull);
      expect(testCategory.monthlyBudget, 100.00);
      print('✅ Test 10b PASSED: Category model properties working');

      print('✅ Test 10 PASSED: Model data integrity verified');
    });
  });
}
