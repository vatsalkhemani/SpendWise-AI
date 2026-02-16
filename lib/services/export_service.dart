import 'dart:convert';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import '../models/expense.dart';

class ExportService {
  /// Export expenses to CSV
  static void exportToCSV(List<Expense> expenses, {String? filename}) {
    if (expenses.isEmpty) return;

    // Create CSV data
    final List<List<dynamic>> rows = [
      // Header row
      ['Date', 'Description', 'Category', 'Amount', 'Person'],
      // Data rows
      ...expenses.map((expense) => [
            expense.formattedDate,
            expense.description,
            expense.category,
            expense.amount.toStringAsFixed(2),
            expense.person ?? '',
          ]),
      // Summary row
      [],
      ['TOTAL', '', '', expenses.fold(0.0, (sum, e) => sum + e.amount).toStringAsFixed(2), ''],
    ];

    // Convert to CSV string
    final String csv = const ListToCsvConverter().convert(rows);

    // Download file
    _downloadFile(
      csv,
      filename ?? 'spendwise_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      'text/csv',
    );
  }

  /// Export expenses to formatted text report
  static void exportToTextReport(
    List<Expense> expenses,
    Map<String, double> categoryTotals, {
    String? filename,
  }) {
    if (expenses.isEmpty) return;

    final now = DateTime.now();
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final avgTransaction = totalSpent / expenses.length;

    // Create report
    final buffer = StringBuffer();
    buffer.writeln('SPENDWISE AI - EXPENSE REPORT');
    buffer.writeln('=' * 50);
    buffer.writeln('Generated: ${now.month}/${now.day}/${now.year} ${now.hour}:${now.minute}');
    buffer.writeln('');
    buffer.writeln('SUMMARY');
    buffer.writeln('-' * 50);
    buffer.writeln('Total Expenses: ${expenses.length}');
    buffer.writeln('Total Amount: \$${totalSpent.toStringAsFixed(2)}');
    buffer.writeln('Average Transaction: \$${avgTransaction.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('SPENDING BY CATEGORY');
    buffer.writeln('-' * 50);

    categoryTotals.forEach((category, amount) {
      final percentage = (amount / totalSpent * 100).toStringAsFixed(1);
      buffer.writeln('$category: \$${amount.toStringAsFixed(2)} ($percentage%)');
    });

    buffer.writeln('');
    buffer.writeln('DETAILED TRANSACTIONS');
    buffer.writeln('-' * 50);
    buffer.writeln('');

    // Sort by date
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final expense in sortedExpenses) {
      buffer.writeln('Date: ${expense.formattedDate}');
      buffer.writeln('Description: ${expense.description}');
      buffer.writeln('Category: ${expense.category}');
      buffer.writeln('Amount: ${expense.formattedAmount}');
      if (expense.person != null) {
        buffer.writeln('With: ${expense.person}');
      }
      buffer.writeln('-' * 30);
    }

    buffer.writeln('');
    buffer.writeln('End of Report');

    // Download file
    _downloadFile(
      buffer.toString(),
      filename ?? 'spendwise_report_${DateTime.now().millisecondsSinceEpoch}.txt',
      'text/plain',
    );
  }

  /// Download file in browser
  static void _downloadFile(String content, String filename, String mimeType) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  /// Export with date range
  static void exportWithDateRange(
    List<Expense> allExpenses,
    DateTime startDate,
    DateTime endDate,
    Map<String, double> categoryTotals,
  ) {
    final filtered = allExpenses.where((e) {
      return e.date.isAfter(startDate) && e.date.isBefore(endDate);
    }).toList();

    final filename = 'spendwise_${startDate.month}-${startDate.day}_to_${endDate.month}-${endDate.day}.csv';
    exportToCSV(filtered, filename: filename);
  }
}
