# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SpendWise AI is an **AI-powered expense tracking app** built with **Flutter** that uses **natural language input** to log and categorize expenses. The app integrates with **Azure OpenAI (GPT-4o)** for intelligent expense parsing and financial insights.

**Platform:** Flutter (cross-platform: Web, iOS, Android, Desktop)
**Architecture:** MVVM pattern (Models, Services, Screens)
**AI Provider:** Azure OpenAI API + Azure Computer Vision API
**Current Status:** ✅ Phases 1, 2, 3, 4, 5A COMPLETE - Full-featured production app with editing, analytics, budgets, recurring, export, and camera OCR

---

## Development Commands

### Running the App
```bash
# Get dependencies
flutter pub get

# Run on Chrome (recommended for development)
flutter run -d chrome

# Run on specific port (if default is in use)
flutter run -d chrome --web-port=8083

# Run on specific device
flutter devices                 # List available devices
flutter run -d <device-id>

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
```

### Building
```bash
# Build for web
flutter build web

# Build for Android
flutter build apk              # Debug APK
flutter build apk --release    # Release APK

# Build for iOS (requires macOS)
flutter build ios
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Code Analysis
```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Clean build artifacts
flutter clean
```

---

## Architecture & Structure

### High-Level Architecture

```
┌──────────────────────────────┐
│   Screens (UI Layer)         │  ← Flutter widgets, user interaction
│   - ChatScreen               │
│   - DashboardScreen          │
│   - CategoriesScreen         │
│   - AIChatScreen             │
└──────────┬───────────────────┘
           │
┌──────────▼───────────────────┐
│   Services (Business Logic)  │  ← API calls, data processing
│   - AzureOpenAIService       │
│   - ExpenseService           │
└──────────┬───────────────────┘
           │
