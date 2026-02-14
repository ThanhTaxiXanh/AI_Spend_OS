import 'package:equatable/equatable.dart';

/// Core Transaction entity representing a financial transaction
class Transaction extends Equatable {
  final String id;
  final String type; // expense, income, transfer
  final double amount;
  final String category;
  final String? subcategory;
  final String description;
  final DateTime timestamp;
  final String? location;
  final String? notes;
  final bool isRecurring;
  final String? recurringPattern;
  final double confidence; // AI confidence score
  final bool isVerified; // User verified
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.subcategory,
    required this.description,
    required this.timestamp,
    this.location,
    this.notes,
    this.isRecurring = false,
    this.recurringPattern,
    this.confidence = 0.0,
    this.isVerified = false,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  Transaction copyWith({
    String? id,
    String? type,
    double? amount,
    String? category,
    String? subcategory,
    String? description,
    DateTime? timestamp,
    String? location,
    String? notes,
    bool? isRecurring,
    String? recurringPattern,
    double? confidence,
    bool? isVerified,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      confidence: confidence ?? this.confidence,
      isVerified: isVerified ?? this.isVerified,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    amount,
    category,
    subcategory,
    description,
    timestamp,
    location,
    notes,
    isRecurring,
    recurringPattern,
    confidence,
    isVerified,
    metadata,
    createdAt,
    updatedAt,
  ];
}
