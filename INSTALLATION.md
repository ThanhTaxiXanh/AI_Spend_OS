# AI Spend OS - Complete Installation Guide

## System Requirements

### Development Environment
- **Operating System**: Windows 10+, macOS 10.14+, or Linux
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: Minimum 10GB free space
- **Internet**: Required for initial setup only

### Software Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio (for Android development)
- Xcode 12+ (for iOS development, macOS only)
- Git (recommended)

### Target Devices
- **Android**: API Level 21 (Android 5.0) or higher
- **iOS**: iOS 12.0 or higher

## Installation Steps

### 1. Install Flutter

#### Windows
```powershell
# Download Flutter SDK from https://flutter.dev
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

# Verify installation
flutter doctor
```

#### macOS
```bash
# Using Homebrew
brew install flutter

# Or download from https://flutter.dev
# Extract and add to PATH in ~/.zshrc or ~/.bash_profile
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### Linux
```bash
# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.0.0-stable.tar.xz

# Extract
tar xf flutter_linux_3.0.0-stable.tar.xz

# Add to PATH in ~/.bashrc
export PATH="$PATH:$HOME/flutter/bin"

# Verify installation
flutter doctor
```

### 2. Setup Android Development (Optional, for Android builds)

```bash
# Install Android Studio from https://developer.android.com/studio
# During installation, ensure Android SDK is installed
# Accept Android licenses
flutter doctor --android-licenses
```

### 3. Setup iOS Development (macOS only, for iOS builds)

```bash
# Install Xcode from App Store
# Install Xcode command line tools
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Install CocoaPods
sudo gem install cocoapods
```

### 4. Extract AI Spend OS Project

```bash
# Extract the ai_spend_os.zip file
# Navigate to the project directory
cd ai_spend_os
```

### 5. Install Project Dependencies

```bash
# Install Flutter packages
flutter pub get

# This will download all required dependencies:
# - flutter_riverpod (state management)
# - sqflite (database)
# - tflite_flutter (ML)
# - speech_to_text (voice)
# - And many more...
```

### 6. Verify Setup

```bash
# Check for issues
flutter doctor -v

# Expected output: All checkmarks or minor warnings
```

### 7. Run the Application

#### On Android Emulator
```bash
# Start Android emulator from Android Studio
# Or create one: flutter emulators
# Launch it: flutter emulators --launch <emulator_id>

# Run app
flutter run
```

#### On iOS Simulator (macOS only)
```bash
# Open iOS Simulator
open -a Simulator

# Run app
flutter run -d ios
```

#### On Physical Device
```bash
# For Android:
# 1. Enable Developer Options on device
# 2. Enable USB Debugging
# 3. Connect via USB
# 4. Run: flutter run

# For iOS:
# 1. Connect device
# 2. Trust computer
# 3. Run: flutter run -d <device-id>
# 4. May require Apple Developer account for first install
```

## Post-Installation Setup

### Configure Database
The database is created automatically on first launch at:
- **Android**: `/data/data/com.aispendos.ai_spend_os/databases/ai_spend_os.db`
- **iOS**: `~/Library/Application Support/ai_spend_os.db`

### Grant Permissions
On first launch, the app will request:
- **Microphone access** (for voice input)
- **Storage access** (for database)

Accept these permissions for full functionality.

### Initial Configuration
1. Launch the app
2. The database schema is created automatically
3. Default categories are available immediately
4. Start adding transactions to train the AI

## Building for Production

### Android Release Build

#### Generate Keystore
```bash
keytool -genkey -v -keystore ~/ai-spend-os-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ai-spend-os
```

#### Configure Signing
Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=ai-spend-os
storeFile=<path-to-jks-file>
```

#### Build APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Build App Bundle (for Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS Release Build

#### Configure in Xcode
```bash
# Open project in Xcode
open ios/Runner.xcworkspace

# Configure:
# 1. Team (Apple Developer account)
# 2. Bundle Identifier
# 3. Version and Build numbers
# 4. Signing certificates
```

#### Build for Release
```bash
flutter build ios --release

# Archive in Xcode for App Store submission
# Product > Archive
```

## Troubleshooting

### Issue: Flutter doctor shows errors
**Solution**: Follow the specific recommendations from `flutter doctor -v`

### Issue: Pub get fails
**Solution**:
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### Issue: Build errors on Android
**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter build apk
```

### Issue: iOS build fails
**Solution**:
```bash
cd ios
pod repo update
pod install
cd ..
flutter clean
flutter build ios
```

### Issue: Permission denied on Linux/macOS
**Solution**:
```bash
chmod +x android/gradlew
chmod +x ios/Pods/
```

### Issue: Database not creating
**Solution**: 
- Check storage permissions
- Verify path_provider package is installed
- Clear app data and reinstall

### Issue: ML features not working
**Solution**:
- Ensure tflite_flutter is properly installed
- Check that assets are included in pubspec.yaml
- Verify Android/iOS minimum versions

## Performance Optimization

### Release Mode
Always test and deploy in release mode:
```bash
flutter run --release
flutter build apk --release
flutter build ios --release
```

### Reduce App Size
```bash
# Use app bundle for Android
flutter build appbundle --target-platform android-arm,android-arm64

# Split APKs
flutter build apk --split-per-abi
```

### Enable Obfuscation
```bash
flutter build apk --obfuscate --split-debug-info=/<project-dir>/symbols
flutter build ios --obfuscate --split-debug-info=/<project-dir>/symbols
```

## Maintenance

### Update Dependencies
```bash
flutter pub upgrade
flutter pub outdated
```

### Run Tests
```bash
flutter test
flutter test --coverage
```

### Code Analysis
```bash
flutter analyze
dart format .
```

## Additional Resources

- Flutter Documentation: https://flutter.dev/docs
- AI Spend OS README: See README.md
- Project Structure: See PROJECT_STRUCTURE.md
- Quick Start: See QUICKSTART.md

## Support Checklist

Before reporting issues:
- [ ] Run `flutter doctor -v`
- [ ] Check Flutter and Dart versions
- [ ] Verify all dependencies installed
- [ ] Clear build and reinstall
- [ ] Test on different device/emulator
- [ ] Review error logs
- [ ] Check permissions granted

---

**Complete installation guide for AI Spend OS development and deployment**
