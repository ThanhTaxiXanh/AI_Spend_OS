import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

/// Integration test driver with screenshot capture support
/// 
/// This driver enables screenshot capture during integration tests
/// and saves them to the screenshots directory for artifact upload.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String screenshotName, List<int> screenshotBytes) async {
      // Create screenshots directory if it doesn't exist
      final screenshotsDir = Directory('screenshots');
      if (!await screenshotsDir.exists()) {
        await screenshotsDir.create(recursive: true);
      }

      // Save screenshot with proper naming
      final image = File('${screenshotsDir.path}/$screenshotName.png');
      await image.writeAsBytes(screenshotBytes);
      
      print('Screenshot saved: ${image.path}');
      
      return true;
    },
  );
}
