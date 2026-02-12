import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String colorHex;

  @HiveField(3)
  final String iconName;

  @HiveField(4)
  final bool isDefault;

  @HiveField(5)
  final double totalSpent;

  @HiveField(6)
  final int transactionCount;

  Category({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.iconName,
    this.isDefault = false,
    this.totalSpent = 0.0,
    this.transactionCount = 0,
  });

  // Get Flutter Color from hex
  Color get color {
    return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  }

  // Get IconData
  IconData get icon {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'movie':
        return Icons.movie;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'category':
      default:
        return Icons.category;
    }
  }

  // Format total spent
  String get formattedTotal {
    return '\$${totalSpent.toStringAsFixed(2)}';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
      'iconName': iconName,
      'isDefault': isDefault,
      'totalSpent': totalSpent,
      'transactionCount': transactionCount,
    };
  }

  // Create from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      colorHex: json['colorHex'] as String,
      iconName: json['iconName'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transactionCount'] as int? ?? 0,
    );
  }

  // Copy with
  Category copyWith({
    String? id,
    String? name,
    String? colorHex,
    String? iconName,
    bool? isDefault,
    double? totalSpent,
    int? transactionCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      isDefault: isDefault ?? this.isDefault,
      totalSpent: totalSpent ?? this.totalSpent,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }
}
