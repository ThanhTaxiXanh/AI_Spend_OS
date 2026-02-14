import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Screenshot Helper Utilities
/// 
/// Provides reusable functions for capturing screenshots during integration tests
/// with proper error handling and file management.

class ScreenshotHelper {
  static const String screenshotsDirectory = 'screenshots';
  static int _screenshotCounter = 0;

  /// Initialize screenshots directory and clear old files
  static Future<void> initialize() async {
    final dir = Directory(screenshotsDirectory);
    
    if (await dir.exists()) {
      // Clear existing screenshots
      await for (final file in dir.list()) {
        if (file is File && file.path.endsWith('.png')) {
          await file.delete();
        }
      }
    } else {
      await dir.create(recursive: true);
    }
    
    _screenshotCounter = 0;
    print('Screenshot helper initialized. Directory: ${dir.absolute.path}');
  }

  /// Capture screenshot with automatic numbering and metadata
  static Future<void> capture(
    IntegrationTestWidgetsFlutterBinding binding,
    WidgetTester tester, {
    required String name,
    String? description,
    Duration? waitBefore,
    Duration? waitAfter,
  }) async {
    try {
      // Wait before capturing if specified
      if (waitBefore != null) {
        await Future.delayed(waitBefore);
        await tester.pumpAndSettle();
      }

      // Generate filename with counter for ordering
      _screenshotCounter++;
      final filename = '${_screenshotCounter.toString().padLeft(2, '0')}_$name';

      // Capture the screenshot
      await binding.takeScreenshot(filename);

      // Log capture
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] Screenshot captured: $filename.png');
      if (description != null) {
        print('  Description: $description');
      }

      // Wait after capturing if specified
      if (waitAfter != null) {
        await Future.delayed(waitAfter);
      }
    } catch (e, stackTrace) {
      print('Error capturing screenshot "$name": $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Capture screenshot of current screen state
  static Future<void> captureCurrentScreen(
    IntegrationTestWidgetsFlutterBinding binding,
    WidgetTester tester,
    String screenName, {
    String? description,
  }) async {
    await capture(
      binding,
      tester,
      name: screenName,
      description: description,
      waitBefore: const Duration(milliseconds: 500),
      waitAfter: const Duration(milliseconds: 200),
    );
  }

  /// Capture screenshot after navigation
  static Future<void> captureAfterNavigation(
    IntegrationTestWidgetsFlutterBinding binding,
    WidgetTester tester,
    String screenName, {
    String? description,
    Duration settleTime = const Duration(seconds: 2),
  }) async {
    await tester.pumpAndSettle(settleTime);
    await captureCurrentScreen(
      binding,
      tester,
      screenName,
      description: description,
    );
  }

  /// Capture multiple screenshots in sequence
  static Future<void> captureSequence(
    IntegrationTestWidgetsFlutterBinding binding,
    WidgetTester tester,
    List<ScreenshotSpec> specs,
  ) async {
    for (final spec in specs) {
      await capture(
        binding,
        tester,
        name: spec.name,
        description: spec.description,
        waitBefore: spec.waitBefore,
        waitAfter: spec.waitAfter,
      );
    }
  }

  /// Get total screenshots captured
  static int get capturedCount => _screenshotCounter;

  /// Verify screenshots directory and count
  static Future<int> verifyScreenshots() async {
    final dir = Directory(screenshotsDirectory);
    
    if (!await dir.exists()) {
      print('Warning: Screenshots directory does not exist');
      return 0;
    }

    int count = 0;
    await for (final file in dir.list()) {
      if (file is File && file.path.endsWith('.png')) {
        count++;
        final stat = await file.stat();
        print('  ${file.path.split('/').last} - ${(stat.size / 1024).toStringAsFixed(2)} KB');
      }
    }

    print('Total screenshots verified: $count');
    return count;
  }

  /// Create metadata file for screenshots
  static Future<void> createMetadata(Map<String, dynamic> testInfo) async {
    final metadataFile = File('$screenshotsDirectory/metadata.json');
    
    final metadata = {
      'test_run': testInfo,
      'screenshots_count': _screenshotCounter,
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
    };

    await metadataFile.writeAsString(
      _formatJson(metadata),
    );

    print('Metadata file created: ${metadataFile.path}');
  }

  static String _formatJson(Map<String, dynamic> json) {
    final buffer = StringBuffer();
    buffer.writeln('{');
    
    final entries = json.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isLast = i == entries.length - 1;
      
      buffer.write('  "${entry.key}": ');
      if (entry.value is String) {
        buffer.write('"${entry.value}"');
      } else if (entry.value is Map) {
        buffer.write('${entry.value}');
      } else {
        buffer.write('${entry.value}');
      }
      
      if (!isLast) buffer.write(',');
      buffer.writeln();
    }
    
    buffer.writeln('}');
    return buffer.toString();
  }
}

/// Screenshot specification for batch capture
class ScreenshotSpec {
  final String name;
  final String? description;
  final Duration? waitBefore;
  final Duration? waitAfter;

  const ScreenshotSpec({
    required this.name,
    this.description,
    this.waitBefore,
    this.waitAfter,
  });
}

/// Widget finder extensions for common UI patterns
extension ScreenshotFinderExtensions on CommonFinders {
  /// Find by text with fuzzy matching
  Finder textContaining(String text) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data != null &&
          widget.data!.toLowerCase().contains(text.toLowerCase()),
    );
  }

  /// Find card widgets
  Finder get cards => find.byType(Card);

  /// Find buttons
  Finder get buttons => find.byType(ElevatedButton);

  /// Find navigation bars
  Finder get navigationBar => find.byType(BottomNavigationBar);
}

/// Test navigation helpers
class NavigationHelper {
  /// Navigate to screen and capture
  static Future<void> navigateAndCapture(
    WidgetTester tester,
    IntegrationTestWidgetsFlutterBinding binding,
    Finder destination,
    String screenshotName, {
    String? description,
  }) async {
    if (destination.evaluate().isNotEmpty) {
      await tester.tap(destination);
      await ScreenshotHelper.captureAfterNavigation(
        binding,
        tester,
        screenshotName,
        description: description,
      );
    } else {
      print('Warning: Navigation destination not found for $screenshotName');
    }
  }

  /// Navigate back to previous screen
  static Future<void> navigateBack(WidgetTester tester) async {
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    } else {
      // Fallback to Navigator.pop
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      if (navigator.canPop()) {
        navigator.pop();
        await tester.pumpAndSettle();
      }
    }
  }

  /// Navigate to bottom navigation item
  static Future<void> navigateToTab(
    WidgetTester tester,
    IntegrationTestWidgetsFlutterBinding binding,
    IconData icon,
    String screenshotName, {
    String? description,
  }) async {
    final bottomNavBar = find.byType(BottomNavigationBar);
    
    if (bottomNavBar.evaluate().isEmpty) {
      print('Warning: Bottom navigation bar not found');
      return;
    }

    final tab = find.descendant(
      of: bottomNavBar,
      matching: find.byIcon(icon),
    );

    await navigateAndCapture(
      tester,
      binding,
      tab,
      screenshotName,
      description: description,
    );
  }
}
