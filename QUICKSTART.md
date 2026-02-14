# AI Spend OS - Quick Start Guide

## 5-Minute Setup

### Step 1: Prerequisites
Ensure you have Flutter installed. If not:
```bash
# Visit https://flutter.dev/docs/get-started/install
# Or run:
flutter doctor
```

### Step 2: Extract & Navigate
```bash
cd ai_spend_os
```

### Step 3: Install Dependencies
```bash
flutter pub get
```

### Step 4: Run the App
```bash
# See available devices
flutter devices

# Run on connected device
flutter run
```

## First Use

1. **Dashboard** - View spending summary and quick actions
2. **Add Transaction** - Tap + button to manually add a transaction
3. **Voice Input** - Tap microphone icon for voice-based entry
4. **Budget** - Set up monthly budgets for different categories
5. **Insights** - View AI-generated spending insights

## Testing the AI Features

### Test Transaction Parser
Try adding these voice inputs:
- "Chi 50 nghìn cafe sáng nay"
- "Mua bánh mì 20k"
- "Đổ xăng 300 nghìn đồng"

### Test Voice Assistant
Ask these questions:
- "Tháng này tôi đã chi bao nhiêu?"
- "So với tháng trước thì sao?"
- "Tôi còn bao nhiêu ngân sách?"

### View AI Insights
Navigate to Insights screen to see:
- Spending trends
- Smart suggestions
- Predictive alerts

## Building for Release

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
# Open in Xcode for submission
```

## Troubleshooting

**Issue**: Dependencies not installing
**Solution**: Run `flutter clean` then `flutter pub get`

**Issue**: Build errors
**Solution**: Check Flutter and Dart SDK versions (3.0.0+)

**Issue**: Database errors
**Solution**: Clear app data or uninstall/reinstall

**Issue**: Voice not working
**Solution**: Grant microphone permissions in device settings

## Configuration

Edit `lib/core/constants/app_constants.dart` to customize:
- Categories list
- Confidence thresholds
- Alert thresholds
- Training parameters
- UI strings

## Support

- Check README.md for full documentation
- Review PROJECT_STRUCTURE.md for architecture details
- Examine code comments for implementation details

---

**Ready to use in under 5 minutes!**
