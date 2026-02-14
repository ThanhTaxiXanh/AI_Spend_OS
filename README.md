# AI Spend OS - Offline-First AI Financial Management System

[![CI/CD](https://github.com/username/ai_spend_os/workflows/Flutter%20CI%20-%20Visual%20Testing%20&%20Web%20Preview/badge.svg)](https://github.com/username/ai_spend_os/actions)

## Overview

AI Spend OS is a production-ready, offline-first financial management application built with Flutter for Android and iOS. It features advanced on-device AI capabilities including self-evolving transaction parsing, spending prediction, intelligent budget alerts, and offline voice assistance.

**🚀 NEW: Complete CI/CD Pipeline Included!**  
This project now includes a fully configured GitHub Actions pipeline with automated testing, screenshot capture, and web deployment. See [CICD_SETUP.md](CICD_SETUP.md) for quick setup.

## Key Features

### 🤖 AI Engine
- **Self-Evolving Transaction Parser**: Automatically categorizes transactions with reinforcement learning
- **Vietnamese Language Support**: Full support for Vietnamese number words and currency
- **Reinforcement Learning**: Adapts to user corrections and improves over time
- **Confidence Scoring**: Provides confidence levels for automatic categorizations

### 📊 Spending Analysis
- **AI Pattern Predictor**: Forecasts future spending using statistical analysis
- **Risk Detection**: Identifies potential budget overruns before they happen
- **Trend Analysis**: Tracks spending patterns over time
- **Category Breakdown**: Detailed analysis by spending category

### 💰 Budget Management
- **Intelligent Alerts**: Predictive warnings when approaching budget limits
- **Smart Suggestions**: Context-aware recommendations to reduce spending
- **Multiple Periods**: Support for monthly, weekly, and custom budget periods
- **Visual Progress**: Real-time budget utilization tracking

### 🎙️ Voice Assistant (Offline)
- **Natural Language Queries**: Ask questions in Vietnamese or English
- **Transaction History**: Query spending by period or category
- **Budget Status**: Check remaining budget via voice
- **Comparisons**: Compare spending across different periods

### 🧠 On-Device Machine Learning
- **Privacy-First**: All ML training happens locally
- **Micro-Training Pipeline**: Lightweight neural network for categorization
- **Idle-Time Training**: Trains during device idle periods
- **Model Versioning**: Tracks model performance over time

### 🔒 Security
- **Local-Only Storage**: No external data transmission
- **Encrypted Database**: SQLite with encryption support
- **Secure Settings**: Protected storage for sensitive configurations

## Architecture

The application follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and constants
│   ├── config/             # Dependency injection
│   ├── constants/          # Application constants
│   ├── errors/             # Error handling
│   └── utils/              # Helper functions
├── features/               # Feature modules
│   ├── dashboard/
│   ├── transactions/
│   ├── budget/
│   ├── reports/
│   ├── insights/
│   └── voice_assistant/
├── ai_engine/              # AI components
│   ├── parsing/            # Transaction parser
│   ├── categorization/     # Category classifier
│   ├── prediction/         # Spending predictor
│   ├── reinforcement/      # Reinforcement learning
│   └── alerts/             # Budget alert system
├── data/                   # Data layer
│   ├── datasources/        # Data sources
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
├── domain/                 # Domain layer
│   ├── entities/           # Business entities
│   └── repositories/       # Repository interfaces
├── presentation/           # Presentation layer
│   ├── screens/            # UI screens
│   ├── widgets/            # Reusable widgets
│   └── theme/              # App theming
├── services/               # Core services
│   ├── database/           # SQLite database
│   ├── voice/              # Voice processing
│   ├── ml/                 # ML services
│   ├── storage/            # Secure storage
│   └── security/           # Security services
├── ml/                     # Machine learning
│   ├── training/           # Training pipeline
│   ├── inference/          # Model inference
│   └── features/           # Feature extraction
└── voice/                  # Voice processing
    ├── stt/                # Speech-to-text
    ├── tts/                # Text-to-speech
    └── processor/          # Voice query processor
```

## Database Schema

### Transactions Table
```sql
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
);
```

### Budgets Table
```sql
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
);
```

### Keyword Weights Table (Reinforcement Learning)
```sql
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
);
```

### Predictions Table
```sql
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
);
```

## Installation

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio or Xcode
- Android SDK 21+ or iOS 12+

### Setup Steps

1. **Clone or extract the project**
```bash
cd ai_spend_os
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate code (if needed)**
```bash
flutter pub run build_runner build
```

4. **Run the app**
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices
flutter run -d <device-id>
```

## CI/CD Pipeline

This project includes a complete GitHub Actions CI/CD pipeline that automatically:

- ✅ Runs all tests on every push and pull request
- ✅ Captures screenshots of all key screens
- ✅ Builds Flutter web version with optimizations
- ✅ Deploys web preview to GitHub Pages
- ✅ Generates APK builds for Android
- ✅ Uploads all artifacts for review

### Quick Setup

1. Enable GitHub Pages in repository settings (source: `gh-pages` branch)
2. Set workflow permissions to "Read and write" in Actions settings
3. Push code to trigger the pipeline
4. Access web preview at `https://[username].github.io/ai_spend_os/`

For complete setup instructions, see [CICD_SETUP.md](CICD_SETUP.md).

### Web Preview