┌──────────▼───────────────────┐
│   Models (Data)              │  ← Data structures
│   - Expense                  │
│   - Category                 │
└──────────────────────────────┘
```

### Key Directories

- **`lib/`** - Main application code
  - **`lib/main.dart`** - App entry point with navigation setup (BottomNavigationBar with 4 screens)
  - **`lib/config/config.dart`** - ⚠️ **CRITICAL:** Contains Azure OpenAI API keys - **GITIGNORED**
  - **`lib/models/`** - Data models (Expense, Category)
  - **`lib/screens/`** - UI screens (Chat, Dashboard, Categories, AI Chat)
  - **`lib/services/`** - Business logic (Azure OpenAI integration, ExpenseService)
  - **`lib/theme/`** - UI theme configuration
- **`test/`** - Unit and widget tests

### Critical Files

**`lib/config/config.dart`** (GITIGNORED - contains secrets):
- Azure OpenAI endpoint, API key, deployment name
- App configuration and feature flags
- Default categories with colors and icons
- **NEVER commit this file** - it's in .gitignore for security

**`lib/services/expense_service.dart`**:
- Central singleton service for managing all expenses and categories
- Hive local storage with Firestore cloud sync (hybrid architecture)
- Reactive StreamControllers for live UI updates
- Provides analytics methods (totals, averages, category breakdowns)
- User-specific data isolation (expenses_$userId, categories_$userId)
- Auto-migration from old data on first launch

**`lib/services/azure_openai_service.dart`**:
- `parseExpense()` - Parses natural language input → structured expense data
- `categorizeExpense()` - Auto-categorizes expense descriptions
- `getInsights()` - Provides AI-driven spending insights
- `streamChatResponse()` - Powers the AI chat assistant

**`lib/services/firestore_service.dart`** (NEW in Phase 3):
- Firestore cloud sync service (~280 lines)
- User-specific collections (users/{userId}/expenses, users/{userId}/categories)
- CRUD operations: addExpense, updateExpense, deleteExpense
- Real-time streams: getExpensesStream, getCategoriesStream
- Batch operations for data migration
- Error handling and retry logic

**`lib/main.dart`**:
- App theme (dark mode with yellow accent #FFD60A)
- Navigation structure (5-tab BottomNavigationBar)
- MaterialApp configuration
- Firebase and Hive initialization
- Auth state management with AuthGate

---

## Current Implementation Status

### ✅ What's Implemented (Phase 1 Complete)

1. **Natural Language Expense Input** (`lib/screens/chat_screen.dart`)
   - Chat-style interface for entering expenses
   - AI parsing via Azure OpenAI with dynamic categories
   - Real-time monthly total display
   - Transaction count tracking
   - Message history with smooth animations
   - **Voice Input** - Speech-to-text with visual feedback (mic icon turns yellow when listening)

2. **Live Analytics Dashboard** (`lib/screens/dashboard_screen.dart`)
   - Monthly spending total and transaction count cards
   - **Interactive Pie Chart** - fl_chart visualization with percentage labels
   - Color-coded category legend
   - **Category Breakdown Bars** - Progress bars with spending percentages
   - Recent expenses list (last 5)
   - Reactive updates via StreamBuilder
   - **Smooth Animations** - Staggered slide-up animations for cards and charts

3. **Category Management** (`lib/screens/categories_screen.dart`)
   - Default categories with color coding
   - Real-time spending per category
   - Transaction counts
   - **Full CRUD Operations** - Add, edit, and delete categories with confirmation dialogs
   - Auto-generated colors for new categories
   - Animated category cards
   - AI Category Assistant UI (placeholder for future)

4. **AI Chat Assistant** (`lib/screens/ai_chat_screen.dart`)
   - Question/answer interface
   - Suggested prompt chips
   - Context-aware responses using expense data
   - Chat history with timestamps

5. **Data Management** (`lib/services/expense_service.dart`)
   - Singleton service pattern
   - **Hive Local Persistence** - Data stored in IndexedDB (web) or filesystem (mobile/desktop)
   - Reactive updates via StreamControllers
   - Analytics calculations
   - TypeAdapters for Expense and Category models

6. **Smart Categorization** (`lib/services/azure_openai_service.dart`)
   - **Dynamic Category Support** - AI uses user's actual categories (not hardcoded)
   - Pulls available categories from database
   - Exact category matching
   - Fallback to default categories if needed

7. **Smooth Animations** (`lib/utils/animations.dart`)
   - Fade-in animations for empty states
   - Slide-up animations for cards and lists
   - Scale animations for interactive elements
   - Staggered list animations
   - Page transitions

### ✅ Phase 2: Firebase Authentication (COMPLETE - Feb 13, 2026)
- ✅ Firebase Core initialized
- ✅ Google Sign-In authentication
- ✅ User-specific Hive boxes (expenses_$userId, categories_$userId)
- ✅ Multi-user support with data isolation
- ✅ Migration from old "user123" data

### ✅ Phase 3: Cloud Sync (COMPLETE - Feb 14, 2026)
- ✅ FirestoreService implementation (~280 lines)
- ✅ Hybrid sync architecture (Hive local + Firestore cloud)
- ✅ Real-time Firestore listeners (1-3s sync latency)
- ✅ Auto-migration Hive → Firestore on first launch
- ✅ Sync status indicator (cloud icon in Dashboard)

### ✅ Phase 4: Advanced Features (COMPLETE - Feb 16, 2026)

**4a. Expense Management** (`lib/screens/dashboard_screen.dart`)
- ✅ Edit expense dialog with pre-filled fields
- ✅ Delete expense with confirmation dialog
- ✅ Edit/delete buttons on each expense tile
- ✅ Syncs changes to both Hive and Firestore

**4b. Analytics & Insights** (`lib/screens/analytics_screen.dart` - NEW)
- ✅ 6-month spending trend line chart (fl_chart)
- ✅ Month-over-month comparison card
- ✅ Quick stats: Total, Monthly Avg, Transactions, Avg/Transaction
- ✅ AI-powered insights with "Generate" button
- ✅ 4 new Azure OpenAI methods: spending summary, pattern detection, predictions, recommendations

**4c. Budget Tracking** (`lib/screens/categories_screen.dart`)
- ✅ Set monthly budget per category
- ✅ Budget progress bars with color coding (green/orange/red)
- ✅ Over-budget warnings
- ✅ Category model updated with `monthlyBudget` field

**4d. Search & Filters** (`lib/screens/all_expenses_screen.dart` - NEW)
- ✅ Full-text search (description, person)
- ✅ Category filter dropdown
- ✅ Date range picker
- ✅ Amount range filter (min/max)
- ✅ Active filter chips with remove option

**4e. Data Export** (`lib/services/export_service.dart` - NEW)
- ✅ Export to CSV (csv package)
- ✅ Export to text report with category breakdowns
- ✅ Browser download functionality (dart:html)
- ✅ Export menu in Dashboard AppBar

**4f. Recurring Expenses** (`lib/screens/recurring_expenses_screen.dart` - NEW)
- ✅ Create recurring templates (daily, weekly, monthly, yearly)
- ✅ Auto-generation of expense instances
- ✅ Stop recurring expenses
- ✅ Delete recurring templates and all instances
- ✅ Expense model updated with 4 recurring fields
- ✅ Auto-processing on app init

### ✅ Phase 5A: Mobile Optimization - Camera OCR (COMPLETE - Feb 19, 2026)

**5a. Camera Receipt Scanning** (`lib/screens/chat_screen.dart`)
- ✅ Camera button in chat input area (left of microphone)
- ✅ Source selection dialog: "Take Photo" or "Choose from Gallery"
- ✅ Camera/photo permissions handling (iOS/Android)
- ✅ Permission error with settings link
- ✅ Cross-platform support (Web: gallery only, Mobile: camera + gallery)

**5b. OCR Service** (`lib/services/ocr_service.dart` - NEW ~200 lines)
- ✅ Image capture via image_picker
- ✅ Smart image compression (<4MB for Azure API)
- ✅ Azure Computer Vision API integration (Read API v3.2)
- ✅ Two-step OCR: Submit image → Poll for results
- ✅ Text extraction from OCR response
- ✅ Error handling (no text, poor quality, network errors)

**5c. AI Receipt Parsing** (`lib/services/azure_openai_service.dart`)
- ✅ New method: `parseReceiptText()` (~80 lines)
- ✅ Receipt-specific prompt engineering
- ✅ Extracts: amount (total), merchant name, category, date
- ✅ Handles itemized receipts, tax, subtotals
- ✅ Reuses existing HTTP request infrastructure

**5d. Review & Edit Dialog** (`lib/screens/chat_screen.dart`)
- ✅ Shows extracted data in editable form
- ✅ Amount field (TextField, validated)
- ✅ Description field (TextField)
- ✅ Category dropdown (user's categories)
- ✅ Person field (optional)
- ✅ Date picker with theme
- ✅ "Add Expense" button creates expense (Hive + Firestore)

**5e. Platform Configuration**
- ✅ iOS permissions: NSCameraUsageDescription, NSPhotoLibraryUsageDescription
- ✅ Android permissions: CAMERA, READ_EXTERNAL_STORAGE
- ✅ Dependencies: image_picker ^1.0.7, image ^4.1.7, permission_handler ^11.3.0
- ✅ Config.dart: azureVisionEndpoint, azureVisionApiKey

### ⚠️ What's NOT Yet Implemented (Phase 5B+ Features)

1. **Collaborative Features** - ❌ No shared expenses or bill splitting
2. **Receipt Image Storage** - ❌ Only text data saved (no image attachments)
3. **Multi-Currency** - ❌ Only supports single currency (USD)
4. **Tax Features** - ❌ No tax categorization or reporting
5. **Business Expense Tracking** - ❌ No mileage or advanced tax features

---

## Development Principles

1. **Simplicity First** - Keep UX simple, avoid complex forms
2. **Natural Interaction** - Natural language input is core to the experience
3. **AI-Powered** - Leverage AI to minimize manual work
4. **Functionality Over Optimization** - Working features > perfect code
5. **Clean Code** - Maintainable and readable, avoid over-engineering

**Critical Rules:**
- ✅ **Never commit API keys** - config.dart must stay gitignored
- ✅ **Update documentation** when making architectural changes
- ✅ **Test with real AI** - Verify Azure OpenAI integration works
- ✅ **Mobile-first** - UI must work on mobile aspect ratios

---

## Azure OpenAI Integration

The app uses Azure OpenAI's GPT-4o model for:
1. **Expense Parsing** - Natural language → structured JSON
2. **Auto-Categorization** - Description → category assignment
3. **Financial Insights** - Query → helpful analysis
4. **AI Chat** - Conversational expense queries
5. **Spending Summaries** - AI-generated monthly summaries
6. **Pattern Detection** - Unusual spending pattern identification
7. **Predictions** - Next month spending forecasts
8. **Recommendations** - Personalized money-saving tips

**API Configuration:**
- Endpoint: Configured in `lib/config/config.dart`
- Model: `gpt-4o`
- API Version: `2024-12-01-preview`
- Headers: `api-key` authentication

**Prompt Engineering Tips:**
- Always specify exact JSON format in prompts
- List valid categories explicitly
- Keep system role consistent: "You are a helpful financial assistant"
- Limit response length (< 150 words for chat)

**Cost Considerations:**
- ~500 tokens per expense input (~$0.01)
- ~1000-2000 tokens per chat query (~$0.02-$0.04)

---

## State Management

**Current:** Singleton services with StreamControllers
**Pattern:**
```dart
// Services are singletons
final ExpenseService _expenseService = ExpenseService();

