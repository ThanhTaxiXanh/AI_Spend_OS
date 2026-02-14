import 'dart:math';
import 'package:logger/logger.dart';
import '../../core/constants/app_constants.dart';
import '../../services/database/database_service.dart';
import '../../domain/entities/prediction.dart';
import 'package:uuid/uuid.dart';

/// Feature vector for ML prediction
class SpendingFeatures {
  final double avgDailySpending;
  final double avgWeeklySpending;
  final double avgMonthlySpending;
  final double trend; // Positive = increasing, negative = decreasing
  final double volatility;
  final int transactionCount;
  final Map<String, double> categoryDistribution;
  final double dayOfWeekPattern;
  final double seasonalFactor;

  SpendingFeatures({
    required this.avgDailySpending,
    required this.avgWeeklySpending,
    required this.avgMonthlySpending,
    required this.trend,
    required this.volatility,
    required this.transactionCount,
    required this.categoryDistribution,
    required this.dayOfWeekPattern,
    required this.seasonalFactor,
  });
}

/// AI Spending Pattern Predictor
/// Uses statistical methods and feature engineering for predictions
class SpendingPredictor {
  final DatabaseService _db;
  final Logger _logger = Logger();
  final _uuid = const Uuid();

  SpendingPredictor(this._db);

  /// Predict spending for next period
  Future<Prediction> predictSpending({
    String? category,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    try {
      _logger.i('Predicting spending for ${category ?? "all categories"}');
      
      // Extract features from historical data
      final features = await _extractFeatures(
        category: category,
        lookbackDays: AppConstants.historicalWindow,
      );
      
      // Generate prediction using multiple methods
      final movingAvgPrediction = _movingAveragePrediction(features);
      final trendPrediction = _trendBasedPrediction(features);
      final seasonalPrediction = _seasonalPrediction(features, periodStart);
      
      // Ensemble prediction (weighted average)
      final predictedAmount = (
        movingAvgPrediction * 0.4 +
        trendPrediction * 0.4 +
        seasonalPrediction * 0.2
      );
      
      // Calculate confidence
      final confidence = _calculatePredictionConfidence(features);
      
      // Calculate risk score
      final riskScore = await _calculateRiskScore(
        predictedAmount: predictedAmount,
        category: category,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
      
      // Identify contributing factors
      final factors = _identifyFactors(features, riskScore);
      
      // Create breakdown
      final breakdown = _createBreakdown(features, predictedAmount);
      
      final prediction = Prediction(
        id: _uuid.v4(),
        category: category ?? 'All',
        predictedAmount: predictedAmount,
        confidence: confidence,
        periodStart: periodStart,
        periodEnd: periodEnd,
        riskScore: riskScore,
        factors: factors,
        breakdown: breakdown,
        generatedAt: DateTime.now(),
      );
      
      // Cache prediction
      await _cachePrediction(prediction);
      
      return prediction;
    } catch (e) {
      _logger.e('Prediction failed: $e');
      rethrow;
    }
  }

  /// Extract features from historical transactions
  Future<SpendingFeatures> _extractFeatures({
    String? category,
    required int lookbackDays,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: lookbackDays));
    
    final transactions = await _db.queryTransactions(
      type: AppConstants.transactionTypeExpense,
      category: category,
      startDate: startDate,
      endDate: endDate,
    );
    
    if (transactions.isEmpty) {
      return SpendingFeatures(
        avgDailySpending: 0,
        avgWeeklySpending: 0,
        avgMonthlySpending: 0,
        trend: 0,
        volatility: 0,
        transactionCount: 0,
        categoryDistribution: {},
        dayOfWeekPattern: 0,
        seasonalFactor: 1.0,
      );
    }
    
    // Calculate daily spending
    final dailySpending = <DateTime, double>{};
    for (final tx in transactions) {
      final date = DateTime.fromMillisecondsSinceEpoch(tx['timestamp'] as int);
      final dateKey = DateTime(date.year, date.month, date.day);
      dailySpending[dateKey] = (dailySpending[dateKey] ?? 0) + (tx['amount'] as double);
    }
    
    final avgDaily = dailySpending.values.isEmpty 
        ? 0.0 
        : dailySpending.values.reduce((a, b) => a + b) / dailySpending.length;
    
    // Calculate weekly spending
    final avgWeekly = avgDaily * 7;
    
    // Calculate monthly spending
    final avgMonthly = avgDaily * 30;
    
    // Calculate trend (linear regression slope)
    final trend = _calculateTrend(dailySpending);
    
    // Calculate volatility (standard deviation)
    final volatility = _calculateVolatility(dailySpending.values.toList());
    
    // Category distribution
    final categoryDist = <String, double>{};
    for (final tx in transactions) {
      final cat = tx['category'] as String;
      categoryDist[cat] = (categoryDist[cat] ?? 0) + (tx['amount'] as double);
    }
    
    // Day of week pattern
    final dowPattern = _calculateDayOfWeekPattern(transactions);
    
    // Seasonal factor
    final seasonalFactor = _calculateSeasonalFactor(DateTime.now());
    
    return SpendingFeatures(
      avgDailySpending: avgDaily,
      avgWeeklySpending: avgWeekly,
      avgMonthlySpending: avgMonthly,
      trend: trend,
      volatility: volatility,
      transactionCount: transactions.length,
      categoryDistribution: categoryDist,
      dayOfWeekPattern: dowPattern,
      seasonalFactor: seasonalFactor,
    );
  }

  /// Moving average prediction
  double _movingAveragePrediction(SpendingFeatures features) {
    return features.avgMonthlySpending;
  }

  /// Trend-based prediction
  double _trendBasedPrediction(SpendingFeatures features) {
    // Project based on current trend
    final basePrediction = features.avgMonthlySpending;
    final trendAdjustment = features.trend * 30; // 30 days
    return max(0, basePrediction + trendAdjustment);
  }

  /// Seasonal prediction
  double _seasonalPrediction(SpendingFeatures features, DateTime period) {
    return features.avgMonthlySpending * features.seasonalFactor;
  }

  /// Calculate trend using simple linear regression
  double _calculateTrend(Map<DateTime, double> dailySpending) {
    if (dailySpending.length < 2) return 0;
    
    final sortedDates = dailySpending.keys.toList()..sort();
    final n = sortedDates.length;
    
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    
    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = dailySpending[sortedDates[i]]!;
      
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    
    // Slope = (n*sumXY - sumX*sumY) / (n*sumX2 - sumX*sumX)
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    return slope;
  }

  /// Calculate volatility (standard deviation)
  double _calculateVolatility(List<double> values) {
    if (values.isEmpty) return 0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => pow(v - mean, 2));
    final variance = squaredDiffs.reduce((a, b) => a + b) / values.length;
    
    return sqrt(variance);
  }

