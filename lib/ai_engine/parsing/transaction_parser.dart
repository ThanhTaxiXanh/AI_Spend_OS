import 'dart:convert';
import 'package:logger/logger.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';

/// Parsed transaction result from AI engine
class ParsedTransaction {
  final String type;
  final double amount;
  final String category;
  final String description;
  final DateTime timestamp;
  final double confidence;
  final Map<String, dynamic> metadata;

  ParsedTransaction({
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.timestamp,
    required this.confidence,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'amount': amount,
    'category': category,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'confidence': confidence,
    'metadata': metadata,
  };
}

/// Self-evolving AI Transaction Parser
/// Handles Vietnamese and English input with reinforcement learning
class AITransactionParser {
  final Logger _logger = Logger();
  
  // Category keywords mapping (can be loaded from database)
  final Map<String, List<String>> _categoryKeywords = {
    'Food & Dining': [
      'ăn', 'cơm', 'phở', 'bún', 'cafe', 'cà phê', 'quán', 'nhà hàng',
      'food', 'eat', 'restaurant', 'coffee', 'breakfast', 'lunch', 'dinner',
      'fast food', 'grab food', 'shopeefood', 'gofood', 'baemin',
    ],
    'Transportation': [
      'xe', 'grab', 'uber', 'taxi', 'xăng', 'gas', 'petrol', 'parking',
      'đỗ xe', 'bus', 'xe buýt', 'metro', 'tàu', 'máy bay', 'flight',
      'gojek', 'be', 'vehicle', 'car', 'bike', 'motorcycle',
    ],
    'Shopping': [
      'mua', 'shopping', 'quần áo', 'clothes', 'giày', 'shoes', 'đồ',
      'lazada', 'shopee', 'tiki', 'sendo', 'mall', 'siêu thị', 'market',
      'fashion', 'áo', 'váy', 'phụ kiện', 'accessories',
    ],
    'Entertainment': [
      'phim', 'movie', 'cinema', 'game', 'chơi', 'giải trí', 'vui chơi',
      'karaoke', 'bar', 'club', 'concert', 'show', 'netflix', 'spotify',
      'entertainment', 'fun', 'hobby', 'sport', 'gym',
    ],
    'Bills & Utilities': [
      'tiền điện', 'electric', 'electricity', 'tiền nước', 'water',
      'internet', 'wifi', 'phone', 'điện thoại', 'bill', 'hóa đơn',
      'rent', 'thuê nhà', 'gas', 'garbage', 'rác', 'utility',
    ],
    'Healthcare': [
      'bệnh viện', 'hospital', 'doctor', 'bác sĩ', 'thuốc', 'medicine',
      'pharmacy', 'nhà thuốc', 'khám bệnh', 'health', 'medical',
      'dental', 'nha khoa', 'insurance', 'bảo hiểm',
    ],
    'Education': [
      'học', 'học phí', 'tuition', 'school', 'trường', 'course', 'khóa học',
      'book', 'sách', 'education', 'training', 'đào tạo', 'class',
      'university', 'đại học', 'study',
    ],
    'Personal Care': [
      'spa', 'salon', 'barber', 'cắt tóc', 'nail', 'massage', 'beauty',
      'makeup', 'skincare', 'cosmetics', 'mỹ phẩm', 'personal', 'care',
      'haircut', 'grooming',
    ],
    'Gifts & Donations': [
      'quà', 'gift', 'present', 'donate', 'từ thiện', 'charity',
      'wedding', 'cưới', 'birthday', 'sinh nhật', 'tặng',
    ],
    'Travel': [
      'du lịch', 'travel', 'tour', 'hotel', 'khách sạn', 'resort',
      'vacation', 'nghỉ dưỡng', 'trip', 'chuyến đi', 'booking',
    ],
    'Investment': [
      'đầu tư', 'invest', 'stock', 'cổ phiếu', 'crypto', 'bitcoin',
      'fund', 'quỹ', 'saving', 'tiết kiệm', 'gold', 'vàng',
    ],
  };

