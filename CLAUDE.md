# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SpendWise AI is an AI-powered expense tracking app built with **Flutter** that uses natural language input to log and categorize expenses. The app integrates with **Azure OpenAI (GPT-4o)** for intelligent expense parsing and financial insights.

**Platform:** Flutter (cross-platform: Web, iOS, Android)
**Architecture:** MVVM pattern (Models, Views/Screens, Services)
**AI Provider:** Azure OpenAI API
**Current Status:** MVP development - core functionality implemented, Firebase integration pending

## Development Commands

### Running the App
```bash
# Get dependencies
flutter pub get

# Run on Chrome (recommended for development)
flutter run -d chrome

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

### Code Generation & Analysis
```bash
# Generate code (for future Hive/JSON serialization)
flutter pub run build_runner build

# Watch mode for continuous generation
flutter pub run build_runner watch

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

### Cleaning
```bash
# Clean build artifacts
flutter clean

# Then reinstall dependencies
flutter pub get
```

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
│   (Future: FirebaseService)  │
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
  - **`lib/services/`** - Business logic (Azure OpenAI integration)
- **`test/`** - Unit and widget tests

### Critical Files

**`lib/config/config.dart`** (GITIGNORED - contains secrets):
- Azure OpenAI endpoint, API key, deployment name
- App configuration and feature flags
- Default categories with colors and icons
- **NEVER commit this file** - it's in .gitignore for security

**`lib/services/azure_openai_service.dart`**:
- `parseExpense()` - Parses natural language input → structured expense data
- `categorizeExpense()` - Auto-categorizes expense descriptions
- `getInsights()` - Provides AI-driven spending insights
- `streamChatResponse()` - Powers the AI chat assistant

**`lib/main.dart`**:
- App theme (dark mode with yellow accent #FFD60A)
- Navigation structure (4-tab BottomNavigationBar)
- MaterialApp configuration

## Development Principles (from DESIGN.md)

1. **Simplicity First** - Keep UX simple, avoid complex forms
2. **Natural Interaction** - Natural language input is core to the experience
3. **AI-Powered** - Leverage AI to minimize manual work
4. **Functionality Over Optimization** - Working features > perfect code
5. **Clean Code** - Maintainable and readable, avoid over-engineering

**Critical Rules:**
- ✅ **Always maintain DESIGN.md and FEATURES.md** when making architectural changes
- ✅ **API Security First** - Never commit API keys or secrets
- ✅ **Focus on Functionality** - Ship working features over premature optimization

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

**Cost Considerations:**
- ~500 tokens per expense input (~$0.01)
- ~1000-2000 tokens per chat query (~$0.02-$0.04)

## State Management

**Current:** Basic `setState()` for local state management
**Future:** May add Provider/Riverpod when Firebase integration requires global state

## Data Persistence

**Current:** In-memory only (data lost on restart)
**Planned:**
- Local: Hive (dev dependencies already include `hive_generator`, `build_runner`)
- Cloud: Firebase Firestore (dependencies commented out in pubspec.yaml)
- Authentication: Firebase Auth with Google Sign-In

## Testing Natural Language Input

Example inputs to test AI parsing:
- "spent $25 on lunch at McDonald's with Sarah"
- "$67.32 groceries at Walmart"
- "coffee with Mike $18.75"
- "45 dollars on uber"

Expected categories:
- Food & Dining, Transportation, Groceries, Entertainment, Shopping, Healthcare, Other

## UI Theme

**Dark Mode Theme:**
- Background: `#1C1C1E`
- Cards: `#2C2C2E`
- Primary/Accent: `#FFD60A` (Yellow)
- Text: White/Grey shades

## Known Issues & Future Work

**Not Yet Implemented:**
- Firebase authentication (packages commented out)
- Data persistence (local or cloud)
- Voice input (speech_to_text)
- Charts/visualizations (fl_chart)
- Category CRUD operations (UI exists, backend pending)

**README.md Discrepancy:**
- README describes iOS/SwiftUI implementation
- **Actual implementation is Flutter** (as of Feb 11, 2026)
- Consider updating README to reflect Flutter migration

## When Adding New Features

1. Check FEATURES.md for planned specifications
2. Update DESIGN.md if making architectural changes
3. Follow existing patterns in screens/ and services/
4. Keep AI prompts in `azure_openai_service.dart` well-structured
5. Test with various natural language inputs
6. Ensure config.dart remains gitignored