// Use StreamBuilder for reactive UI
StreamBuilder<List<Expense>>(
  stream: _expenseService.expensesStream,
  builder: (context, snapshot) {
    final data = _expenseService.someMethod();
    return Widget(...);
  },
)
```

**Future:** May add Provider/Riverpod when Firebase integration requires more complex state

---

## Data Persistence

**Current:** ✅ **Hybrid Architecture** - Hive (local) + Firestore (cloud)

### Hive Integration ✅ (Phase 1 - Complete)
- Dependencies: `hive: ^2.2.3`, `hive_flutter: ^1.1.0`
- TypeAdapters generated for Expense and Category models
- User-specific boxes: `expenses_$userId` and `categories_$userId`
- Storage: IndexedDB (web) / local filesystem (mobile/desktop)
- Initialized in `main.dart` before app starts
- Instant writes (0ms) for offline-first UX

### Firestore Integration ✅ (Phase 3 - Complete)
- Dependencies: `firebase_core`, `firebase_auth`, `cloud_firestore`
- Cloud sync with real-time listeners (1-3s latency)
- User-specific collections: `users/{userId}/expenses`, `users/{userId}/categories`
- Auto-migration: Hive → Firestore on first launch
- Security rules: User-isolated data access only
- Composite indexes for efficient queries

### Authentication ✅ (Phase 2 - Complete)
- Firebase Auth with Google Sign-In
- User profiles with display name and photo
- User-specific data isolation
- Migration from old "user123" data

---

## Testing Natural Language Input

Example inputs to test AI parsing:
- "spent $25 on lunch at McDonald's with Sarah"
- "$67.32 groceries at Walmart"
- "coffee with Mike $18.75"
- "45 dollars on uber to airport"

Expected categories:
- Food & Dining, Transportation, Groceries, Entertainment, Shopping, Healthcare, Other

---

## UI Theme

**Dark Mode Theme:**
- Background: `#1C1C1E` (very dark gray)
- Cards: `#2C2C2E` (dark gray)
- Primary/Accent: `#FFD60A` (bright yellow)
- Text Primary: `#FFFFFF` (white)
- Text Secondary: `#98989D` (light gray)
- Text Tertiary: `#636366` (medium gray)

