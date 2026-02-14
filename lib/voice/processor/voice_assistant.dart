import 'package:logger/logger.dart';
import '../../core/constants/app_constants.dart';
import '../../services/database/database_service.dart';

/// Query intent detected from voice input
enum QueryIntent {
  totalSpending,
  categorySpending,
  budgetRemaining,
  comparison,
  projection,
  transactionHistory,
  addTransaction,
  unknown,
}

/// Voice query result
class VoiceQueryResult {
  final QueryIntent intent;
  final Map<String, dynamic> parameters;
  final String response;
  final Map<String, dynamic>? data;

  VoiceQueryResult({
    required this.intent,
    required this.parameters,
    required this.response,
    this.data,
  });
}

/// Voice Financial Assistant
/// Processes natural language queries about finances
class VoiceAssistant {
  final DatabaseService _db;
  final Logger _logger = Logger();

  VoiceAssistant(this._db);

  /// Process voice query
  Future<VoiceQueryResult> processQuery(String query) async {
    try {
      _logger.i('Processing voice query: $query');
      
      // Normalize query
      final normalized = query.toLowerCase().trim();
      
      // Detect intent
      final intent = _detectIntent(normalized);
      
      // Extract parameters
      final parameters = _extractParameters(normalized, intent);
      
      // Execute query
      final result = await _executeQuery(intent, parameters);
      
      return result;
    } catch (e) {
      _logger.e('Voice query processing failed: $e');
      return VoiceQueryResult(
        intent: QueryIntent.unknown,
        parameters: {},
        response: 'Xin lỗi, tôi không hiểu câu hỏi của bạn.',
      );
    }
  }

  /// Detect query intent
  QueryIntent _detectIntent(String query) {
    // Total spending patterns
    if (query.contains('tổng') || query.contains('total') ||
        query.contains('bao nhiêu') && query.contains('chi')) {
      return QueryIntent.totalSpending;
    }
    
    // Category spending
    if (query.contains('danh mục') || query.contains('category') ||
        _containsCategory(query)) {
      return QueryIntent.categorySpending;
    }
    
    // Budget remaining
    if (query.contains('còn') || query.contains('remaining') ||
        query.contains('ngân sách')) {
      return QueryIntent.budgetRemaining;
    }
    
    // Comparison
    if (query.contains('so với') || query.contains('compared') ||
        query.contains('hơn')) {
      return QueryIntent.comparison;
    }
    
    // Projection
    if (query.contains('dự đoán') || query.contains('predict') ||
        query.contains('sẽ')) {
      return QueryIntent.projection;
    }
    
    // Add transaction
    if (query.contains('thêm') || query.contains('add') ||
        query.contains('ghi')) {
      return QueryIntent.addTransaction;
    }
    
    return QueryIntent.unknown;
  }

