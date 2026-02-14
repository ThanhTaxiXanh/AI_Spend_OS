import 'package:equatable/equatable.dart';

/// Budget entity representing spending limits for categories
class Budget extends Equatable {
  final String id;
  final String category;
  final double limit;
  final String period; // monthly, weekly, daily, custom
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final double alertThreshold; // percentage
  final bool enablePredictiveAlerts;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Budget({
    required this.id,
    required this.category,
    required this.limit,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.alertThreshold = 0.8,
    this.enablePredictiveAlerts = true,
    required this.createdAt,
    this.updatedAt,
  });

  Budget copyWith({
    String? id,
    String? category,
    double? limit,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    double? alertThreshold,
    bool? enablePredictiveAlerts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      enablePredictiveAlerts: enablePredictiveAlerts ?? this.enablePredictiveAlerts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    category,
    limit,
    period,
    startDate,
    endDate,
    isActive,
    alertThreshold,
    enablePredictiveAlerts,
    createdAt,
    updatedAt,
  ];
}