  /// Parse raw text input into structured transaction
  Future<ParsedTransaction> parse(String input, {Map<String, double>? keywordWeights}) async {
    try {
      _logger.i('Parsing input: $input');
      
      // Step 1: Normalize text
      final normalizedText = _normalizeText(input);
      
      // Step 2: Extract amount
      final amount = _extractAmount(normalizedText);
      
      // Step 3: Detect transaction type
      final type = _detectTransactionType(normalizedText);
      
      // Step 4: Categorize with reinforcement learning
      final categoryResult = _categorizeTransaction(
        normalizedText,
        keywordWeights: keywordWeights,
      );
      
      // Step 5: Extract timestamp hints
      final timestamp = _extractTimestamp(normalizedText);
      
      // Step 6: Generate clean description
      final description = _generateDescription(normalizedText, amount, categoryResult['category']);
      
      // Step 7: Calculate confidence score
      final confidence = _calculateConfidence(
        amount: amount,
        category: categoryResult['category'],
        categoryConfidence: categoryResult['confidence'],
        type: type,
      );
      
      return ParsedTransaction(
        type: type,
        amount: amount,
        category: categoryResult['category'],
        description: description,
        timestamp: timestamp,
        confidence: confidence,
        metadata: {
          'raw_input': input,
          'normalized': normalizedText,
          'keywords_matched': categoryResult['keywords'],
          'amount_pattern': categoryResult['amount_pattern'],
        },
      );
    } catch (e) {
      _logger.e('Parsing failed: $e');
      throw ParsingFailure('Failed to parse transaction: $e');
    }
  }

  /// Normalize Vietnamese text
  String _normalizeText(String text) {
    // Convert to lowercase
    String normalized = text.toLowerCase().trim();
    
    // Remove extra spaces
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    
    // Normalize Vietnamese currency
    normalized = normalized.replaceAll('đồng', 'đ');
    normalized = normalized.replaceAll('vnd', 'đ');
    normalized = normalized.replaceAll('k', '000');
    
    return normalized;
  }

  /// Extract amount from text
  double _extractAmount(String text) {
    // Try digit patterns first
    final digitPattern = RegExp(r'(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)');
    final digitMatch = digitPattern.firstMatch(text);
    
    if (digitMatch != null) {
      final amountStr = digitMatch.group(1)!
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return double.tryParse(amountStr) ?? 0.0;
    }
    
    // Try Vietnamese number words
    final viAmount = _extractVietnameseAmount(text);
    if (viAmount > 0) return viAmount;
    
    return 0.0;
  }

  /// Extract amount from Vietnamese number words
  double _extractVietnameseAmount(String text) {
    double total = 0;
    double current = 0;
    
    final words = text.split(' ');
    
    for (final word in words) {
      if (AppConstants.vietnameseNumbers.containsKey(word)) {
        final value = AppConstants.vietnameseNumbers[word]!;
        
        if (value >= 1000) {
          if (current == 0) current = 1;
          current *= value;
          total += current;
          current = 0;
        } else if (value >= 100) {
          if (current == 0) current = 1;
          current *= value;
        } else {
          current += value;
        }
      }
    }
    
    total += current;
    return total;
  }

  /// Detect transaction type (expense, income, transfer)
  String _detectTransactionType(String text) {
    // Income keywords
    if (text.contains('nhận') || text.contains('receive') ||
        text.contains('lương') || text.contains('salary') ||
        text.contains('income') || text.contains('thu nhập')) {
      return AppConstants.transactionTypeIncome;
    }
    
    // Transfer keywords
    if (text.contains('chuyển') || text.contains('transfer') ||
        text.contains('gửi') || text.contains('send')) {
      return AppConstants.transactionTypeTransfer;
    }
    
    // Default to expense
    return AppConstants.transactionTypeExpense;
  }

