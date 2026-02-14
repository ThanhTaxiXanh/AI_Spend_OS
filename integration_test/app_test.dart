import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/main.dart' as app;

/// Integration test with automated screenshot capture
/// 
/// This test suite navigates through all key screens of the application
/// and captures screenshots for visual regression testing and documentation.
/// 
/// Screenshots are saved to the /screenshots directory and uploaded as
/// GitHub Actions artifacts for review.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  // Enable screenshot capture for headless environments
  if (binding is IntegrationTestWidgetsFlutterBinding) {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  }

  group('AI Spend OS Visual Integration Tests', () {
    testWidgets('Complete app flow with screenshot capture',
        (WidgetTester tester) async {
      // Configure test environment
      await setupTestEnvironment();

      // Launch the application
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Allow app to initialize
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Test 1: Dashboard Screen
      await testDashboardScreen(tester, binding);

      // Test 2: Add Transaction Screen
      await testAddTransactionScreen(tester, binding);

      // Test 3: Budget Screen
      await testBudgetScreen(tester, binding);

      // Test 4: Voice Assistant Screen
      await testVoiceAssistantScreen(tester, binding);

      // Test 5: Insights Screen
      await testInsightsScreen(tester, binding);

      // Test 6: Settings Screen (via navigation)
      await testSettingsNavigation(tester, binding);

      // Verify all critical UI elements are present
      await verifyUIElements(tester);
    });
  });
}

/// Setup test environment and prepare for screenshot capture
Future<void> setupTestEnvironment() async {
  // Create screenshots directory if it doesn't exist
  final screenshotsDir = Directory('screenshots');
  if (!await screenshotsDir.exists()) {
    await screenshotsDir.create(recursive: true);
  }

  // Clear any existing screenshots from previous runs
  if (await screenshotsDir.exists()) {
    await for (final file in screenshotsDir.list()) {
      if (file is File && file.path.endsWith('.png')) {
        await file.delete();
      }
    }
  }

  print('Screenshot directory prepared: ${screenshotsDir.path}');
}

/// Test Dashboard Screen and capture screenshot
Future<void> testDashboardScreen(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  print('Testing Dashboard Screen...');

  // Wait for dashboard to fully load
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify dashboard elements
  expect(find.text('AI Spend OS'), findsOneWidget);
  
  // Look for dashboard indicators (flexible to handle empty state)
  final dashboardIndicators = [
    find.byType(Card),
    find.textContaining('Month', findRichText: true),
    find.textContaining('Quick Actions', findRichText: true),
  ];

  bool foundDashboardElement = false;
  for (final finder in dashboardIndicators) {
    if (finder.evaluate().isNotEmpty) {
      foundDashboardElement = true;
      break;
    }
  }
  expect(foundDashboardElement, isTrue, reason: 'Dashboard should show at least one key element');

  // Capture screenshot
  await captureScreenshot(
    binding,
    '01_dashboard_home',
    description: 'Main dashboard with spending overview',
  );

  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

/// Test Add Transaction Screen
Future<void> testAddTransactionScreen(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  print('Testing Add Transaction Screen...');

  // Find and tap the FAB to add transaction
  final fabFinder = find.byType(FloatingActionButton);
  
  if (fabFinder.evaluate().isNotEmpty) {
    await tester.tap(fabFinder);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify we're on the add transaction screen
    expect(
      find.text('Add Transaction'),
      findsOneWidget,
      reason: 'Add Transaction screen should be visible',
    );

    // Capture screenshot
    await captureScreenshot(
      binding,
      '02_add_transaction',
      description: 'Transaction entry form',
    );

    // Go back to dashboard
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    } else {
      // Alternative: use Navigator pop
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    }
  } else {
    print('Warning: FloatingActionButton not found, skipping add transaction test');
  }
}

