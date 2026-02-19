# SpendWise AI 💰🤖

**An AI-powered expense tracking app built with Flutter that makes managing your finances effortless.**

Track expenses through natural language (text, voice, or camera), get automatic AI categorization, visualize spending patterns, and chat with your AI financial assistant.

[![Flutter](https://img.shields.io/badge/Flutter-3.38.9-blue)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.8-blue)](https://dart.dev)
[![Azure OpenAI](https://img.shields.io/badge/Azure%20OpenAI-GPT--4o-green)](https://azure.microsoft.com/en-us/products/ai-services/openai-service)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Sync-orange)](https://firebase.google.com/)

---

## 🎯 Overview

SpendWise AI is your intelligent expense tracking companion. Simply tell it what you spent - type "spent $25 on lunch", speak it, or snap a photo of your receipt - and it automatically logs, categorizes, and analyzes your expenses using Azure OpenAI. No forms, no hassle, just natural interaction.

**Current Status:** ✅ **Phases 1, 2, 3, 4, 5A COMPLETE** - Full-Featured Production App with OCR
**Platform:** Flutter (Web, Android, iOS, Desktop)
**Development:** Active - Phase 5B (Collaborative Features) Next

---

## 📸 Screenshots

<div align="center">

### Chat Screen - Natural Language & Voice Input
<img src="lib/Images/image (3).jpg" width="800" alt="Chat Screen">

### Dashboard - Live Analytics & Spending Overview
<img src="lib/Images/image (4).jpg" width="800" alt="Dashboard">

### Categories - Budget Tracking & Management
<img src="lib/Images/image (5).jpg" width="800" alt="Categories">

### Analytics - 6-Month Trends & AI Insights
<img src="lib/Images/image (6).jpg" width="800" alt="Analytics">

### All Expenses - Search & Advanced Filters
<img src="lib/Images/image (8).png" width="800" alt="All Expenses">

</div>

---

## ✨ Features

### ✅ Implemented (Phases 1-5A Complete)

#### **Phase 1: Local MVP** ✅ (Feb 12, 2026)
- **🎙️ Natural Language Input**: Type expenses naturally ("spent $25 on lunch")
- **🤖 AI Auto-Categorization**: Azure OpenAI GPT-4o automatically categorizes expenses
- **📊 Live Dashboard**: Real-time analytics with interactive pie charts (fl_chart)
- **💬 AI Chat Assistant**: Ask questions about spending patterns and get insights
- **🏷️ Smart Categories**: Full CRUD operations (add, edit, delete categories)
- **🔊 Voice Input**: Speech-to-text integration with microphone button
- **💾 Local Storage**: Hive persistence (IndexedDB for web, filesystem for mobile)
- **✨ Smooth Animations**: Fade-in, slide-up, and staggered animations

#### **Phase 2: Authentication** ✅ (Feb 13, 2026)
- **🔐 Google Sign-In**: Firebase Authentication integration
- **👤 User Profiles**: Display name and photo from Google account
- **🔒 User-Specific Data**: Isolated data per user (no data sharing)
- **🔄 Data Migration**: Auto-migrate from old single-user setup

#### **Phase 3: Cloud Sync** ✅ (Feb 14, 2026)
- **☁️ Firestore Integration**: Cloud database with real-time sync
- **⚡ Hybrid Architecture**: Instant local writes (0ms) + background cloud sync (100-300ms)
- **🔄 Multi-Device Sync**: Real-time updates across devices (1-3s latency)
- **📱 Cross-Platform**: Runs on Web, Android, iOS, Desktop (Flutter)
- **📊 Sync Indicator**: Cloud icon shows sync status in Dashboard

#### **Phase 4: Advanced Features** ✅ (Feb 16, 2026)
- **✏️ Expense Editing**: Modify amount, description, category, date with dialog
- **🗑️ Expense Deletion**: Delete expenses with confirmation dialog
- **📈 Analytics Dashboard**: 6-month trend charts, month comparison, quick stats (5th tab)
- **💰 Budget Tracking**: Set monthly budgets per category with progress bars
- **🤖 AI Insights**: Generate spending summaries, patterns, predictions, and tips
- **🔍 Search & Filters**: Full-text search, filter by category/date/amount
- **📤 Data Export**: Export to CSV or text report with category breakdowns
- **🔄 Recurring Expenses**: Daily/weekly/monthly/yearly schedules with auto-generation

#### **Phase 5A: Mobile Optimization - Camera OCR** ✅ (Feb 19, 2026)
- **📸 Receipt Scanning**: Camera or gallery image capture
- **🔍 OCR Text Extraction**: Azure Computer Vision API integration
- **🤖 AI Receipt Parsing**: Automatic extraction of amount, merchant, category, date
- **✅ Review & Edit Dialog**: Editable fields before saving
- **🖼️ Dual Input Options**: Take photo or choose from gallery
- **🔐 Permission Handling**: Smart camera/photo permissions with settings link
- **📱 Cross-Platform Support**: Works on Web (gallery), Android, iOS (camera + gallery)

### 📋 Planned (Phase 5B+)

- **🤝 Collaborative Features**: Shared expenses, bill splitting, group tracking
- **💱 Multi-Currency**: Support for multiple currencies
- **💼 Business Expenses**: Tax categorization, mileage tracking
- **📎 Receipt Attachments**: Store receipt photos with expenses
- **📊 Advanced Reports**: Monthly/yearly reports with graphs

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.38.9 (Web, Android, iOS, Desktop)
- **Language**: Dart 3.10.8
- **State Management**: Singleton services with StreamControllers (reactive)
- **UI**: Material Design with custom dark theme
- **Charts**: fl_chart ^0.66.0 (interactive visualizations)
- **Animations**: Custom fade-in, slide-up, staggered animations

### AI & OCR
- **AI Provider**: Azure OpenAI (GPT-4o model)
- **OCR Provider**: Azure Computer Vision API (Read API v3.2)
- **API Version**: 2024-12-01-preview
- **Capabilities**: Natural language parsing, receipt OCR, spending insights

### Backend & Authentication
- **Authentication**: Firebase Auth (Google Sign-In)
- **Cloud Database**: Cloud Firestore with real-time listeners
- **User Isolation**: User-specific data collections

### Data Storage
- **Local**: Hive ^2.2.3 (IndexedDB for web, filesystem for mobile)
- **Cloud**: Cloud Firestore ^5.5.0
- **Architecture**: Hybrid offline-first (instant local + background cloud sync)

### Input Methods
- **Text**: Natural language parsing
- **Voice**: speech_to_text ^6.6.0 (speech recognition)
- **Camera**: image_picker ^1.0.7 (camera/gallery access)
- **Image Processing**: image ^4.1.7 (compression, resizing)
- **Permissions**: permission_handler ^11.3.0 (iOS/Android)

### Data Export
- **CSV Export**: csv ^6.0.0
- **Text Reports**: Custom formatted reports with category breakdowns

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Azure OpenAI account with API access
- Azure Computer Vision account (for receipt scanning)
- Firebase project (for authentication and cloud sync)
- Chrome browser (for web development)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/vatsalkhemani/SpendWise-AI.git
cd SpendWiseAI
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Azure OpenAI & Computer Vision**

Create `lib/config/config.dart` (this file is gitignored):
```dart
/// Azure OpenAI Configuration
class AzureOpenAIConfig {
  static const String endpoint = 'YOUR_AZURE_OPENAI_ENDPOINT';
  static const String apiKey = 'YOUR_OPENAI_API_KEY';
  static const String deploymentName = 'gpt-4o';
  static const String apiVersion = '2024-12-01-preview';

  static String get chatCompletionUrl =>
      '$endpoint/openai/deployments/$deploymentName/chat/completions?api-version=$apiVersion';

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'api-key': apiKey,
  };

  static bool get isConfigured =>
      endpoint.isNotEmpty &&
      apiKey.isNotEmpty &&
      deploymentName.isNotEmpty;
}

/// Azure Computer Vision Configuration (for OCR receipt scanning)
class Config {
  static const String azureVisionEndpoint = 'YOUR_VISION_ENDPOINT';
  static const String azureVisionApiKey = 'YOUR_VISION_API_KEY';

  static bool get isVisionConfigured =>
      azureVisionEndpoint.isNotEmpty &&
      !azureVisionEndpoint.contains('YOUR_') &&
      azureVisionApiKey.isNotEmpty &&
      !azureVisionApiKey.contains('YOUR_');
}

/// Firebase Configuration
class FirebaseConfig {
  static const String apiKey = 'YOUR_FIREBASE_API_KEY';
  static const String projectId = 'YOUR_PROJECT_ID';
  static const String webClientId = 'YOUR_WEB_CLIENT_ID';

  static bool get isConfigured =>
      apiKey.isNotEmpty && projectId.isNotEmpty;
}
```

4. **Set up Firebase**
- Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
- Enable Google Authentication
- Enable Cloud Firestore
- Add your app (Web/Android/iOS)
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

5. **Run the app**
```bash
# For web (Chrome)
flutter run -d chrome --web-port=8084

# For Android
flutter run

# For iOS (requires macOS)
flutter run -d ios
```

---

## 📖 Usage

### Adding Expenses - 3 Easy Ways!

#### **1. Natural Language (Text)**
```
spent $67.32 on groceries at Walmart
$25.50 lunch at McDonald's with Sarah
coffee with Mike $18.75
45 dollars on uber to airport
```

#### **2. Voice Input**
1. Tap the 🎤 microphone icon
2. Speak your expense naturally
3. AI processes and saves automatically

#### **3. Camera OCR (NEW!)**
1. Tap the 📷 camera icon
2. Choose "Take Photo" or "Choose from Gallery"
3. Select receipt image
4. Wait 3-5 seconds for OCR processing
5. Review extracted data (editable):
   - Amount
   - Merchant name
   - Category (auto-suggested)
   - Date
6. Tap "Add Expense" to save

**The AI extracts:**
- Amount: $67.32
- Category: Groceries (auto-detected)
- Description: "groceries at Walmart"
- Person: Optional (e.g., "with Sarah")
- Date: Today (or from receipt)

### Managing Expenses

**Edit Expense:**
1. Go to Dashboard or All Expenses
2. Tap the ✏️ edit icon on any expense
3. Modify fields in dialog
4. Save changes (syncs to cloud)

**Delete Expense:**
1. Tap the 🗑️ delete icon
2. Confirm deletion
3. Expense removed (syncs to cloud)

**Set Budgets:**
1. Go to Categories tab
2. Tap category card
3. Set monthly budget
4. Track progress with color-coded bars

### Search & Filter

1. Go to "All Expenses" tab (4th tab)
2. Use search bar for text search
3. Filter by:
   - Category (dropdown)
   - Date range (date picker)
   - Amount range (min/max)
4. Clear filters with chip buttons

### Export Data

1. Go to Dashboard
2. Tap the ⋮ menu icon (top right)
3. Choose export format:
   - CSV (spreadsheet-ready)
   - Text Report (formatted summary)
4. File downloads automatically

### AI Chat Queries

Ask your financial assistant:
```
"What's my total spending this month?"
"Which category do I spend most on?"
"How much did I spend on food?"
"Any unusual spending patterns?"
"What's my average transaction amount?"
"Generate a spending summary for this month"
```

---

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point, navigation
├── config/
│   └── config.dart               # API keys (gitignored)
├── models/
│   ├── expense.dart              # Expense data model with recurring support
│   ├── expense.g.dart            # Hive type adapter
│   ├── category.dart             # Category data model with budgets
│   └── category.g.dart           # Hive type adapter
├── services/
│   ├── azure_openai_service.dart # AI integration (parsing, insights, OCR)
│   ├── expense_service.dart      # Data management (Hive + Firestore sync)
│   ├── firestore_service.dart    # Cloud sync service
│   ├── auth_service.dart         # Firebase authentication
│   ├── ocr_service.dart          # Camera OCR with Azure Computer Vision
│   └── export_service.dart       # CSV and text export
├── screens/
│   ├── chat_screen.dart          # Expense input (text/voice/camera)
│   ├── dashboard_screen.dart     # Analytics and spending overview
│   ├── categories_screen.dart    # Category management with budgets
│   ├── ai_chat_screen.dart       # AI financial assistant
│   ├── analytics_screen.dart     # 6-month trends and insights
│   ├── all_expenses_screen.dart  # Search and filter expenses
│   └── recurring_expenses_screen.dart  # Manage recurring expenses
├── theme/
│   └── app_theme.dart            # Dark theme configuration
├── utils/
│   └── animations.dart           # Animation widgets
└── Images/                        # App screenshots for README
```

---

## 🔧 Development

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Format Code
```bash
flutter format lib/
```

### Hot Reload
While app is running:
- Press `r` in terminal for hot reload (fast updates)
- Press `R` for hot restart (full app restart)
- Press `q` to quit

### Build for Production
```bash
# Web
flutter build web --release

# Android APK
flutter build apk --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

---

## 🔐 Security

- **API Keys**: Stored in `lib/config/config.dart` (gitignored)
- **Never commit**: config.dart, .env files, or any secrets
- **HTTPS**: All API calls use secure connections
- **User Isolation**: Firestore security rules enforce per-user data access
- **Authentication**: Firebase Auth with Google Sign-In (secure OAuth)

⚠️ **CRITICAL**: The `config.dart` file is gitignored to protect your API keys. Never commit this file or share it publicly!

---

## 📊 Architecture

### MVVM Pattern
```
Screens (UI) → Services (Business Logic) → Models (Data)
```

### Data Flow (Hybrid Sync Architecture)
```
User Input → Azure OpenAI → Parse Response → ExpenseService.addExpense() →
  1. Write to Hive (instant - 0ms)
  2. Stream Updates → All Screens Refresh (reactive)
  3. Sync to Firestore (background - 100-300ms)
  4. Firestore listeners → Other devices update (1-3s)
```

### Camera OCR Flow
```
User taps 📷 → Camera/Gallery picker → Capture image →
  1. Compress image (<4MB for Azure API)
  2. Upload to Azure Computer Vision (OCR)
  3. Poll for text extraction results (3-5s)
  4. Parse receipt text with Azure OpenAI (GPT-4o)
  5. Show review dialog with editable fields
  6. User confirms → Save expense (Hive + Firestore)
```

### State Management
- **Pattern**: Singleton services for shared state
- **Reactive**: StreamControllers with StreamBuilder widgets
- **Benefits**: Simple, no external dependencies, reactive UI updates

---

## 🎨 UI Design

**Theme:** iOS-inspired dark mode with yellow accents

**Color Palette:**
- Background: `#1C1C1E` (very dark gray)
- Cards: `#2C2C2E` (dark gray)
- Primary/Accent: `#FFD60A` (bright yellow)
- Text Primary: `#FFFFFF` (white)
- Text Secondary: `#98989D` (light gray)

**Navigation:** 5 Bottom Tabs
1. **💬 Chat**: Expense input (text/voice/camera)
2. **📊 Dashboard**: Monthly totals, charts, recent expenses
3. **🏷️ Categories**: Manage categories and budgets
4. **📈 Analytics**: 6-month trends, AI insights
5. **🤖 AI Chat**: Financial assistant Q&A

---

## 🗺️ Roadmap

### ✅ Phase 1: Local MVP (COMPLETE - Feb 12, 2026)
- ✅ Natural language expense parsing
- ✅ Hive local persistence
- ✅ Voice input (speech_to_text)
- ✅ Interactive charts (fl_chart)
- ✅ Category CRUD operations
- ✅ Smooth animations throughout

### ✅ Phase 2: Authentication (COMPLETE - Feb 13, 2026)
- ✅ Firebase integration (Auth, Firestore)
- ✅ Google Sign-In
- ✅ User-specific data isolation
- ✅ Data migration from single-user setup

### ✅ Phase 3: Cloud Sync (COMPLETE - Feb 14, 2026)
- ✅ Firestore cloud database
- ✅ Real-time multi-device sync
- ✅ Hybrid offline-first architecture
- ✅ Auto-migration Hive → Firestore
- ✅ Sync status indicator

### ✅ Phase 4: Advanced Features (COMPLETE - Feb 16, 2026)
- ✅ Expense editing and deletion
- ✅ Advanced analytics (trends, budgets)
- ✅ AI insights (summaries, patterns, predictions)
- ✅ Search and filters
- ✅ Data export (CSV, text reports)
- ✅ Recurring expenses

### ✅ Phase 5A: Mobile Optimization - OCR (COMPLETE - Feb 19, 2026)
- ✅ Camera receipt scanning
- ✅ Azure Computer Vision OCR integration
- ✅ AI receipt parsing
- ✅ Review & edit dialog
- ✅ Cross-platform support (Web/Android/iOS)

### 📋 Phase 5B+: Future Enhancements
- 🔄 Receipt image storage (with expenses)
- 🔄 Collaborative expense sharing
- 🔄 Bill splitting with friends/family
- 🔄 Multi-currency support
- 🔄 Business expense tracking (tax categories)
- 🔄 Mileage tracking
- 🔄 Advanced reports (monthly/yearly PDF)

See [MASTER_ROADMAP.md](MASTER_ROADMAP.md) for detailed feature breakdown.

---

## 💰 API Costs

### Azure OpenAI (GPT-4o)
- **Expense parsing**: ~500 tokens (~$0.01 per expense)
- **Chat queries**: ~1000-2000 tokens (~$0.02-$0.04 per query)
- **Receipt parsing**: ~800 tokens (~$0.015 per receipt)
- **Estimated**: $5-15/month for active user (100-200 expenses/month)

### Azure Computer Vision (OCR)
- **Free tier**: 5,000 calls/month (covers ~160 receipts/day)
- **Paid tier**: $1.50 per 1,000 calls
- **Estimated**: FREE for most users (within free tier)
- **Heavy usage** (500 receipts/month): ~$0.075/month

### Firebase
- **Authentication**: Free (no limits)
- **Firestore Free tier**: 50K reads/day, 20K writes/day, 1GB storage
- **Typical user**: Well within free limits
- **Storage**: 1MB per user (10,000 users = 10GB)

### Total Estimated Cost
- **Light user** (20 expenses/month): ~$1/month
- **Average user** (100 expenses/month): ~$5-8/month
- **Power user** (500 expenses/month): ~$15-20/month

---

## 🤝 Contributing

This is a personal project, but feedback and contributions are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

**Development Guidelines:**
- Follow existing code style (dart format)
- Add comments for complex logic
- Update README for new features
- Test on Web, Android, iOS if possible

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

---

## 👤 Author

**Vatsal Khemani**
- GitHub: [@vatsalkhemani](https://github.com/vatsalkhemani)
- Email: vatsalkhemani@gmail.com
- LinkedIn: [Vatsal Khemani](https://linkedin.com/in/vatsalkhemani)

---

## 🙏 Acknowledgments

- **Azure OpenAI** (GPT-4o) for natural language processing and AI insights
- **Azure Computer Vision** for OCR receipt scanning
- **Flutter Team** for the amazing cross-platform framework
- **Firebase** for authentication and cloud sync infrastructure
- **fl_chart** for beautiful interactive charts
- **Hive** for fast local storage

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/vatsalkhemani/SpendWise-AI/issues)
- **Documentation**:
  - [CLAUDE.md](CLAUDE.md) - Developer guide
  - [MASTER_ROADMAP.md](MASTER_ROADMAP.md) - Feature roadmap
  - [PHASE4_COMPLETE.md](PHASE4_COMPLETE.md) - Phase 4 details
  - [FIRESTORE_SYNC_IMPLEMENTATION.md](FIRESTORE_SYNC_IMPLEMENTATION.md) - Cloud sync details

---

## 🌟 Features Highlight

### What Makes SpendWise AI Special?

✨ **3 Input Methods**: Type, speak, or snap - your choice!
🤖 **True AI Intelligence**: GPT-4o understands natural language perfectly
📸 **Smart OCR**: Extracts data from receipts with >90% accuracy
⚡ **Instant Sync**: Write locally (0ms), sync in background (100-300ms)
🔄 **Multi-Device**: Changes appear on all devices within 1-3 seconds
📊 **Beautiful Charts**: Interactive visualizations with fl_chart
💰 **Budget Tracking**: Set budgets, track progress, get alerts
🔍 **Powerful Search**: Find any expense in milliseconds
📤 **Easy Export**: CSV for spreadsheets, text for reports
🔐 **Secure**: User-isolated data, HTTPS everywhere

---

## 🎯 Perfect For

- 💼 **Individuals**: Personal expense tracking made effortless
- 👥 **Couples**: Track shared expenses (coming soon: bill splitting)
- 🏢 **Freelancers**: Business expense tracking with export
- 🎓 **Students**: Budget management on a tight budget
- 🌍 **Travelers**: Quick expense logging on the go

---

**Built with ❤️ and AI to make expense tracking effortless**

*Last Updated: February 19, 2026*
*Version: 1.0.0 - Phase 5A Complete (Camera OCR)*
