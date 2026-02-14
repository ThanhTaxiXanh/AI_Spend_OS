import 'package:equatable/equatable.dart';

/// KeywordWeight entity for reinforcement learning in categorization
class KeywordWeight extends Equatable {
  final String id;
  final String keyword;
  final String category;
  final double weight;
  final int occurrenceCount;
  final DateTime lastUsed;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? context; // Time of day, weekday, etc.

  const KeywordWeight({
    required this.id,
    required this.keyword,
    required this.category,
    required this.weight,
    required this.occurrenceCount,
    required this.lastUsed,
    required this.createdAt,
    this.updatedAt,
    this.context,
  });

  KeywordWeight copyWith({
    String? id,
    String? keyword,
    String? category,
    double? weight,
    int? occurrenceCount,
    DateTime? lastUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? context,
  }) {
    return KeywordWeight(
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      category: category ?? this.category,
      weight: weight ?? this.weight,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      lastUsed: lastUsed ?? this.lastUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      context: context ?? this.context,
    );
  }

  @override
  List<Object?> get props => [
    id,
    keyword,
    category,
    weight,
    occurrenceCount,
    lastUsed,
    createdAt,
    updatedAt,
    context,
  ];
}