**Design Language:**
- iOS-inspired aesthetics
- Material Design components
- Clean, minimalist interface
- Mobile-first responsive layout

---

## Common Development Patterns

### Adding a New Screen
1. Create file in `lib/screens/`
2. Extend `StatefulWidget` if state needed
3. Use `StreamBuilder` for reactive data
4. Access services via singleton pattern
5. Add to navigation in `main.dart`

### Accessing Expense Data
```dart
final expenseService = ExpenseService();

// Get data
final total = expenseService.getMonthlyTotal();
final expenses = expenseService.expenses;

// Listen to changes
StreamBuilder<List<Expense>>(
  stream: expenseService.expensesStream,
  builder: (context, snapshot) { ... },
)
```

### Calling Azure OpenAI
```dart
final aiService = AzureOpenAIService();

// Parse expense
final parsed = await aiService.parseExpense("spent \$25 on lunch");

// Get insights
final insights = await aiService.getInsights(
  "What's my total spending?",
  expenseService.getExpenseDataForAI(),
);
```

---

## Known Issues & Limitations

### Current Limitations (Phase 4 Features)
- **No Expense Editing:** Cannot modify existing expenses
- **No Expense Deletion:** Cannot delete existing expenses
- **No Advanced Analytics:** No budgets, trends, or spending goals
- **No Search/Filters:** Cannot search or filter expenses
- **No Data Export:** No CSV/PDF export functionality

