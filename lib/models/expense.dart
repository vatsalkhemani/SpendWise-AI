import 'package:intl/intl.dart';

class Expense {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String description;
  final String? person;
  final DateTime date;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    this.person,
    required this.date,
    required this.createdAt,
  });

  // Format amount as currency
  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Format date
  String get formattedDate {
    return DateFormat('MMM d, yyyy').format(date);
  }

  // Format time
  String get formattedTime {
    return DateFormat('h:mm a').format(createdAt);
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'category': category,
      'description': description,
      'person': person,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String,
      person: json['person'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Copy with
  Expense copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    String? description,
    String? person,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      person: person ?? this.person,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