  /// Check if query contains category name
  bool _containsCategory(String query) {
    for (final category in AppConstants.defaultCategories) {
      if (query.contains(category.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  /// Extract parameters from query
  Map<String, dynamic> _extractParameters(String query, QueryIntent intent) {
    final params = <String, dynamic>{};
    
    // Extract time period
    if (query.contains('hôm nay') || query.contains('today')) {
      params['period'] = 'today';
      params['startDate'] = DateTime.now().subtract(const Duration(days: 0));
      params['endDate'] = DateTime.now();
    } else if (query.contains('tuần này') || query.contains('this week')) {
      params['period'] = 'week';
      params['startDate'] = DateTime.now().subtract(const Duration(days: 7));
      params['endDate'] = DateTime.now();
    } else if (query.contains('tháng này') || query.contains('this month')) {
      params['period'] = 'month';
      final now = DateTime.now();
      params['startDate'] = DateTime(now.year, now.month, 1);
      params['endDate'] = now;
    } else if (query.contains('tháng trước') || query.contains('last month')) {
      params['period'] = 'last_month';
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      params['startDate'] = lastMonth;
      params['endDate'] = DateTime(now.year, now.month, 0);
    }
    
    // Extract category
    for (final category in AppConstants.defaultCategories) {
      if (query.contains(category.toLowerCase())) {
        params['category'] = category;
        break;
      }
    }
    
    return params;
  }

  /// Execute query based on intent
  Future<VoiceQueryResult> _executeQuery(
    QueryIntent intent,
    Map<String, dynamic> parameters,
  ) async {
    switch (intent) {
      case QueryIntent.totalSpending:
        return await _handleTotalSpending(parameters);
      
      case QueryIntent.categorySpending:
        return await _handleCategorySpending(parameters);
      
      case QueryIntent.budgetRemaining:
        return await _handleBudgetRemaining(parameters);
      
      case QueryIntent.comparison:
        return await _handleComparison(parameters);
      
      default:
        return VoiceQueryResult(
          intent: intent,
          parameters: parameters,
          response: 'Tính năng này đang được phát triển.',
        );
    }
  }

  /// Handle total spending query
  Future<VoiceQueryResult> _handleTotalSpending(
    Map<String, dynamic> parameters,
  ) async {
    final period = parameters['period'] as String? ?? 'month';
    final startDate = parameters['startDate'] as DateTime?;
    final endDate = parameters['endDate'] as DateTime?;
    
    final total = await _db.getTotalSpending(
      startDate: startDate,
      endDate: endDate,
    );
    
    String response;
    if (period == 'today') {
      response = 'Hôm nay bạn đã chi ${_formatCurrency(total)}.';
    } else if (period == 'week') {
      response = 'Tuần này bạn đã chi ${_formatCurrency(total)}.';
    } else if (period == 'month') {
      response = 'Tháng này bạn đã chi ${_formatCurrency(total)}.';
    } else {
      response = 'Bạn đã chi ${_formatCurrency(total)} trong khoảng thời gian này.';
    }
    
    return VoiceQueryResult(
      intent: QueryIntent.totalSpending,
      parameters: parameters,
      response: response,
      data: {'total': total},
    );
  }

  /// Handle category spending query
  Future<VoiceQueryResult> _handleCategorySpending(
    Map<String, dynamic> parameters,
  ) async {
    final category = parameters['category'] as String?;
    final startDate = parameters['startDate'] as DateTime?;
    final endDate = parameters['endDate'] as DateTime?;
    final period = parameters['period'] as String? ?? 'month';
    
    if (category != null) {
      final total = await _db.getTotalSpending(
        category: category,
        startDate: startDate,
        endDate: endDate,
      );
      
      final response = 'Chi tiêu cho $category $period này là ${_formatCurrency(total)}.';
      
      return VoiceQueryResult(
        intent: QueryIntent.categorySpending,
        parameters: parameters,
        response: response,
        data: {'category': category, 'total': total},
      );
    } else {
      // Get all categories
      final breakdown = await _db.getSpendingByCategory(
        startDate: startDate,
        endDate: endDate,
      );
      
      final topCategories = breakdown.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      String response = 'Chi tiêu theo danh mục:\n';
      for (int i = 0; i < topCategories.take(3).length; i++) {
        final entry = topCategories[i];
        response += '${i + 1}. ${entry.key}: ${_formatCurrency(entry.value)}\n';
      }
      
      return VoiceQueryResult(
        intent: QueryIntent.categorySpending,
        parameters: parameters,
        response: response,
        data: {'breakdown': breakdown},
      );
    }
  }

  /// Handle budget remaining query
  Future<VoiceQueryResult> _handleBudgetRemaining(
    Map<String, dynamic> parameters,
  ) async {
    final budgets = await _db.queryActiveBudgets();
    
    if (budgets.isEmpty) {
      return VoiceQueryResult(
        intent: QueryIntent.budgetRemaining,
        parameters: parameters,
        response: 'Bạn chưa thiết lập ngân sách nào.',
      );
    }
    
    String response = 'Ngân sách còn lại:\n';
    final remainingData = <String, Map<String, double>>{};
    
    for (final budget in budgets) {
      final category = budget['category'] as String;
      final limit = budget['limit_amount'] as double;
      final startDate = DateTime.fromMillisecondsSinceEpoch(budget['start_date'] as int);
      
      final spent = await _db.getTotalSpending(
        category: category,
        startDate: startDate,
        endDate: DateTime.now(),
      );
      
      final remaining = limit - spent;
      remainingData[category] = {'limit': limit, 'spent': spent, 'remaining': remaining};
      
      response += '$category: ${_formatCurrency(remaining)} / ${_formatCurrency(limit)}\n';
    }
    
    return VoiceQueryResult(
      intent: QueryIntent.budgetRemaining,
      parameters: parameters,
      response: response,
      data: remainingData,
    );
  }

  /// Handle comparison query
  Future<VoiceQueryResult> _handleComparison(
    Map<String, dynamic> parameters,
  ) async {
    // Compare this month vs last month
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);
    
    final thisMonthTotal = await _db.getTotalSpending(
      startDate: thisMonthStart,
      endDate: now,
    );
    
    final lastMonthTotal = await _db.getTotalSpending(
      startDate: lastMonthStart,
      endDate: lastMonthEnd,
    );
    
    final difference = thisMonthTotal - lastMonthTotal;
    final percentChange = lastMonthTotal > 0 
        ? (difference / lastMonthTotal * 100) 
        : 0.0;
    
    String response;
    if (difference > 0) {
      response = 'Tháng này bạn chi nhiều hơn tháng trước ${_formatCurrency(difference.abs())} (${percentChange.toStringAsFixed(1)}%).';
    } else if (difference < 0) {
      response = 'Tháng này bạn tiết kiệm được ${_formatCurrency(difference.abs())} so với tháng trước (${percentChange.abs().toStringAsFixed(1)}%).';
    } else {
      response = 'Chi tiêu tháng này tương đương tháng trước.';
    }
    
    return VoiceQueryResult(
      intent: QueryIntent.comparison,
      parameters: parameters,
      response: response,
      data: {
        'this_month': thisMonthTotal,
        'last_month': lastMonthTotal,
        'difference': difference,
        'percent_change': percentChange,
      },
    );
  }

  /// Format currency for Vietnamese
  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} triệu đồng';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} nghìn đồng';
    } else {
      return '${amount.toStringAsFixed(0)} đồng';
    }
  }
}
