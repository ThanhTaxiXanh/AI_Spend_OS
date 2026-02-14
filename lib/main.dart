import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'services/database/database_service.dart';
import 'core/config/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final db = DatabaseService();
  await db.database; // Ensure database is created
  
  // Setup dependency injection
  await setupDependencies();
  
  runApp(
    const ProviderScope(
      child: AISpendOSApp(),
    ),
  );
}

class AISpendOSApp extends StatelessWidget {
  const AISpendOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Spend OS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
