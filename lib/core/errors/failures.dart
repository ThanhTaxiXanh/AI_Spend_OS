import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final int? code;
  
  const Failure(this.message, [this.code]);
  
  @override
  List<Object?> get props => [message, code];
}

/// Database related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.code]);
}

/// ML Model related failures
class MLFailure extends Failure {
  const MLFailure(super.message, [super.code]);
}

/// Voice processing failures
class VoiceFailure extends Failure {
  const VoiceFailure(super.message, [super.code]);
}

/// Parsing failures
class ParsingFailure extends Failure {
  const ParsingFailure(super.message, [super.code]);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

/// Storage failures
class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.code]);
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, [super.code]);
}

/// Network failures (should not occur in offline-first, but included for completeness)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/// Encryption failures
class EncryptionFailure extends Failure {
  const EncryptionFailure(super.message, [super.code]);
}

/// Training failures
class TrainingFailure extends Failure {
  const TrainingFailure(super.message, [super.code]);
}

/// Prediction failures
class PredictionFailure extends Failure {
  const PredictionFailure(super.message, [super.code]);
}

/// Generic unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.code]);
}
