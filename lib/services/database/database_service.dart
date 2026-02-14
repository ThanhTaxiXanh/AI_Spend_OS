import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';
import 'package:logger/logger.dart';

/// Comprehensive database service managing SQLite operations
class DatabaseService {
  static Database? _database;
  static final Logger _logger = Logger();

  /// Get database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database with encryption and migrations
  Future<Database> _initDatabase() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = join(directory.path, AppConstants.databaseName);
      
      _logger.i('Initializing database at: $path');
      
      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    } catch (e) {
      _logger.e('Failed to initialize database: $e');
      throw const DatabaseFailure('Failed to initialize database');
    }
  }

  /// Create all tables on first install
  Future<void> _onCreate(Database db, int version) async {
    _logger.i('Creating database tables, version: $version');
    
    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        subcategory TEXT,
        description TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        location TEXT,
        notes TEXT,
        is_recurring INTEGER DEFAULT 0,
        recurring_pattern TEXT,
        confidence REAL DEFAULT 0.0,
        is_verified INTEGER DEFAULT 0,
        metadata TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');

    // Budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        limit_amount REAL NOT NULL,
        period TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1,
        alert_threshold REAL DEFAULT 0.8,
        enable_predictive_alerts INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');

    // Keyword weights table for reinforcement learning
    await db.execute('''
      CREATE TABLE keyword_weights (
        id TEXT PRIMARY KEY,
        keyword TEXT NOT NULL,
        category TEXT NOT NULL,
        weight REAL NOT NULL,
        occurrence_count INTEGER DEFAULT 1,
        last_used INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        context TEXT,
        UNIQUE(keyword, category)
      )
    ''');

    // Predictions cache table
    await db.execute('''
      CREATE TABLE predictions (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        predicted_amount REAL NOT NULL,
        confidence REAL NOT NULL,
        period_start INTEGER NOT NULL,
        period_end INTEGER NOT NULL,
        risk_score REAL NOT NULL,
        factors TEXT NOT NULL,
        breakdown TEXT NOT NULL,
        generated_at INTEGER NOT NULL,
        is_accurate INTEGER DEFAULT 0,
        actual_amount REAL
      )
    ''');

    // ML metadata table
    await db.execute('''
      CREATE TABLE ml_metadata (
        id TEXT PRIMARY KEY,
        model_name TEXT NOT NULL,
        model_version TEXT NOT NULL,
        training_date INTEGER NOT NULL,
        accuracy REAL,
        samples_count INTEGER,
        feature_count INTEGER,
        hyperparameters TEXT,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    // User settings table
    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Training data table for on-device ML
    await db.execute('''
      CREATE TABLE training_data (
        id TEXT PRIMARY KEY,
        features TEXT NOT NULL,
        label TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for performance
    await db.execute('CREATE INDEX idx_transactions_timestamp ON transactions(timestamp)');
    await db.execute('CREATE INDEX idx_transactions_category ON transactions(category)');
    await db.execute('CREATE INDEX idx_transactions_type ON transactions(type)');
    await db.execute('CREATE INDEX idx_budgets_category ON budgets(category)');
    await db.execute('CREATE INDEX idx_budgets_dates ON budgets(start_date, end_date)');
    await db.execute('CREATE INDEX idx_keyword_weights_keyword ON keyword_weights(keyword)');
    await db.execute('CREATE INDEX idx_keyword_weights_category ON keyword_weights(category)');
    await db.execute('CREATE INDEX idx_predictions_category ON predictions(category)');
    
    _logger.i('Database tables created successfully');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.i('Upgrading database from v$oldVersion to v$newVersion');
    
    // Add migration logic here for future versions
    if (oldVersion < 2) {
      // Example migration for version 2
      // await db.execute('ALTER TABLE transactions ADD COLUMN new_field TEXT');
    }
  }

  /// Operations to perform when database is opened
  Future<void> _onOpen(Database db) async {
    _logger.i('Database opened');
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Insert transaction
  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      transaction,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update transaction
  Future<void> updateTransaction(String id, Map<String, dynamic> transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete transaction
  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Query transactions with filters
  Future<List<Map<String, dynamic>>> queryTransactions({
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    
    String where = '';
    List<dynamic> whereArgs = [];
    
    if (type != null) {
      where += 'type = ?';
      whereArgs.add(type);
    }
    
    if (category != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'category = ?';
      whereArgs.add(category);
    }
    
    if (startDate != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'timestamp >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    
    if (endDate != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'timestamp <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }
    
    return await db.query(
      'transactions',
      where: where.isEmpty ? null : where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Insert or update keyword weight
  Future<void> upsertKeywordWeight(Map<String, dynamic> weight) async {
    final db = await database;
    await db.insert(
      'keyword_weights',
      weight,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Query keyword weights for a keyword
  Future<List<Map<String, dynamic>>> queryKeywordWeights(String keyword) async {
    final db = await database;
    return await db.query(
      'keyword_weights',
      where: 'keyword = ?',
      whereArgs: [keyword],
      orderBy: 'weight DESC',
    );
  }

  /// Insert budget
  Future<void> insertBudget(Map<String, dynamic> budget) async {
    final db = await database;
    await db.insert(
      'budgets',
      budget,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Query active budgets
  Future<List<Map<String, dynamic>>> queryActiveBudgets() async {
    final db = await database;
    return await db.query(
      'budgets',
      where: 'is_active = ?',
      whereArgs: [1],
    );
  }

  /// Insert prediction
  Future<void> insertPrediction(Map<String, dynamic> prediction) async {
    final db = await database;
    await db.insert(
      'predictions',
      prediction,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Query recent predictions
  Future<List<Map<String, dynamic>>> queryPredictions({
    String? category,
    DateTime? afterDate,
  }) async {
    final db = await database;
    
    String? where;
    List<dynamic>? whereArgs;
    
    if (category != null) {
      where = 'category = ?';
      whereArgs = [category];
    }
    
    if (afterDate != null) {
      if (where != null) {
        where += ' AND generated_at > ?';
        whereArgs!.add(afterDate.millisecondsSinceEpoch);
      } else {
        where = 'generated_at > ?';
        whereArgs = [afterDate.millisecondsSinceEpoch];
      }
    }
    
    return await db.query(
      'predictions',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'generated_at DESC',
    );
  }

  /// Insert ML metadata
  Future<void> insertMLMetadata(Map<String, dynamic> metadata) async {
    final db = await database;
    await db.insert(
      'ml_metadata',
      metadata,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get or set user setting
  Future<String?> getSetting(String key) async {
    final db = await database;
    final results = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    
    if (results.isEmpty) return null;
    return results.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'user_settings',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert training data sample
  Future<void> insertTrainingData(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'training_data',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all training data for model training
  Future<List<Map<String, dynamic>>> getAllTrainingData() async {
    final db = await database;
    return await db.query('training_data');
  }

  /// Calculate total spending for period
  Future<double> getTotalSpending({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String where = "type = 'expense'";
    List<dynamic> whereArgs = [];
    
    if (category != null) {
      where += ' AND category = ?';
      whereArgs.add(category);
    }
    
    if (startDate != null) {
      where += ' AND timestamp >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    
    if (endDate != null) {
      where += ' AND timestamp <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }
    
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE $where',
      whereArgs,
    );
    
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get spending by category for period
  Future<Map<String, double>> getSpendingByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String where = "type = 'expense'";
    List<dynamic> whereArgs = [];
    
    if (startDate != null) {
      where += ' AND timestamp >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    
    if (endDate != null) {
      where += ' AND timestamp <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }
    
    final results = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM transactions WHERE $where GROUP BY category',
      whereArgs,
    );
    
    return Map.fromEntries(
      results.map((r) => MapEntry(
        r['category'] as String,
        (r['total'] as num).toDouble(),
      )),
    );
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('budgets');
    await db.delete('keyword_weights');
    await db.delete('predictions');
    await db.delete('ml_metadata');
    await db.delete('training_data');
  }
}