  /// Calculate day of week spending pattern
  double _calculateDayOfWeekPattern(List<Map<String, dynamic>> transactions) {
    final weekdaySpending = <int, double>{};
    
    for (final tx in transactions) {
      final date = DateTime.fromMillisecondsSinceEpoch(tx['timestamp'] as int);
      final dow = date.weekday;
      weekdaySpending[dow] = (weekdaySpending[dow] ?? 0) + (tx['amount'] as double);
    }
    
    if (weekdaySpending.isEmpty) return 1.0;
    
    final avgWeekday = weekdaySpending.values.reduce((a, b) => a + b) / weekdaySpending.length;
    return avgWeekday > 0 ? 1.0 : 0.0;
  }

  /// Calculate seasonal factor
  double _calculateSeasonalFactor(DateTime date) {
    final month = date.month;
    
    // Example seasonal factors (can be trained from historical data)
    final seasonalFactors = {
      1: 1.1,  // January - New Year
      2: 1.0,  // February
      3: 1.05, // March
      4: 1.0,  // April
      5: 1.05, // May
      6: 1.1,  // June - Mid-year
      7: 1.15, // July - Summer
      8: 1.15, // August - Summer
      9: 1.05, // September
      10: 1.1, // October
      11: 1.15, // November - Holidays
      12: 1.2, // December - Holidays
    };
    
    return seasonalFactors[month] ?? 1.0;
  }

