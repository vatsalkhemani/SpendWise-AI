# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SpendWise AI is an **AI-powered expense tracking app** built with **Flutter** that uses **natural language input** to log and categorize expenses. The app integrates with **Azure OpenAI (GPT-4o)** for intelligent expense parsing and financial insights.

**Platform:** Flutter (cross-platform: Web, iOS, Android, Desktop)
**Architecture:** MVVM pattern (Models, Services, Screens)
**AI Provider:** Azure OpenAI API
**Current Status:** MVP core complete, Phase 1 features pending

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
- In-memory storage with reactive StreamControllers
- Provides analytics methods (totals, averages, category breakdowns)
- Will be extended with Hive/Firebase persistence in Phase 1/2

**`lib/services/azure_openai_service.dart`**:
- `parseExpense()` - Parses natural language input → structured expense data
- `categorizeExpense()` - Auto-categorizes expense descriptions
- `getInsights()` - Provides AI-driven spending insights
- `streamChatResponse()` - Powers the AI chat assistant

**`lib/main.dart`**:
- App theme (dark mode with yellow accent #FFD60A)
- Navigation structure (4-tab BottomNavigationBar)
- MaterialApp configuration
- ExpenseService initialization

---

## Current Implementation Status

### ✅ What's Implemented (MVP Core)

1. **Natural Language Expense Input** (`lib/screens/chat_screen.dart`)
   - Chat-style interface for entering expenses
   - AI parsing via Azure OpenAI
   - Real-time monthly total display
   - Transaction count tracking
   - Message history with user/AI bubbles

2. **Live Analytics Dashboard** (`lib/screens/dashboard_screen.dart`)
   - Monthly spending total
   - Active category count
   - Spending breakdown by category with percentages
   - Recent expenses list (last 5)
   - Reactive updates via StreamBuilder

3. **Category Management** (`lib/screens/categories_screen.dart`)
   - 7 default categories with color coding
   - Real-time spending per category
   - Transaction counts
   - AI Category Assistant UI (placeholder)

4. **AI Chat Assistant** (`lib/screens/ai_chat_screen.dart`)
   - Question/answer interface
   - Suggested prompt chips
   - Context-aware responses using expense data
   - Chat history with timestamps

5. **Data Management** (`lib/services/expense_service.dart`)
   - Singleton service pattern
   - In-memory storage with StreamControllers
   - Reactive updates across all screens
   - Analytics calculations

### ⚠️ What's NOT Yet Implemented

1. **Data Persistence** - ❌ Data lost on page refresh (in-memory only)
2. **Voice Input** - ❌ UI exists but speech-to-text not integrated
3. **Charts** - ❌ Placeholders only, fl_chart not added
4. **Category CRUD** - ❌ Edit/Delete buttons not functional
5. **Firebase** - ❌ No cloud sync or authentication
6. **Expense Editing** - ❌ Cannot modify/delete existing expenses

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

**Current:** In-memory only (data lost on restart)
**Phase 1 Plan:** Add Hive for local persistence
**Phase 2 Plan:** Add Firebase Firestore for cloud sync

### Hive Integration (Planned)
- Dependencies: `hive`, `hive_flutter`, `hive_generator`, `build_runner`
- Already in `dev_dependencies` but not yet used
- Will replace in-memory lists in ExpenseService

### Firebase Integration (Planned)
- Dependencies commented out in pubspec.yaml
- Will add: `firebase_core`, `firebase_auth`, `cloud_firestore`
- Authentication: Firebase Auth with Google Sign-In

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

### Current Limitations
- **Data Persistence:** Data only in memory, lost on refresh
- **Voice Input:** UI exists but not functional
- **Charts:** Placeholders only, no actual visualizations
- **Category CRUD:** Edit/Delete buttons don't work
- **No Authentication:** All users share same data ("user123")
- **No Cloud Sync:** Everything is local

### Port Conflicts
- **Issue:** Ports 8080-8082 often in use on Windows
- **Solution:** Use `--web-port=8083` or higher

### Hot Reload Issues
- **Issue:** Sometimes hot reload fails after significant changes
- **Solution:** Use hot restart (R) or stop and restart

---

## Phase 1 Features (Next Steps)

See [MASTER_ROADMAP.md](MASTER_ROADMAP.md) for detailed breakdown.

**Priority Order:**
1. **Add Hive Persistence** (~30 min) - Never lose data
2. **Add fl_chart Visualizations** (~45 min) - Pie/line charts
3. **Implement Voice Input** (~30 min) - speech_to_text integration
4. **Enable Category CRUD** (~30 min) - Add/edit/delete categories

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

### Data not persisting
- **Expected behavior** - no persistence yet
- Phase 1 will add Hive for local storage
- Phase 2 will add Firebase for cloud sync

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

*Last Updated: February 12, 2026*
