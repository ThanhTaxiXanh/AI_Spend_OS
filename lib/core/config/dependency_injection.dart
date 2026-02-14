import 'package:get_it/get_it.dart';
import '../services/database/database_service.dart';
import '../ai_engine/parsing/transaction_parser.dart';
import '../ai_engine/reinforcement/reinforcement_engine.dart';
import '../ai_engine/prediction/spending_predictor.dart';
import '../ai_engine/alerts/budget_alert_system.dart';
import '../voice/processor/voice_assistant.dart';
import '../ml/training/training_pipeline.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Database
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
  
  // AI Engine
  getIt.registerLazySingleton<AITransactionParser>(() => AITransactionParser());
  getIt.registerLazySingleton<ReinforcementEngine>(
    () => ReinforcementEngine(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<SpendingPredictor>(
    () => SpendingPredictor(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<BudgetAlertSystem>(
    () => BudgetAlertSystem(
      getIt<DatabaseService>(),
      getIt<SpendingPredictor>(),
    ),
  );
  
  // Voice
  getIt.registerLazySingleton<VoiceAssistant>(
    () => VoiceAssistant(getIt<DatabaseService>()),
  );
  
  // ML Training
  getIt.registerLazySingleton<MLTrainingPipeline>(
    () => MLTrainingPipeline(getIt<DatabaseService>()),
  );
}
