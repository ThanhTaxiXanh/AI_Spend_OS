/// Core constants for AI Spend OS
class AppConstants {
  // App Info
  static const String appName = 'AI Spend OS';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'ai_spend_os.db';
  static const int databaseVersion = 1;
  
  // ML Models
  static const String categoryModelPath = 'assets/models/category_classifier.tflite';
  static const String predictionModelPath = 'assets/models/spending_predictor.tflite';
  static const String parsingModelPath = 'assets/models/transaction_parser.tflite';
  
  // Voice
  static const String whisperModelPath = 'assets/models/whisper_tiny.tflite';
  static const int sampleRate = 16000;
  static const int recordingDuration = 30; // seconds
  
  // AI Engine
  static const double confidenceThreshold = 0.7;
  static const double autoSaveThreshold = 0.85;
  static const int maxTrainingIterations = 100;
  static const double learningRate = 0.001;
  
  // Reinforcement Learning
  static const double initialWeight = 1.0;
  static const double weightBoost = 0.2;
  static const double weightDecay = 0.95;
  static const int decayDays = 30;
  
  // Prediction
  static const int predictionWindow = 30; // days
  static const int historicalWindow = 90; // days
  static const double riskThreshold = 0.8;
  
  // Budget Alerts
  static const double warningThreshold = 0.8; // 80% of budget
  static const double criticalThreshold = 0.95; // 95% of budget
  static const int lookaheadDays = 7;
  
  // Categories
  static const List<String> defaultCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Personal Care',
    'Gifts & Donations',
    'Travel',
    'Investment',
    'Other',
  ];
  
  // Vietnamese Number Words
  static const Map<String, int> vietnameseNumbers = {
    'không': 0,
    'một': 1,
    'hai': 2,
    'ba': 3,
    'bốn': 4,
    'năm': 5,
    'sáu': 6,
    'bảy': 7,
    'tám': 8,
    'chín': 9,
    'mười': 10,
    'trăm': 100,
    'nghìn': 1000,
    'ngàn': 1000,
    'triệu': 1000000,
    'tỷ': 1000000000,
  };
  
  // Transaction Types
  static const String transactionTypeExpense = 'expense';
  static const String transactionTypeIncome = 'income';
  static const String transactionTypeTransfer = 'transfer';
  
  // Time Patterns
  static const Map<String, List<int>> timePatterns = {
    'morning': [6, 7, 8, 9, 10, 11],
    'afternoon': [12, 13, 14, 15, 16, 17],
    'evening': [18, 19, 20, 21],
    'night': [22, 23, 0, 1, 2, 3, 4, 5],
  };
  
  // Day Type Patterns
  static const List<int> weekdays = [1, 2, 3, 4, 5];
  static const List<int> weekends = [6, 7];
  
  // Encryption
  static const String encryptionKeyName = 'ai_spend_os_master_key';
  static const int encryptionKeyLength = 32;
  
  // Cache
  static const int predictionCacheDuration = 3600; // 1 hour in seconds
  static const int maxCacheEntries = 1000;
  
  // Training
  static const int minTransactionsForTraining = 50;
  static const int trainingBatchSize = 32;
  static const int maxEpochs = 10;
  static const double validationSplit = 0.2;
  
  // Voice Assistant
  static const List<String> supportedLanguages = ['vi-VN', 'en-US'];
  static const String defaultLanguage = 'vi-VN';
  
  // Query Intents
  static const String intentTotalSpending = 'total_spending';
  static const String intentCategorySpending = 'category_spending';
  static const String intentBudgetRemaining = 'budget_remaining';
  static const String intentComparison = 'comparison';
  static const String intentProjection = 'projection';
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';
}