### Port Conflicts
- **Issue:** Ports 8080-8082 often in use on Windows
- **Solution:** Use `--web-port=8083` or higher

### Hot Reload Issues
- **Issue:** Sometimes hot reload fails after significant changes
- **Solution:** Use hot restart (R) or stop and restart

---

## Completed Phases ✅

### Phase 1: Local MVP (Feb 12, 2026)
1. ✅ **Hive Persistence** - Data persists locally, never lost
2. ✅ **fl_chart Visualizations** - Interactive pie charts and progress bars
3. ✅ **Voice Input** - speech_to_text with microphone button
4. ✅ **Category CRUD** - Full add/edit/delete with dialogs
5. ✅ **Dynamic Categorization** - AI uses user's actual categories
6. ✅ **Smooth Animations** - Fade-in, slide-up, and staggered animations

See [PHASE1_COMPLETE.md](PHASE1_COMPLETE.md) for full details.

### Phase 2: Firebase Authentication (Feb 13, 2026)
1. ✅ **Google Sign-In** - Firebase Auth integration
2. ✅ **User Profiles** - Display name and photo
3. ✅ **User-Specific Data** - Isolated Hive boxes per user
4. ✅ **Data Migration** - Auto-migrate from old "user123"

### Phase 3: Cloud Sync (Feb 14, 2026)
1. ✅ **Firestore Integration** - Cloud database setup
2. ✅ **Hybrid Sync** - Hive (instant) + Firestore (background)
3. ✅ **Real-Time Listeners** - Multi-device sync (1-3s latency)
4. ✅ **Auto-Migration** - Hive → Firestore one-time transfer
5. ✅ **Sync Indicator** - Cloud icon in Dashboard AppBar

See [FIRESTORE_SYNC_IMPLEMENTATION.md](FIRESTORE_SYNC_IMPLEMENTATION.md) and [PHASE3_QUICK_START.md](PHASE3_QUICK_START.md) for technical details.

### Phase 4: Advanced Features (Feb 16, 2026)
1. ✅ **Expense Editing/Deletion** - Full CRUD with dialogs
2. ✅ **Analytics Screen** - 6-month trends, charts, stats (5th tab)
3. ✅ **Budget Tracking** - Per-category budgets with progress bars
4. ✅ **AI Insights** - Summaries, patterns, predictions, tips
5. ✅ **Search & Filters** - Full-text search, category, date, amount filters
6. ✅ **Data Export** - CSV and text report export
7. ✅ **Recurring Expenses** - Daily/weekly/monthly/yearly schedules

