import 'dart:math';
import 'package:logger/logger.dart';
import '../../core/constants/app_constants.dart';
import '../../services/database/database_service.dart';

/// Feature vector for transaction classification
class TransactionFeatures {
  final List<double> features;
  final String label;

  TransactionFeatures(this.features, this.label);
}

/// Simple neural network for on-device training
class SimpleNeuralNetwork {
  List<List<double>> weightsInputHidden = [];
  List<List<double>> weightsHiddenOutput = [];
  List<double> biasHidden = [];
  List<double> biasOutput = [];
  
  final int inputSize;
  final int hiddenSize;
  final int outputSize;
  final double learningRate;
  
  SimpleNeuralNetwork({
    required this.inputSize,
    required this.hiddenSize,
    required this.outputSize,
    this.learningRate = 0.01,
  }) {
    _initializeWeights();
  }

  void _initializeWeights() {
    final random = Random();
    
    // Initialize input to hidden weights
    weightsInputHidden = List.generate(
      inputSize,
      (i) => List.generate(hiddenSize, (j) => random.nextDouble() * 2 - 1),
    );
    
    // Initialize hidden to output weights
    weightsHiddenOutput = List.generate(
      hiddenSize,
      (i) => List.generate(outputSize, (j) => random.nextDouble() * 2 - 1),
    );
    
    // Initialize biases
    biasHidden = List.generate(hiddenSize, (i) => 0.0);
    biasOutput = List.generate(outputSize, (i) => 0.0);
  }

  List<double> forward(List<double> input) {
    // Hidden layer
    final hidden = List<double>.filled(hiddenSize, 0.0);
    for (int j = 0; j < hiddenSize; j++) {
      double sum = biasHidden[j];
      for (int i = 0; i < inputSize; i++) {
        sum += input[i] * weightsInputHidden[i][j];
      }
      hidden[j] = _sigmoid(sum);
    }
    
    // Output layer
    final output = List<double>.filled(outputSize, 0.0);
    for (int j = 0; j < outputSize; j++) {
      double sum = biasOutput[j];
      for (int i = 0; i < hiddenSize; i++) {
        sum += hidden[i] * weightsHiddenOutput[i][j];
      }
      output[j] = _sigmoid(sum);
    }
    
    return output;
  }

  double _sigmoid(double x) {
    return 1 / (1 + exp(-x));
  }

  void train(List<double> input, List<double> target) {
    // Forward pass
    final hidden = List<double>.filled(hiddenSize, 0.0);
    for (int j = 0; j < hiddenSize; j++) {
      double sum = biasHidden[j];
      for (int i = 0; i < inputSize; i++) {
        sum += input[i] * weightsInputHidden[i][j];
      }
      hidden[j] = _sigmoid(sum);
    }
    
    final output = forward(input);
    
    // Calculate output errors
    final outputErrors = List<double>.filled(outputSize, 0.0);
    for (int i = 0; i < outputSize; i++) {
      outputErrors[i] = (target[i] - output[i]) * output[i] * (1 - output[i]);
    }
    
    // Calculate hidden errors
    final hiddenErrors = List<double>.filled(hiddenSize, 0.0);
    for (int i = 0; i < hiddenSize; i++) {
      double error = 0;
      for (int j = 0; j < outputSize; j++) {
        error += outputErrors[j] * weightsHiddenOutput[i][j];
      }
      hiddenErrors[i] = error * hidden[i] * (1 - hidden[i]);
    }
    
    // Update weights and biases
    for (int i = 0; i < hiddenSize; i++) {
      for (int j = 0; j < outputSize; j++) {
        weightsHiddenOutput[i][j] += learningRate * outputErrors[j] * hidden[i];
      }
      biasOutput[i] += learningRate * outputErrors[i];
    }
    
    for (int i = 0; i < inputSize; i++) {
      for (int j = 0; j < hiddenSize; j++) {
        weightsInputHidden[i][j] += learningRate * hiddenErrors[j] * input[i];
      }
    }
    
    for (int i = 0; i < hiddenSize; i++) {
      biasHidden[i] += learningRate * hiddenErrors[i];
    }
  }
}

/// Micro-ML On-Device Training Pipeline
class MLTrainingPipeline {
  final DatabaseService _db;
  final Logger _logger = Logger();
  
  SimpleNeuralNetwork? _model;
  final List<String> _categories = AppConstants.defaultCategories;

  MLTrainingPipeline(this._db);

