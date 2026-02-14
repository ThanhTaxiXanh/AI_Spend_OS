import 'package:logger/logger.dart';
import '../../core/constants/app_constants.dart';
import '../../services/database/database_service.dart';
import '../../domain/entities/keyword_weight.dart';
import 'package:uuid/uuid.dart';

/// Auto-Categorization Reinforcement Engine
/// Implements adaptive learning from user corrections
class ReinforcementEngine {
  final DatabaseService _db;
  final Logger _logger = Logger();
  final _uuid = const Uuid();

  ReinforcementEngine(this._db);

  /// Learn from user correction
  /// When user changes category, boost relevant keywords and decay others
  Future<void> learnFromCorrection({
    required String originalText,
    required String predictedCategory,
    required String correctCategory,
  }) async {
    try {
      _logger.i('Learning from correction: $predictedCategory -> $correctCategory');
      
      // Extract keywords from text
      final keywords = _extractKeywords(originalText);
      
      // Boost weights for correct category
      for (final keyword in keywords) {
        await _boostKeywordWeight(keyword, correctCategory);
      }
      
      // Reduce weights for incorrect category if different
      if (predictedCategory != correctCategory) {
        for (final keyword in keywords) {
          await _reduceKeywordWeight(keyword, predictedCategory);
        }
      }
      
      _logger.i('Reinforcement learning applied for ${keywords.length} keywords');
    } catch (e) {
      _logger.e('Failed to apply reinforcement learning: $e');
    }
  }

  /// Boost keyword weight for category
  Future<void> _boostKeywordWeight(String keyword, String category) async {
    final existing = await _db.queryKeywordWeights(keyword);
    
    // Find existing weight for this category
    final matchingWeight = existing.where(
      (w) => w['category'] == category,
    ).firstOrNull;
    
    if (matchingWeight != null) {
      // Update existing weight
      final currentWeight = matchingWeight['weight'] as double;
      final occurrences = matchingWeight['occurrence_count'] as int;
      
      await _db.upsertKeywordWeight({
        'id': matchingWeight['id'],
        'keyword': keyword,
        'category': category,
        'weight': currentWeight + AppConstants.weightBoost,
        'occurrence_count': occurrences + 1,
        'last_used': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      // Create new weight entry
      await _db.upsertKeywordWeight({
        'id': _uuid.v4(),
        'keyword': keyword,
        'category': category,
        'weight': AppConstants.initialWeight + AppConstants.weightBoost,
        'occurrence_count': 1,
        'last_used': DateTime.now().millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  /// Reduce keyword weight for category
  Future<void> _reduceKeywordWeight(String keyword, String category) async {
    final existing = await _db.queryKeywordWeights(keyword);
    
    final matchingWeight = existing.where(
      (w) => w['category'] == category,
    ).firstOrNull;
    
    if (matchingWeight != null) {
      final currentWeight = matchingWeight['weight'] as double;
      final newWeight = currentWeight * 0.8; // Reduce by 20%
      
      if (newWeight > 0.1) {
        await _db.upsertKeywordWeight({
          'id': matchingWeight['id'],
          'keyword': keyword,
          'category': category,
          'weight': newWeight,
          'occurrence_count': matchingWeight['occurrence_count'],
          'last_used': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }
  }

  /// Get keyword weights for parsing
  Future<Map<String, double>> getKeywordWeights() async {
    final allWeights = await _db.database.then(
      (db) => db.query('keyword_weights'),
    );
    
    final weights = <String, double>{};
    
    for (final w in allWeights) {
      final keyword = w['keyword'] as String;
      final category = w['category'] as String;
      final weight = w['weight'] as double;
      final lastUsed = DateTime.fromMillisecondsSinceEpoch(w['last_used'] as int);
      
      // Apply time decay
      final decayedWeight = _applyTimeDecay(weight, lastUsed);
      
      weights['$keyword:$category'] = decayedWeight;
    }
    
    return weights;
  }

  /// Apply time decay to weight
  double _applyTimeDecay(double weight, DateTime lastUsed) {
    final daysSinceUsed = DateTime.now().difference(lastUsed).inDays;
    
    if (daysSinceUsed <= AppConstants.decayDays) {
      return weight;
    }
    
    // Calculate decay
    final decayPeriods = daysSinceUsed ~/ AppConstants.decayDays;
    final decayedWeight = weight * 
        (AppConstants.weightDecay * decayPeriods).clamp(0.1, 1.0);
    
    return decayedWeight;
  }

  /// Extract keywords from text
  List<String> _extractKeywords(String text) {
    final normalized = text.toLowerCase().trim();
    final words = normalized.split(RegExp(r'\s+'));
    
    // Filter out common words and numbers
    final stopWords = {
      'và', 'or', 'the', 'a', 'an', 'in', 'on', 'at', 'to', 'for',
      'của', 'với', 'là', 'có', 'đã', 'sẽ', 'được', 'cho',
    };
    
    return words.where((word) {
      return word.length > 2 && 
             !stopWords.contains(word) &&
             !RegExp(r'^\d+$').hasMatch(word);
    }).toList();
  }

  /// Get contextual scoring based on time and day
  Future<Map<String, double>> getContextualScores({
    required DateTime timestamp,
  }) async {
    final hour = timestamp.hour;
    final weekday = timestamp.weekday;
    
    final scores = <String, double>{};
    
    // Time of day patterns
    if (AppConstants.timePatterns['morning']!.contains(hour)) {
      scores['Food & Dining'] = 1.2; // Higher probability in morning
      scores['Transportation'] = 1.3; // Commute time
    } else if (AppConstants.timePatterns['afternoon']!.contains(hour)) {
      scores['Food & Dining'] = 1.1;
      scores['Shopping'] = 1.2;
    } else if (AppConstants.timePatterns['evening']!.contains(hour)) {
      scores['Entertainment'] = 1.3;
      scores['Food & Dining'] = 1.2;
    }
    
    // Weekday vs weekend patterns
    if (AppConstants.weekends.contains(weekday)) {
      scores['Entertainment'] = (scores['Entertainment'] ?? 1.0) * 1.2;
      scores['Travel'] = (scores['Travel'] ?? 1.0) * 1.3;
      scores['Shopping'] = (scores['Shopping'] ?? 1.0) * 1.2;
    } else {
      scores['Transportation'] = (scores['Transportation'] ?? 1.0) * 1.2;
      scores['Food & Dining'] = (scores['Food & Dining'] ?? 1.0) * 1.1;
    }
    
    return scores;
  }

  /// Cleanup old unused weights
  Future<void> cleanupOldWeights({int maxAge = 180}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: maxAge));
    final db = await _db.database;
    
    await db.delete(
      'keyword_weights',
      where: 'last_used < ? AND weight < ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch, 0.5],
    );
    
    _logger.i('Cleaned up old keyword weights');
  }

  /// Get statistics for monitoring
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await _db.database;
    
    final totalWeights = await db.rawQuery(
      'SELECT COUNT(*) as count FROM keyword_weights',
    );
    
    final avgWeight = await db.rawQuery(
      'SELECT AVG(weight) as avg FROM keyword_weights',
    );
    
    final topKeywords = await db.rawQuery(
      'SELECT keyword, category, weight, occurrence_count '
      'FROM keyword_weights ORDER BY weight DESC LIMIT 10',
    );
    
    return {
      'total_weights': totalWeights.first['count'],
      'average_weight': avgWeight.first['avg'],
      'top_keywords': topKeywords,
    };
  }
}
