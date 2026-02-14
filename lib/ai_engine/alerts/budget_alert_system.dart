import 'package:logger/logger.dart';
import '../../core/constants/app_constants.dart';
import '../../services/database/database_service.dart';
import '../prediction/spending_predictor.dart';

/// Alert type and severity
enum AlertSeverity { info, warning, critical }

class BudgetAlert {
  final String id;
  final String category;
  final AlertSeverity severity;
  final String message;
  final double currentSpending;
  final double budgetLimit;
  final double projectedSpending;
  final double daysRemaining;
  final List<String> suggestions;
  final DateTime generatedAt;

  BudgetAlert({
    required this.id,
    required this.category,
    required this.severity,
    required this.message,
    required this.currentSpending,
    required this.budgetLimit,
    required this.projectedSpending,
    required this.daysRemaining,
    required this.suggestions,
    required this.generatedAt,
  });
}

/// Intelligent Budget Alert System
/// Generates predictive alerts based on spending patterns
class BudgetAlertSystem {
  final DatabaseService _db;
  final SpendingPredictor _predictor;
  final Logger _logger = Logger();

  BudgetAlertSystem(this._db, this._predictor);

  /// Check all budgets and generate alerts
  Future<List<BudgetAlert>> checkBudgets() async {
    final alerts = <BudgetAlert>[];
    
    try {
      final budgets = await _db.queryActiveBudgets();
      
      for (final budget in budgets) {
        final alert = await _checkBudget(budget);
        if (alert != null) {
          alerts.add(alert);
        }
      }
      
      _logger.i('Generated ${alerts.length} budget alerts');
    } catch (e) {
      _logger.e('Failed to check budgets: $e');
    }
    
    return alerts;
  }

  /// Check individual budget
  Future<BudgetAlert?> _checkBudget(Map<String, dynamic> budget) async {
    final category = budget['category'] as String;
    final limit = budget['limit_amount'] as double;
    final startDate = DateTime.fromMillisecondsSinceEpoch(budget['start_date'] as int);
    final endDate = DateTime.fromMillisecondsSinceEpoch(budget['end_date'] as int);
    final alertThreshold = budget['alert_threshold'] as double;
    final enablePredictive = budget['enable_predictive_alerts'] as int == 1;
    
    // Get current spending
    final currentSpending = await _db.getTotalSpending(
      category: category,
      startDate: startDate,
      endDate: DateTime.now(),
    );
    
    // Calculate days remaining
    final daysRemaining = endDate.difference(DateTime.now()).inDays.toDouble();
    
    if (daysRemaining <= 0) return null;
    
    // Get projection if predictive alerts enabled
    double projectedSpending = currentSpending;
    
    if (enablePredictive) {
      final prediction = await _predictor.predictSpending(
        category: category,
        periodStart: DateTime.now(),
        periodEnd: endDate,
      );
      projectedSpending = currentSpending + prediction.predictedAmount;
    }
    
    // Determine severity and generate alert
    final currentRatio = currentSpending / limit;
    final projectedRatio = projectedSpending / limit;
    
    AlertSeverity? severity;
    String? message;
    
    // Critical: Already over limit
    if (currentRatio >= AppConstants.criticalThreshold) {
      severity = AlertSeverity.critical;
      message = 'You have exceeded your $category budget by ${((currentRatio - 1) * 100).toStringAsFixed(1)}%';
    }
    // Critical: Projected to exceed significantly
    else if (enablePredictive && projectedRatio >= 1.1) {
      severity = AlertSeverity.critical;
      message = 'Your $category spending is projected to exceed budget by ${((projectedRatio - 1) * 100).toStringAsFixed(1)}% this period';
    }
    // Warning: Near limit
    else if (currentRatio >= AppConstants.warningThreshold) {
      severity = AlertSeverity.warning;
      message = 'You have used ${(currentRatio * 100).toStringAsFixed(1)}% of your $category budget';
    }
    // Warning: Projected to exceed
    else if (enablePredictive && projectedRatio >= alertThreshold) {
      severity = AlertSeverity.warning;
      message = 'Your $category spending is on track to use ${(projectedRatio * 100).toStringAsFixed(1)}% of budget';
    }
    
    if (severity == null) return null;
    
    // Generate suggestions
    final suggestions = _generateSuggestions(
      category: category,
      currentSpending: currentSpending,
      limit: limit,
      daysRemaining: daysRemaining,
      severity: severity,
    );
    
    return BudgetAlert(
      id: '${budget['id']}_alert',
      category: category,
      severity: severity,
      message: message,
      currentSpending: currentSpending,
      budgetLimit: limit,
      projectedSpending: projectedSpending,
      daysRemaining: daysRemaining,
      suggestions: suggestions,
      generatedAt: DateTime.now(),
    );
  }

  /// Generate smart suggestions based on alert
  List<String> _generateSuggestions({
    required String category,
    required double currentSpending,
    required double limit,
    required double daysRemaining,
    required AlertSeverity severity,
  }) {
    final suggestions = <String>[];
    final remaining = limit - currentSpending;
    final dailyBudget = daysRemaining > 0 ? remaining / daysRemaining : 0;
    
    if (severity == AlertSeverity.critical) {
      suggestions.add('Consider pausing $category spending for the rest of the period');
      suggestions.add('Review recent transactions to identify areas to cut back');
      suggestions.add('Transfer funds from another category if possible');
    } else if (severity == AlertSeverity.warning) {
      suggestions.add('Limit daily $category spending to ${dailyBudget.toStringAsFixed(0)} VND');
      suggestions.add('Look for cheaper alternatives in this category');
      suggestions.add('Track spending more closely for remaining ${daysRemaining.toInt()} days');
    }
    
    // Category-specific suggestions
    switch (category) {
      case 'Food & Dining':
        suggestions.add('Cook at home more often');
        suggestions.add('Bring lunch to work');
        break;
      case 'Transportation':
        suggestions.add('Use public transport when possible');
        suggestions.add('Carpool or combine trips');
        break;
      case 'Shopping':
        suggestions.add('Wait 24 hours before making purchases');
        suggestions.add('Create a shopping list and stick to it');
        break;
      case 'Entertainment':
        suggestions.add('Choose free or low-cost activities');
        suggestions.add('Limit entertainment to weekends');
        break;
    }
    
    return suggestions;
  }
}
