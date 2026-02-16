import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String? person;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final bool isRecurring;

  @HiveField(10)
  final String? recurringFrequency; // 'daily', 'weekly', 'monthly', 'yearly'

  @HiveField(11)
  final DateTime? recurringEndDate;

  @HiveField(12)
  final String? recurringTemplateId; // Links recurring instances

  Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    this.person,
    required this.date,
    required this.createdAt,
    DateTime? updatedAt,
    this.isRecurring = false,
    this.recurringFrequency,
    this.recurringEndDate,
    this.recurringTemplateId,
  }) : updatedAt = updatedAt ?? createdAt;

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

  // Get recurring display text
  String get recurringDisplayText {
    if (!isRecurring || recurringFrequency == null) return '';
    switch (recurringFrequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'yearly':
        return 'Yearly';
      default:
        return '';
    }
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
      'updatedAt': updatedAt.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringFrequency': recurringFrequency,
      'recurringEndDate': recurringEndDate?.toIso8601String(),
      'recurringTemplateId': recurringTemplateId,
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
      updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : DateTime.parse(json['createdAt'] as String),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringFrequency: json['recurringFrequency'] as String?,
      recurringEndDate: json['recurringEndDate'] != null
          ? DateTime.parse(json['recurringEndDate'] as String)
          : null,
      recurringTemplateId: json['recurringTemplateId'] as String?,
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
    DateTime? updatedAt,
    bool? isRecurring,
    String? recurringFrequency,
    DateTime? recurringEndDate,
    String? recurringTemplateId,
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
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
      recurringTemplateId: recurringTemplateId ?? this.recurringTemplateId,
    );
  }
}