  /// Categorize transaction with reinforcement learning
  Map<String, dynamic> _categorizeTransaction(
    String text, {
    Map<String, double>? keywordWeights,
  }) {
    final scores = <String, double>{};
    final matchedKeywords = <String, List<String>>{};
    
    // Score each category
    for (final category in _categoryKeywords.keys) {
      double score = 0.0;
      final keywords = <String>[];
      
      for (final keyword in _categoryKeywords[category]!) {
        if (text.contains(keyword)) {
          // Base score
          double keywordScore = 1.0;
          
          // Apply reinforcement learning weight if available
          if (keywordWeights != null && keywordWeights.containsKey('$keyword:$category')) {
            keywordScore *= keywordWeights['$keyword:$category']!;
          }
          
          // Boost for exact word match vs substring
          if (RegExp(r'\b' + keyword + r'\b').hasMatch(text)) {
            keywordScore *= 1.5;
          }
          
          score += keywordScore;
          keywords.add(keyword);
        }
      }
      
      if (score > 0) {
        scores[category] = score;
        matchedKeywords[category] = keywords;
      }
    }
    
    // Find best category
    if (scores.isEmpty) {
      return {
        'category': 'Other',
        'confidence': 0.3,
        'keywords': <String>[],
        'amount_pattern': 'none',
      };
    }
    
    final sortedEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final bestCategory = sortedEntries.first.key;
    final bestScore = sortedEntries.first.value;
    
    // Calculate confidence based on score separation
    double confidence = 0.5;
    if (sortedEntries.length == 1) {
      confidence = 0.8;
    } else {
      final secondScore = sortedEntries[1].value;
      final separation = (bestScore - secondScore) / bestScore;
      confidence = 0.5 + (separation * 0.4);
    }
    
    return {
      'category': bestCategory,
      'confidence': confidence,
      'keywords': matchedKeywords[bestCategory] ?? [],
      'amount_pattern': 'keyword_match',
    };
  }

  /// Extract timestamp from text
  DateTime _extractTimestamp(String text) {
    final now = DateTime.now();
    
    // Check for time indicators
    if (text.contains('hôm qua') || text.contains('yesterday')) {
      return now.subtract(const Duration(days: 1));
    }
    
    if (text.contains('hôm kia')) {
      return now.subtract(const Duration(days: 2));
    }
    
    if (text.contains('tuần trước') || text.contains('last week')) {
      return now.subtract(const Duration(days: 7));
    }
    
    // Default to now
    return now;
  }

  /// Generate clean description
  String _generateDescription(String text, double amount, String category) {
    // Remove amount from text
    String desc = text;
    desc = desc.replaceAll(RegExp(r'\d+[.,\d]*'), '');
    desc = desc.replaceAll('đ', '');
    desc = desc.replaceAll('k', '');
    desc = desc.trim();
    
    // Remove common filler words
    final fillers = ['chi', 'trả', 'mua', 'paid', 'buy', 'spent'];
    for (final filler in fillers) {
      desc = desc.replaceAll(filler, '');
    }
    
    desc = desc.trim();
    
    if (desc.isEmpty) {
      desc = category;
    }
    
    return desc[0].toUpperCase() + desc.substring(1);
  }

  /// Calculate overall confidence score
  double _calculateConfidence({
    required double amount,
    required String category,
    required double categoryConfidence,
    required String type,
  }) {
    double confidence = categoryConfidence;
    
    // Boost if amount is valid
    if (amount > 0) {
      confidence *= 1.1;
    } else {
      confidence *= 0.5;
    }
    
    // Boost if not 'Other' category
    if (category != 'Other') {
      confidence *= 1.1;
    }
    
    // Cap at 1.0
    return confidence > 1.0 ? 1.0 : confidence;
  }

  /// Get category keywords (for UI/debugging)
  Map<String, List<String>> getCategoryKeywords() => _categoryKeywords;
}
