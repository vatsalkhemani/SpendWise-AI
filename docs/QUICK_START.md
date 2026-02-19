# SpendWise AI - Quick Start Guide (VS Code Method)

## 🚀 Install Flutter via VS Code (Recommended!)

### Step 1: Install Flutter Extension in VS Code

1. **Open VS Code**
2. Press `Ctrl+Shift+X` (Extensions)
3. Search: **"Flutter"**
4. Click **Install** on "Flutter" by Dart-Code
5. The Dart extension will install automatically

### Step 2: Download Flutter SDK

1. Press `Ctrl+Shift+P` (Command Palette)
2. Type: `Flutter: New Project`
3. You'll see: **"Unable to find Flutter SDK"**
4. Click: **"Download SDK"**
5. Choose location: `C:\src\flutter` (or anywhere you prefer)
6. Wait for download (takes 5-10 minutes)
7. VS Code will configure everything automatically!

### Step 3: Create SpendWise AI Project

Once Flutter is installed:

1. Press `Ctrl+Shift+P`
2. Type: `Flutter: New Project`
3. Select: **Application**
4. Choose this folder: `c:\Users\vkhemani\Pictures\Vibecoding\SpendWise AI`
5. Project name: `spendwise_ai`
6. Wait for project creation

**OR** I can create it for you via command line once Flutter is ready!

---

## 📱 Run Your First Flutter App

### Option 1: Run on Chrome (Web - Easiest!)

1. Open VS Code terminal: `` Ctrl+` ``
2. Run:
   ```bash
   flutter config --enable-web
   flutter run -d chrome
   ```

### Option 2: Run via VS Code UI

1. Open `lib/main.dart`
2. Look for device selector in bottom right (select "Chrome")
3. Press `F5` or click "Run" → "Start Debugging"

---

## ✅ Verify Setup

```bash
# In VS Code terminal
flutter doctor
```

You should see:
```
[✓] Flutter
[✓] Chrome
[✓] VS Code
```

---

## 🎯 Next Steps After Installation

1. ✅ Flutter installed via VS Code
2. ✅ Project created
3. ✅ Run `flutter pub get` to install dependencies
4. ✅ Open `lib/main.dart`
5. ✅ Press `F5` to run
6. ✅ See SpendWise AI in Chrome!

---

## 🔧 Project Structure (After Creation)

```
SpendWise AI/
├── lib/
│   ├── main.dart              # App entry point
│   ├── config/
│   │   └── config.dart        # ✅ Already created with Azure keys!
│   ├── models/
│   ├── screens/
│   ├── services/
│   └── widgets/
├── pubspec.yaml               # Dependencies
├── .gitignore                 # ✅ Already configured
└── README.md
```

---

## 💡 Tips

- **Terminal shortcut**: `` Ctrl+` ``
- **Command palette**: `Ctrl+Shift+P`
- **Run app**: `F5`
- **Hot reload**: `r` in terminal while app is running
- **Hot restart**: `R` in terminal

---

## 🆘 Troubleshooting

**"Unable to find Flutter SDK"**
→ Use VS Code to download it!

**"No devices found"**
→ Enable web: `flutter config --enable-web`
→ Restart VS Code

**Extension not working**
→ Restart VS Code after installing Flutter extension

---

**Time Estimate**: 10 minutes from start to running app! 🎉