See [PHASE4_COMPLETE.md](PHASE4_COMPLETE.md) for full details.

### Phase 5A: Mobile Optimization - Camera OCR (Feb 19, 2026)
1. ✅ **Camera Receipt Scanning** - Camera/gallery image capture with permissions
2. ✅ **OCR Integration** - Azure Computer Vision API (Read API v3.2)
3. ✅ **AI Receipt Parsing** - Extract amount, merchant, category, date from OCR text
4. ✅ **Review Dialog** - Editable fields before saving expense
5. ✅ **Cross-Platform** - Web (gallery), Android/iOS (camera + gallery)
6. ✅ **New Dependencies** - image_picker, image, permission_handler
7. ✅ **Platform Permissions** - iOS (Info.plist) and Android (AndroidManifest.xml)

Technical implementation: OcrService (~200 lines), parseReceiptText() in AzureOpenAIService, review dialog in ChatScreen.

**Next:** See [MASTER_ROADMAP.md](MASTER_ROADMAP.md) for Phase 5B (Collaborative Features, Receipt Image Storage)

---

## When Adding New Features

1. Check [MASTER_ROADMAP.md](MASTER_ROADMAP.md) for planned specifications
2. Update this file (CLAUDE.md) if making architectural changes
3. Follow existing patterns in screens/ and services/
4. Keep AI prompts in `azure_openai_service.dart` well-structured
5. Test with various natural language inputs
6. Ensure config.dart remains gitignored
7. Update README.md if user-facing features change

---

## Security Best Practices

- **API Keys:** Always in gitignored config.dart
- **Never commit:** config.dart, .env files, any secrets
- **Verify:** .gitignore includes `lib/config/config.dart`
- **HTTPS:** All API calls use secure connections
- **Input Validation:** Sanitize user input before AI processing
- **Error Handling:** Never expose API keys in error messages

---

## Troubleshooting

### "Module not found" errors
- Run `flutter pub get`
- Check pubspec.yaml for correct dependencies
- Restart IDE/editor

### Azure OpenAI errors
- Verify endpoint URL in config.dart
- Check API key is valid and not expired
- Ensure deployment name matches ("gpt-4o")
- Check API version compatibility

### Data not syncing across devices
- ✅ **Fixed** - Firestore cloud sync now implemented
- Check sync status indicator (cloud icon) in Dashboard AppBar
- Yellow cloud = syncing, green cloud = synced
- Sync latency: 1-3 seconds across devices
- Check browser console for Firestore sync messages

### UI looks wrong on mobile
- Test in Chrome DevTools mobile view
- Ensure responsive design with MediaQuery
- Use Scaffold and SafeArea properly

---

## Development Workflow

1. **Start Development:**
   ```bash
   flutter pub get
   flutter run -d chrome --web-port=8083
   ```

2. **Make Changes:**
   - Edit files
   - Press `r` for hot reload
   - Press `R` for hot restart if needed

3. **Test:**
   - Try natural language inputs
   - Check dashboard updates
   - Test AI chat queries

4. **Commit:**
   - Verify config.dart not included
   - Run `flutter analyze`
   - Commit with descriptive message

---

## Resources

- **Flutter Docs:** https://docs.flutter.dev
- **Dart Language:** https://dart.dev
- **Azure OpenAI:** https://azure.microsoft.com/products/ai-services/openai-service
- **Roadmap:** [MASTER_ROADMAP.md](MASTER_ROADMAP.md)
- **Original Design:** [DESIGN.md](DESIGN.md) (needs Flutter update)

---

**Remember:** This is a Flutter app, not iOS/SwiftUI. All documentation should reflect Dart/Flutter implementations, not Swift code.

*Last Updated: February 19, 2026 - Phase 5A Complete (Camera OCR)*