Try the live web version (deployed automatically via CI/CD):

**Preview URL:** `https://[your-username].github.io/ai_spend_os/`

The web preview updates automatically on every push to main or develop branches.

## Configuration

### Android Configuration

File: `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### iOS Configuration

File: `ios/Podfile`

```ruby
platform :ios, '12.0'
```

### Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for voice input</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>We need speech recognition for voice commands</string>
```

## AI Engine Components

### Transaction Parser

The parser handles natural language input in both Vietnamese and English:

```dart
// Example usage
final parser = AITransactionParser();
final result = await parser.parse('Chi 50k cho cafe sáng nay');
// Result: type=expense, amount=50000, category=Food & Dining
```

### Reinforcement Learning

The system learns from user corrections:

```dart
final engine = ReinforcementEngine(database);
await engine.learnFromCorrection(
  originalText: 'Chi 100k cafe',
  predictedCategory: 'Shopping',
  correctCategory: 'Food & Dining',
);
```

### Spending Predictor

Forecasts future spending using multiple algorithms:

```dart
final predictor = SpendingPredictor(database);
final prediction = await predictor.predictSpending(
  category: 'Food & Dining',
  periodStart: DateTime.now(),
  periodEnd: DateTime.now().add(Duration(days: 30)),
);
```

### Budget Alert System

Generates intelligent alerts:

```dart
final alertSystem = BudgetAlertSystem(database, predictor);
final alerts = await alertSystem.checkBudgets();
// Returns list of alerts with severity and suggestions
```

### Voice Assistant

Processes natural language queries:

```dart
final assistant = VoiceAssistant(database);
final result = await assistant.processQuery('Tháng này tôi đã chi bao nhiêu?');
// Returns formatted response in Vietnamese
```

## Machine Learning Pipeline

### Training

The on-device ML pipeline trains a lightweight neural network:

```dart
final pipeline = MLTrainingPipeline(database);
final success = await pipeline.trainModel();
```

### Feature Extraction

Features extracted for each transaction:
- Amount (normalized and log-transformed)
- Time features (hour, day, month)
- Text features (keyword matching)
- Transaction type
- Historical patterns

### Model Architecture

- Input layer: 20 features
- Hidden layer: 15 neurons with sigmoid activation
- Output layer: 12 categories (one-hot encoded)
- Learning rate: 0.001
- Training epochs: 10

## Voice Processing

### Speech-to-Text

Uses the `speech_to_text` plugin for offline STT. For production deployment with Whisper.cpp:

1. Download Whisper tiny model
2. Place in `assets/models/`
3. Implement native bridge in `android/` and `ios/`
4. Use FFI to call Whisper C++ library

### Text-to-Speech

Uses `flutter_tts` for offline voice responses in Vietnamese and English.

## Testing

### Run Unit Tests
```bash
flutter test
```

### Run Integration Tests
```bash
flutter test integration_test
```

### Generate Coverage
```bash
flutter test --coverage
```

## Performance Optimization

- Database queries use indexes for fast lookup
- Predictions are cached for 1 hour
- ML training runs during idle time
- UI updates use efficient state management (Riverpod)
- Images and assets are optimized

## Deployment

### Android Release Build
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS Release Build
```bash
flutter build ios --release
```

## Troubleshooting

### Database Issues
- Check write permissions
- Verify database path
- Clear app data and reinstall

### ML Training Fails
- Ensure at least 50 verified transactions
- Check available storage
- Review logs for specific errors

### Voice Recognition Not Working
- Verify microphone permissions
- Check device compatibility
- Test with different phrases

## Future Enhancements

- Multi-currency support
- Receipt OCR scanning
- Expense sharing between users
- Export to CSV/PDF
- Cloud backup (optional, encrypted)
- Widget support
- Wear OS companion app

## CI/CD Documentation

Complete documentation for the automated pipeline:

- **[CICD_SETUP.md](CICD_SETUP.md)** - Quick 5-minute setup guide
- **[GITHUB_PAGES_SETUP.md](GITHUB_PAGES_SETUP.md)** - GitHub Pages configuration
- **[REPOSITORY_SETUP.md](REPOSITORY_SETUP.md)** - Complete repository setup
- **[CI_CD_QUICK_REFERENCE.md](CI_CD_QUICK_REFERENCE.md)** - Daily operations reference
- **[CICD_DELIVERY_SUMMARY.md](CICD_DELIVERY_SUMMARY.md)** - Architecture overview

## Testing

### Unit Tests
```bash
flutter test --coverage
```

### Integration Tests
```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

### Code Analysis
```bash
flutter analyze
```

The CI/CD pipeline automatically runs all tests on every push and pull request.

## Contributing

This is a production-ready template. Feel free to:
- Add new categories
- Improve ML models
- Enhance UI/UX
- Add new languages
- Optimize performance

## License

This project is provided as-is for educational and commercial use.

## Support

For issues or questions:
1. Check the documentation
2. Review the code comments
3. Test with sample data
4. Enable debug logging

## Version History

### v1.0.0 (Initial Release)
- Complete offline-first architecture
- AI transaction parsing with Vietnamese support
- Reinforcement learning for categorization
- Spending prediction engine
- Intelligent budget alerts
- Voice assistant
- On-device ML training
- Secure encrypted storage

---

**AI Spend OS** - Intelligent Financial Management, Powered by On-Device AI