  /// Calculate prediction confidence
  double _calculatePredictionConfidence(SpendingFeatures features) {
    double confidence = 0.5; // Base confidence
    
    // More transactions = higher confidence
    if (features.transactionCount > 50) {
      confidence += 0.2;
    } else if (features.transactionCount > 20) {
      confidence += 0.1;
    }
    
    // Lower volatility = higher confidence
    if (features.avgMonthlySpending > 0) {
      final cvCoefficient = features.volatility / features.avgMonthlySpending;
      if (cvCoefficient < 0.3) {
        confidence += 0.2;
      } else if (cvCoefficient < 0.5) {
        confidence += 0.1;
      }
    }
    
    // Stable trend = higher confidence
    if (features.trend.abs() < features.avgDailySpending * 0.1) {
      confidence += 0.1;
    }
    
    return confidence.clamp(0.0, 1.0);
  }

  /// Calculate risk score
  Future<double> _calculateRiskScore({
    required double predictedAmount,
    String? category,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    // Get active budgets
    final budgets = await _db.queryActiveBudgets();
    
    double riskScore = 0.0;
    
    for (final budget in budgets) {
      if (category != null && budget['category'] != category) continue;
      
      final budgetLimit = budget['limit_amount'] as double;
      final usageRatio = predictedAmount / budgetLimit;
      
      if (usageRatio > 1.0) {
        riskScore = max(riskScore, 1.0);
      } else if (usageRatio > 0.9) {
        riskScore = max(riskScore, 0.8);
      } else if (usageRatio > 0.8) {
        riskScore = max(riskScore, 0.6);
      }
    }
    
    return riskScore;
  }

  /// Identify contributing factors
  List<String> _identifyFactors(SpendingFeatures features, double riskScore) {
    final factors = <String>[];
    
    if (features.trend > 0) {
      factors.add('Spending trend is increasing');
    } else if (features.trend < 0) {
      factors.add('Spending trend is decreasing');
    }
    
    if (features.volatility > features.avgMonthlySpending * 0.5) {
      factors.add('High spending volatility detected');
    }
    
    if (riskScore > AppConstants.riskThreshold) {
      factors.add('High risk of budget overrun');
    }
    
    if (features.seasonalFactor > 1.1) {
      factors.add('Seasonal increase expected');
    }
    
    return factors;
  }

  /// Create detailed breakdown
  Map<String, dynamic> _createBreakdown(
    SpendingFeatures features,
    double predictedAmount,
  ) {
    return {
      'avg_daily': features.avgDailySpending,
      'avg_weekly': features.avgWeeklySpending,
      'avg_monthly': features.avgMonthlySpending,
      'predicted': predictedAmount,
      'trend': features.trend,
      'volatility': features.volatility,
      'transaction_count': features.transactionCount,
      'category_distribution': features.categoryDistribution,
    };
  }

  /// Cache prediction in database
  Future<void> _cachePrediction(Prediction prediction) async {
    await _db.insertPrediction({
      'id': prediction.id,
      'category': prediction.category,
      'predicted_amount': prediction.predictedAmount,
      'confidence': prediction.confidence,
      'period_start': prediction.periodStart.millisecondsSinceEpoch,
      'period_end': prediction.periodEnd.millisecondsSinceEpoch,
      'risk_score': prediction.riskScore,
      'factors': prediction.factors.join('|'),
      'breakdown': _encodeJson(prediction.breakdown),
      'generated_at': prediction.generatedAt.millisecondsSinceEpoch,
    });
  }

  String _encodeJson(Map<String, dynamic> data) {
    // Simple JSON encoding
    return data.entries.map((e) => '"${e.key}":${e.value}').join(',');
  }
}