  /// Train model on historical transactions
  Future<bool> trainModel() async {
    try {
      _logger.i('Starting on-device ML training');
      
      // Check if we have enough data
      final transactions = await _db.queryTransactions(limit: 1000);
      
      if (transactions.length < AppConstants.minTransactionsForTraining) {
        _logger.w('Not enough transactions for training: ${transactions.length}');
        return false;
      }
      
      // Extract features from transactions
      final trainingData = await _extractTrainingData(transactions);
      
      // Initialize model
      _model = SimpleNeuralNetwork(
        inputSize: 20, // Feature vector size
        hiddenSize: 15,
        outputSize: _categories.length,
        learningRate: AppConstants.learningRate,
      );
      
      // Training loop
      for (int epoch = 0; epoch < AppConstants.maxEpochs; epoch++) {
        double totalLoss = 0;
        
        for (final sample in trainingData) {
          // Create one-hot target
          final target = List<double>.filled(_categories.length, 0.0);
          final categoryIndex = _categories.indexOf(sample.label);
          if (categoryIndex >= 0) {
            target[categoryIndex] = 1.0;
          }
          
          // Train
          _model!.train(sample.features, target);
          
          // Calculate loss
          final output = _model!.forward(sample.features);
          for (int i = 0; i < output.length; i++) {
            totalLoss += (target[i] - output[i]) * (target[i] - output[i]);
          }
        }
        
        _logger.i('Epoch $epoch, Loss: ${totalLoss / trainingData.length}');
      }
      
      // Save model metadata
      await _saveModelMetadata(trainingData.length);
      
      _logger.i('Training completed successfully');
      return true;
    } catch (e) {
      _logger.e('Training failed: $e');
      return false;
    }
  }

  /// Extract training data from transactions
  Future<List<TransactionFeatures>> _extractTrainingData(
    List<Map<String, dynamic>> transactions,
  ) async {
    final trainingData = <TransactionFeatures>[];
    
    for (final tx in transactions) {
      if (tx['is_verified'] == 1) {
        final features = _extractFeatures(tx);
        final label = tx['category'] as String;
        trainingData.add(TransactionFeatures(features, label));
      }
    }
    
    return trainingData;
  }

  /// Extract feature vector from transaction
  List<double> _extractFeatures(Map<String, dynamic> transaction) {
    final features = <double>[];
    
    // Amount features
    final amount = transaction['amount'] as double;
    features.add(_normalizeAmount(amount));
    features.add(_logAmount(amount));
    
    // Time features
    final timestamp = DateTime.fromMillisecondsSinceEpoch(transaction['timestamp'] as int);
    features.add(timestamp.hour / 24.0);
    features.add(timestamp.weekday / 7.0);
    features.add(timestamp.day / 31.0);
    features.add(timestamp.month / 12.0);
    
    // Text features (simple bag of words)
    final description = (transaction['description'] as String).toLowerCase();
    final keywords = ['food', 'transport', 'shop', 'bill', 'health', 'edu'];
    for (final keyword in keywords) {
      features.add(description.contains(keyword) ? 1.0 : 0.0);
    }
    
    // Type feature
    final type = transaction['type'] as String;
    features.add(type == 'expense' ? 1.0 : 0.0);
    features.add(type == 'income' ? 1.0 : 0.0);
    
    // Padding to fixed size
    while (features.length < 20) {
      features.add(0.0);
    }
    
    return features.take(20).toList();
  }

  double _normalizeAmount(double amount) {
    return min(amount / 1000000, 1.0); // Normalize to millions
  }

  double _logAmount(double amount) {
    return log(amount + 1) / log(1000000);
  }

  /// Predict category using trained model
  Future<Map<String, double>> predict(Map<String, dynamic> transaction) async {
    if (_model == null) {
      throw Exception('Model not trained');
    }
    
    final features = _extractFeatures(transaction);
    final output = _model!.forward(features);
    
    final predictions = <String, double>{};
    for (int i = 0; i < _categories.length; i++) {
      predictions[_categories[i]] = output[i];
    }
    
    return predictions;
  }

  /// Save model metadata
  Future<void> _saveModelMetadata(int sampleCount) async {
    await _db.insertMLMetadata({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'model_name': 'category_classifier',
      'model_version': '1.0',
      'training_date': DateTime.now().millisecondsSinceEpoch,
      'accuracy': 0.85, // Placeholder
      'samples_count': sampleCount,
      'feature_count': 20,
      'hyperparameters': 'lr=0.01,hidden=15',
      'is_active': 1,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Trigger training during idle time
  Future<void> scheduleTraining() async {
    _logger.i('Scheduling background training');
    // In production, this would use WorkManager or similar
    // For now, just train immediately
    await trainModel();
  }
}
