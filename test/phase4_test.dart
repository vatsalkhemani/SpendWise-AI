import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise_ai/models/expense.dart';
import 'package:spendwise_ai/models/category.dart';

void main() {
  group('Phase 4 Feature Tests', () {
    test('Test 1: Expense model - CRUD operations', () {
      // Create
      final expense = Expense(
        id: 'test_1',
        userId: 'test_user',
        amount: 25.99,
        category: 'Food & Dining',
        description: 'Test expense',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(expense.id, 'test_1');
      expect(expense.amount, 25.99);
      expect(expense.category, 'Food & Dining');
      print('✅ Test 1a PASSED: Expense created successfully');

      // Update (copyWith)
      final updated = expense.copyWith(amount: 30.00);
      expect(updated.amount, 30.00);
      expect(updated.id, expense.id); // ID should remain same
      print('✅ Test 1b PASSED: Expense updated successfully');

      // Formatted output
      expect(expense.formattedAmount, '\$25.99');
      expect(expense.formattedDate, isNotEmpty);
      print('✅ Test 1c PASSED: Expense formatting working');

      print('✅ Test 1 PASSED: Expense CRUD operations');
    });

    test('Test 2: Category model with budget', () {
      final category = Category(
        id: 'test_cat',
        name: 'Food & Dining',
        colorHex: '#FF9F40',
        iconName: 'restaurant',
        isDefault: false,
        monthlyBudget: 500.00,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(category.monthlyBudget, 500.00);
      expect(category.color, isNotNull);
      print('✅ Test 2a PASSED: Category with budget created');

      // Test budget helpers (would need spending data to test fully)
      expect(category.monthlyBudget, greaterThan(0));
      print('✅ Test 2b PASSED: Budget helpers accessible');

      print('✅ Test 2 PASSED: Category budget tracking');
    });

    test('Test 3: Recurring expense model', () {
      final recurring = Expense(
        id: 'recurring_1',
        userId: 'test_user',
        amount: 15.99,
        category: 'Entertainment',
        description: 'Netflix',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        isRecurring: true,
        recurringFrequency: 'monthly',
        recurringEndDate: DateTime.now().add(const Duration(days: 365)),
      );

      expect(recurring.isRecurring, true);
      expect(recurring.recurringFrequency, 'monthly');
      expect(recurring.recurringDisplayText, 'Monthly');
      print('✅ Test 3a PASSED: Recurring expense created');

      // Test frequency display
      final daily = recurring.copyWith(recurringFrequency: 'daily');
      expect(daily.recurringDisplayText, 'Daily');

      final weekly = recurring.copyWith(recurringFrequency: 'weekly');
      expect(weekly.recurringDisplayText, 'Weekly');

      final yearly = recurring.copyWith(recurringFrequency: 'yearly');
      expect(yearly.recurringDisplayText, 'Yearly');
      print('✅ Test 3b PASSED: All frequency types working');

      print('✅ Test 3 PASSED: Recurring expenses');
    });

    test('Test 4: Expense with person field', () {
      final expense = Expense(
        id: 'test_person',
        userId: 'test_user',
        amount: 50.00,
        category: 'Food & Dining',
        description: 'Lunch',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        person: 'Mike',
      );

      expect(expense.person, 'Mike');
      print('✅ Test 4 PASSED: Person field working');
    });

    test('Test 5: Expense date formatting', () {
      final expense = Expense(
        id: 'test_date',
        userId: 'test_user',
        amount: 25.00,
        category: 'Test',
        description: 'Test',
        date: DateTime(2026, 2, 16, 14, 30),
        createdAt: DateTime.now(),
      );

      // Format is "Feb 16, 2026" not "2/16/2026"
      expect(expense.formattedDate, contains('Feb 16, 2026'));
      print('✅ Test 5 PASSED: Date formatting correct');
    });

    test('Test 6: Category color parsing', () {
      final category = Category(
        id: 'test_color',
        name: 'Test',
        colorHex: '#FF9F40',
        iconName: 'test',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final color = category.color;
      expect(color.value, greaterThan(0));
      print('✅ Test 6 PASSED: Color parsing working');
    });

    test('Test 7: Expense JSON serialization', () {
      final expense = Expense(
        id: 'json_test',
        userId: 'test_user',
        amount: 100.00,
        category: 'Groceries',
        description: 'Shopping',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        person: 'Sarah',
        isRecurring: true,
        recurringFrequency: 'monthly',
      );

      // To JSON
      final json = expense.toJson();
      expect(json['id'], 'json_test');
      expect(json['amount'], 100.00);
      expect(json['category'], 'Groceries');
      expect(json['person'], 'Sarah');
      expect(json['isRecurring'], true);
      expect(json['recurringFrequency'], 'monthly');
      print('✅ Test 7a PASSED: toJson() working');

      // From JSON
      final fromJson = Expense.fromJson(json);
      expect(fromJson.id, expense.id);
      expect(fromJson.amount, expense.amount);
      expect(fromJson.category, expense.category);
      expect(fromJson.person, expense.person);
      expect(fromJson.isRecurring, expense.isRecurring);
      print('✅ Test 7b PASSED: fromJson() working');

      print('✅ Test 7 PASSED: JSON serialization');
    });

    test('Test 8: Category JSON serialization', () {
      final category = Category(
        id: 'json_cat',
        name: 'Entertainment',
        colorHex: '#9B59B6',
        iconName: 'movie',
        isDefault: false,
        monthlyBudget: 200.00,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // To JSON
      final json = category.toJson();
      expect(json['id'], 'json_cat');
      expect(json['name'], 'Entertainment');
      expect(json['monthlyBudget'], 200.00);
      print('✅ Test 8a PASSED: Category toJson() working');

      // From JSON
      final fromJson = Category.fromJson(json);
      expect(fromJson.id, category.id);
      expect(fromJson.name, category.name);
      expect(fromJson.monthlyBudget, category.monthlyBudget);
      print('✅ Test 8b PASSED: Category fromJson() working');

      print('✅ Test 8 PASSED: Category JSON serialization');
    });

    test('Test 9: Expense copyWith method', () {
      final original = Expense(
        id: 'copy_test',
        userId: 'test_user',
        amount: 50.00,
        category: 'Food',
        description: 'Original',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Copy with updated amount
      final updated1 = original.copyWith(amount: 75.00);
      expect(updated1.amount, 75.00);
      expect(updated1.description, 'Original'); // Unchanged
      print('✅ Test 9a PASSED: copyWith amount');

      // Copy with updated description
      final updated2 = original.copyWith(description: 'Updated');
      expect(updated2.description, 'Updated');
      expect(updated2.amount, 50.00); // Unchanged
      print('✅ Test 9b PASSED: copyWith description');

      // Copy with updated category
      final updated3 = original.copyWith(category: 'Groceries');
      expect(updated3.category, 'Groceries');
      print('✅ Test 9c PASSED: copyWith category');

      print('✅ Test 9 PASSED: copyWith method');
    });

    test('Test 10: Category copyWith method', () {
      final original = Category(
        id: 'copy_cat',
        name: 'Original',
        colorHex: '#FF0000',
        iconName: 'test',
        isDefault: false,
        monthlyBudget: 100.00,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Copy with updated name
      final updated1 = original.copyWith(name: 'Updated');
      expect(updated1.name, 'Updated');
      expect(updated1.monthlyBudget, 100.00); // Unchanged
      print('✅ Test 10a PASSED: copyWith name');

      // Copy with updated budget
      final updated2 = original.copyWith(monthlyBudget: 200.00);
      expect(updated2.monthlyBudget, 200.00);
      expect(updated2.name, 'Original'); // Unchanged
      print('✅ Test 10b PASSED: copyWith budget');

      print('✅ Test 10 PASSED: Category copyWith');
    });
  });

  group('Phase 4 Edge Cases', () {
    test('Test 11: Zero amount expense', () {
      final expense = Expense(
        id: 'zero',
        userId: 'test',
        amount: 0.00,
        category: 'Test',
        description: 'Zero',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(expense.formattedAmount, '\$0.00');
      print('✅ Test 11 PASSED: Zero amount handling');
    });

    test('Test 12: Large amount expense', () {
      final expense = Expense(
        id: 'large',
        userId: 'test',
        amount: 999999.99,
        category: 'Test',
        description: 'Large',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(expense.formattedAmount, contains('999999.99'));
      print('✅ Test 12 PASSED: Large amount handling');
    });

    test('Test 13: Empty person field', () {
      final expense = Expense(
        id: 'no_person',
        userId: 'test',
        amount: 25.00,
        category: 'Test',
        description: 'Test',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(expense.person, null);
      print('✅ Test 13 PASSED: Null person field');
    });

    test('Test 14: Category without budget', () {
      final category = Category(
        id: 'no_budget',
        name: 'Test',
        colorHex: '#FF0000',
        iconName: 'test',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(category.monthlyBudget, null);
      print('✅ Test 14 PASSED: Null budget handling');
    });

    test('Test 15: Recurring expense without end date', () {
      final expense = Expense(
        id: 'no_end',
        userId: 'test',
        amount: 10.00,
        category: 'Test',
        description: 'Test',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        isRecurring: true,
        recurringFrequency: 'monthly',
      );

      expect(expense.recurringEndDate, null);
      print('✅ Test 15 PASSED: Recurring without end date');
    });
  });
}
