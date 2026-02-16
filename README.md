# SpendWise AI 💰🤖

**An AI-powered expense tracking app built with Flutter that makes managing your finances effortless.**

Track expenses through natural language (text or voice), get automatic AI categorization, visualize spending patterns, and chat with your AI financial assistant.

[![Flutter](https://img.shields.io/badge/Flutter-3.38.9-blue)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.8-blue)](https://dart.dev)
[![Azure OpenAI](https://img.shields.io/badge/Azure%20OpenAI-GPT--4o-green)](https://azure.microsoft.com/en-us/products/ai-services/openai-service)

---

## 🎯 Overview

SpendWise AI is your intelligent expense tracking companion. Simply tell it what you spent - like "spent $25 on lunch at McDonald's" - and it automatically logs, categorizes, and analyzes your expenses using Azure OpenAI. No forms, no hassle, just natural conversation.

**Current Status:** ✅ Phases 1, 2, 3, 4 COMPLETE - Full-Featured Production App
**Platform:** Flutter (Web, Android, iOS, Desktop)
**Development:** Active - Phase 5 (Collaborative Features) Next

---

## ✨ Features

### ✅ Implemented (Phases 1-4 Complete)

**Phase 1: Local MVP**
- **🎙️ Natural Language Input**: Type expenses naturally ("spent $25 on lunch")
- **🤖 AI Auto-Categorization**: Azure OpenAI GPT-4o automatically categorizes expenses
- **📊 Live Dashboard**: Real-time analytics with interactive pie charts (fl_chart)
- **💬 AI Chat Assistant**: Ask questions about spending patterns and get insights
- **🏷️ Smart Categories**: Full CRUD operations (add, edit, delete categories)
- **🔊 Voice Input**: Speech-to-text integration with microphone button
- **💾 Local Storage**: Hive persistence (IndexedDB for web, filesystem for mobile)
- **✨ Smooth Animations**: Fade-in, slide-up, and staggered animations

**Phase 2: Authentication**
- **🔐 Google Sign-In**: Firebase Authentication integration
- **👤 User Profiles**: Display name and photo from Google account
- **🔒 User-Specific Data**: Isolated data per user (no data sharing)
- **🔄 Data Migration**: Auto-migrate from old single-user setup

**Phase 3: Cloud Sync**
- **☁️ Firestore Integration**: Cloud database with real-time sync
- **⚡ Hybrid Architecture**: Instant local writes (0ms) + background cloud sync (100-300ms)
- **🔄 Multi-Device Sync**: Real-time updates across devices (1-3s latency)
- **📱 Cross-Platform**: Runs on Web, Android, iOS (Flutter)
- **📊 Sync Indicator**: Cloud icon shows sync status in Dashboard

**Phase 4: Advanced Features**
- **✏️ Expense Editing**: Modify amount, description, category, date with dialog
- **🗑️ Expense Deletion**: Delete expenses with confirmation dialog
- **📈 Analytics Dashboard**: 6-month trend charts, month comparison, quick stats (NEW 5th tab)
- **💰 Budget Tracking**: Set monthly budgets per category with progress bars
- **🤖 AI Insights**: Generate spending summaries, patterns, predictions, and tips
- **🔍 Search & Filters**: Full-text search, filter by category/date/amount
- **📤 Data Export**: Export to CSV or text report with category breakdowns
- **🔄 Recurring Expenses**: Daily/weekly/monthly/yearly schedules with auto-generation

### 📋 Planned (Phase 5+)
- **🤝 Collaborative Features**: Shared expenses, bill splitting, group tracking
- **📱 Mobile Optimization**: Receipt camera scanning with OCR
- **💱 Multi-Currency**: Support for multiple currencies
- **💼 Business Expenses**: Tax categorization, mileage tracking
- **📎 Attachments**: Receipt photo attachments

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.38.9
- **Language**: Dart 3.10.8
- **State Management**: Singleton services with StreamControllers
- **UI**: Material Design with custom dark theme

### Backend & AI
- **AI Provider**: Azure OpenAI (GPT-4o model)
- **API Version**: 2024-12-01-preview
- **Authentication**: Firebase Auth (Google Sign-In)
- **Cloud Database**: Cloud Firestore for real-time sync

### Data Storage
- **Local**: Hive (IndexedDB for web, filesystem for mobile)
- **Cloud**: Cloud Firestore with real-time listeners
- **Architecture**: Hybrid offline-first (instant local writes + background cloud sync)

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Azure OpenAI account with API access
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

3. **Configure Azure OpenAI**

Create `lib/config/config.dart` (this file is gitignored):
```dart
class AzureOpenAIConfig {
  static const String endpoint = 'YOUR_AZURE_ENDPOINT';
  static const String apiKey = 'YOUR_API_KEY';
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
```

4. **Run the app**
```bash
# For web (Chrome)
flutter run -d chrome

# For Android
flutter run

# For iOS (requires macOS)
flutter run -d ios
```

---

## 📖 Usage

### Adding Expenses

**Text Input:**
```
spent $67.32 on groceries at Walmart
$25.50 lunch at McDonald's with Sarah
coffee with Mike $18.75
45 dollars on uber to airport
```

**The AI extracts:**
- Amount: $67.32
- Category: Groceries (auto-detected)
- Description: "groceries at Walmart"
- Person: Optional (e.g., "with Sarah")
- Date: Today (or specified date)

### AI Chat Queries

Ask your financial assistant:
```
"What's my total spending this month?"
"Which category do I spend most on?"
"How much did I spend on food?"
"Any unusual spending patterns?"
```

---

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point
├── config/
│   └── config.dart               # API keys (gitignored)
├── models/
│   ├── expense.dart              # Expense data model
│   ├── expense.g.dart            # Hive type adapter
│   ├── category.dart             # Category data model
│   └── category.g.dart           # Hive type adapter
├── services/
│   ├── azure_openai_service.dart # AI integration
│   ├── expense_service.dart      # Data management (Hive + Firestore)
│   └── firestore_service.dart    # Cloud sync service
├── screens/
│   ├── chat_screen.dart          # Expense input
│   ├── dashboard_screen.dart     # Analytics
│   ├── categories_screen.dart    # Category management
│   └── ai_chat_screen.dart       # AI assistant
├── theme/
│   └── app_theme.dart            # UI theme
└── utils/
    └── animations.dart           # Animation widgets
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

### Hot Reload
While app is running, press `r` in terminal for hot reload, `R` for hot restart.

---

## 🔐 Security

- **API Keys**: Stored in `lib/config/config.dart` (gitignored)
- **Never commit**: config.dart, .env files, or any secrets
- **HTTPS**: All API calls use secure connections

⚠️ **CRITICAL**: The `config.dart` file is gitignored to protect your API keys. Never commit this file!

---

## 📊 Architecture

### MVVM Pattern
```
Screens (UI) → Services (Business Logic) → Models (Data)
```

### Data Flow
```
User Input → Azure OpenAI → Parse Response → ExpenseService.addExpense() →
  1. Write to Hive (instant - 0ms)
  2. Stream Updates → All Screens Refresh
  3. Sync to Firestore (background - 100-300ms)
  4. Firestore listeners → Other devices update (1-3s)
```

### State Management
- Singleton services for shared state
- StreamControllers for reactive updates
- StreamBuilder widgets for UI updates

---

## 🎨 UI Design

**Theme:** iOS-inspired dark theme
- Background: #1C1C1E (dark)
- Cards: #2C2C2E (charcoal)
- Accent: #FFD60A (yellow)
- Typography: San Francisco-style fonts

**Screens:**
1. **Chat Screen**: Natural language expense input
2. **Dashboard**: Monthly totals, category breakdown, recent expenses
3. **Categories**: Manage expense categories
4. **AI Chat**: Financial insights and Q&A

---

## 🗺️ Roadmap

### ✅ Phase 1: Local MVP (COMPLETE - Feb 12, 2026)
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

### 🚧 Phase 4: Advanced Features (IN PROGRESS)
- [ ] Expense editing and deletion
- [ ] Advanced analytics (trends, budgets)
- [ ] Search and filters
- [ ] Data export (CSV, PDF)

### 📋 Phase 5+: Future Enhancements
- Receipt camera scanning (OCR)
- Recurring expense detection
- Multi-currency support
- Collaborative expense sharing
- Business expense tracking

See [MASTER_ROADMAP.md](MASTER_ROADMAP.md) for detailed feature breakdown.

---

## 💰 API Costs

### Azure OpenAI
- Expense parsing: ~500 tokens (~$0.01 per expense)
- Chat queries: ~1000-2000 tokens (~$0.02-$0.04 per query)
- Estimated: $5-10/month for active user

### Firebase (When Implemented)
- Free tier: 50K reads/day, 20K writes/day, 1GB storage
- Typical user: Well within free limits

---

## 🤝 Contributing

This is a personal project, but feedback and contributions are welcome!

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

---

## 👤 Author

**Vatsal Khemani**
- GitHub: [@vatsalkhemani](https://github.com/vatsalkhemani)
- Email: vatsalkhemani@gmail.com

---

## 🙏 Acknowledgments

- **Azure OpenAI** for AI capabilities
- **Flutter Team** for the amazing framework
- **Firebase** for backend infrastructure (planned)

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/vatsalkhemani/SpendWise-AI/issues)
- **Documentation**: See [CLAUDE.md](CLAUDE.md) for development guide
- **Roadmap**: See [MASTER_ROADMAP.md](MASTER_ROADMAP.md) for feature plans

---

**Built with ❤️ and AI to make expense tracking effortless**

*Last Updated: February 16, 2026*