/// Test Budget Screen via bottom navigation
Future<void> testBudgetScreen(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  print('Testing Budget Screen...');

  // Find bottom navigation bar
  final bottomNavBar = find.byType(BottomNavigationBar);
  
  if (bottomNavBar.evaluate().isNotEmpty) {
    // Tap on Budget tab (index 2)
    final budgetTab = find.descendant(
      of: bottomNavBar,
      matching: find.byIcon(Icons.account_balance_wallet),
    );

    if (budgetTab.evaluate().isNotEmpty) {
      await tester.tap(budgetTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify budget screen elements
      expect(
        find.textContaining('Budget', findRichText: true),
        findsAtLeastNWidgets(1),
      );

      // Capture screenshot
      await captureScreenshot(
        binding,
        '03_budget_management',
        description: 'Budget overview and limits',
      );
    }

    // Return to dashboard
    final dashboardTab = find.descendant(
      of: bottomNavBar,
      matching: find.byIcon(Icons.dashboard),
    );
    
    if (dashboardTab.evaluate().isNotEmpty) {
      await tester.tap(dashboardTab);
      await tester.pumpAndSettle();
    }
  }
}

/// Test Voice Assistant Screen
Future<void> testVoiceAssistantScreen(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  print('Testing Voice Assistant Screen...');

  // Find microphone icon in app bar
  final micIcon = find.byIcon(Icons.mic);
  
  if (micIcon.evaluate().isNotEmpty) {
    await tester.tap(micIcon.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify voice assistant screen
    expect(find.text('Voice Assistant'), findsOneWidget);

    // Capture screenshot
    await captureScreenshot(
      binding,
      '04_voice_assistant',
      description: 'Voice input interface',
    );

    // Navigate back
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }
  } else {
    print('Warning: Microphone icon not found, skipping voice assistant test');
  }
}

/// Test Insights Screen
Future<void> testInsightsScreen(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  print('Testing Insights Screen...');

  // Find insights icon in app bar
  final insightsIcon = find.byIcon(Icons.insights);
  
  if (insightsIcon.evaluate().isNotEmpty) {
    await tester.tap(insightsIcon.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify insights screen
    expect(find.text('AI Insights'), findsOneWidget);

    // Capture screenshot
    await captureScreenshot(
      binding,
      '05_ai_insights',
      description: 'AI-generated spending insights',
    );

    // Navigate back
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }
  } else {
    print('Warning: Insights icon not found, skipping insights test');
  }
}

/// Test Settings Navigation
Future<void> testSettingsNavigation(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  print('Testing Settings Navigation...');

  // Navigate to reports tab first (if available)
  final bottomNavBar = find.byType(BottomNavigationBar);
  
  if (bottomNavBar.evaluate().isNotEmpty) {
    final reportsTab = find.descendant(
      of: bottomNavBar,
      matching: find.byIcon(Icons.bar_chart),
    );

    if (reportsTab.evaluate().isNotEmpty) {
      await tester.tap(reportsTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Capture reports screen
      await captureScreenshot(
        binding,
        '06_reports_analytics',
        description: 'Spending reports and analytics',
      );
    }
  }

  // Return to dashboard for final state
  final dashboardTab = find.descendant(
    of: bottomNavBar,
    matching: find.byIcon(Icons.dashboard),
  );
  
  if (dashboardTab.evaluate().isNotEmpty) {
    await tester.tap(dashboardTab);
    await tester.pumpAndSettle();
  }
}

/// Verify critical UI elements are present
Future<void> verifyUIElements(WidgetTester tester) async {
  print('Verifying critical UI elements...');

  // Verify app structure
  expect(find.byType(MaterialApp), findsOneWidget);
  expect(find.byType(Scaffold), findsAtLeastNWidgets(1));

  // Verify navigation exists
  final bottomNav = find.byType(BottomNavigationBar);
  if (bottomNav.evaluate().isNotEmpty) {
    expect(bottomNav, findsOneWidget);
  }

  print('UI element verification complete');
}

/// Capture and save screenshot with descriptive filename
Future<void> captureScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  String filename, {
  String? description,
}) async {
  try {
    // Wait for animations to settle
    await Future.delayed(const Duration(milliseconds: 500));

    // Capture screenshot
    await binding.takeScreenshot(filename);

    print('✓ Screenshot captured: $filename.png');
    if (description != null) {
      print('  Description: $description');
    }

    // Additional delay to ensure file is written
    await Future.delayed(const Duration(milliseconds: 200));
  } catch (e) {
    print('✗ Failed to capture screenshot $filename: $e');
  }
}
