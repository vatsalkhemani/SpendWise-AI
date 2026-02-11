# Flutter Setup Guide for SpendWise AI

## Prerequisites

### Required
- ✅ Windows 10/11
- ✅ VS Code
- ✅ Chrome browser

### To Install
- ⏳ Flutter SDK
- ⏳ Android Studio (optional, for Android emulator)

---

## Step 1: Install Flutter

### Option A: Using winget (Windows 11)
```powershell
winget install --id=Google.Flutter -e
```

### Option B: Using Chocolatey
```powershell
choco install flutter
```

### Option C: Manual Download
1. Go to: https://docs.flutter.dev/get-started/install/windows
2. Download Flutter SDK
3. Extract to `C:\src\flutter`
4. Add to PATH: `C:\src\flutter\bin`

### Verify Installation
```bash
flutter doctor
```

---

## Step 2: Install VS Code Extensions

Open VS Code and install:
1. **Flutter** (Dart-Code.flutter)
2. **Dart** (Dart-Code.dart-code)

---

## Step 3: Set Up Development Target

### For Web Development (Easiest - Use Chrome)
```bash
flutter config --enable-web
```
**This is recommended to start!** You can test in Chrome immediately.

### For Android Development (Optional)
1. Install Android Studio: https://developer.android.com/studio
2. Open Android Studio → Tools → SDK Manager
3. Install Android SDK
4. Create Android Virtual Device (AVD)

---

## Step 4: Create SpendWise AI Flutter Project

```bash
cd "c:\Users\vkhemani\Pictures\Vibecoding\SpendWise AI"
flutter create --org com.spendwiseai spendwise_ai
cd spendwise_ai
```

---

## Step 5: Test Flutter Installation

### Run on Chrome (Web)
```bash
flutter run -d chrome
```

### Run on Android Emulator (if installed)
```bash
flutter emulators --launch <emulator_name>
flutter run
```

---

## Step 6: Configure Azure OpenAI

Create `lib/config/config.dart`:

```dart
class AzureOpenAIConfig {
  static const String endpoint = 'YOUR_AZURE_ENDPOINT';
  static const String apiKey = 'YOUR_API_KEY';
  static const String deploymentName = 'gpt-4';
}
```

**Add to .gitignore:**
```
lib/config/config.dart
```

---

## Troubleshooting

### `flutter: command not found`
- Restart terminal after installation
- Check PATH includes Flutter bin directory
- Run: `where flutter` (Windows) to verify

### Android Studio issues
- Not required! Use Chrome for development
- Install only if you want Android emulator

### VS Code not recognizing Dart
- Install Flutter and Dart extensions
- Restart VS Code
- Open Command Palette (Ctrl+Shift+P) → "Flutter: Run Flutter Doctor"

---

## Quick Start After Setup

```bash
# Navigate to project
cd "c:\Users\vkhemani\Pictures\Vibecoding\SpendWise AI"

# Run on Chrome (recommended)
flutter run -d chrome

# Or use VS Code
# Press F5 in VS Code with a Dart file open
```

---

## What's Next?

Once Flutter is installed and working:
1. ✅ Create Flutter project structure
2. ✅ Set up Firebase
3. ✅ Add Azure OpenAI integration
4. ✅ Build chat interface
5. ✅ Implement voice input

---

## Resources

- Flutter Docs: https://docs.flutter.dev
- Dart Language: https://dart.dev
- Firebase for Flutter: https://firebase.google.com/docs/flutter/setup
- Flutter Packages: https://pub.dev

---

**Estimated Setup Time:** 15-30 minutes
