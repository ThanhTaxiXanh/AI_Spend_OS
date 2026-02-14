import 'package:equatable/equatable.dart';

/// Prediction entity for AI-generated spending predictions
class Prediction extends Equatable {
  final String id;
  final String category;
  final double predictedAmount;
  final double confidence;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double riskScore;
  final List<String> factors;
  final Map<String, dynamic> breakdown;
  final DateTime generatedAt;
  final bool isAccurate; // Will be updated post-period
  final double? actualAmount;

  const Prediction({
    required this.id,
    required this.category,
    required this.predictedAmount,
    required this.confidence,
    required this.periodStart,
    required this.periodEnd,
    required this.riskScore,
    required this.factors,
    required this.breakdown,
    required this.generatedAt,
    this.isAccurate = false,
    this.actualAmount,
  });

  Prediction copyWith({
    String? id,
    String? category,
    double? predictedAmount,
    double? confidence,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? riskScore,
    List<String>? factors,
    Map<String, dynamic>? breakdown,
    DateTime? generatedAt,
    bool? isAccurate,
    double? actualAmount,
  }) {
    return Prediction(
      id: id ?? this.id,
      category: category ?? this.category,
      predictedAmount: predictedAmount ?? this.predictedAmount,
      confidence: confidence ?? this.confidence,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      riskScore: riskScore ?? this.riskScore,
      factors: factors ?? this.factors,
      breakdown: breakdown ?? this.breakdown,
      generatedAt: generatedAt ?? this.generatedAt,
      isAccurate: isAccurate ?? this.isAccurate,
      actualAmount: actualAmount ?? this.actualAmount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    category,
    predictedAmount,
    confidence,
    periodStart,
    periodEnd,
    riskScore,
    factors,
    breakdown,
    generatedAt,
    isAccurate,
    actualAmount,
  ];
}
