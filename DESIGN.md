# SpendWise AI - Design Document

**Version:** 1.0
**Last Updated:** February 11, 2026
**Status:** Active Development

---

## Table of Contents

1. [Design Philosophy](#design-philosophy)
2. [Architecture Overview](#architecture-overview)
3. [Technical Stack](#technical-stack)
4. [App Architecture](#app-architecture)
5. [Data Models](#data-models)
6. [Service Layer](#service-layer)
7. [UI/UX Design](#uiux-design)
8. [Navigation Flow](#navigation-flow)
9. [AI Integration](#ai-integration)
10. [Security & Privacy](#security--privacy)
11. [Performance Considerations](#performance-considerations)
12. [Design Decisions](#design-decisions)

---

## Design Philosophy

### Core Principles

1. **Simplicity First**: Keep the user experience simple and intuitive. No complex forms or multiple steps.
2. **Natural Interaction**: Users should interact with the app as they would with a friend - through natural language.
3. **AI-Powered**: Leverage AI to reduce manual work (categorization, insights, analysis).
4. **Functionality Over Optimization**: Working features are more valuable than perfect optimization.
5. **Clean Code**: Write maintainable, readable code without over-engineering.

### User Experience Goals

- **Effortless Input**: Expense logging should take < 10 seconds
- **Instant Feedback**: Immediate visual confirmation of actions
- **Intelligent Defaults**: AI makes smart assumptions, user can override
- **Conversational**: Feel like talking to a helpful financial buddy

---

## Architecture Overview

### Pattern: MVVM (Model-View-ViewModel)

We use MVVM because:
- Natural fit for SwiftUI
- Clear separation of concerns
- Testable business logic
- Reactive data binding with Combine

```
┌─────────────────────────────────────────┐
│            SwiftUI Views                │
│   (UI Layer - Declarative Interface)    │
└───────────────┬─────────────────────────┘
                │ @StateObject
                │ @ObservedObject
┌───────────────▼─────────────────────────┐
│           ViewModels                    │
│  (Business Logic & State Management)    │
└───────────────┬─────────────────────────┘
                │ Calls
                │
┌───────────────▼─────────────────────────┐
│            Services                     │
│  (API, Auth, Database, Speech)          │
└───────────────┬─────────────────────────┘
                │ Uses
                │
┌───────────────▼─────────────────────────┐
│            Models                       │
│      (Data Structures)                  │
└─────────────────────────────────────────┘
```

---

## Technical Stack

### Frontend
- **SwiftUI**: Modern declarative UI framework
- **iOS 16+**: Target minimum iOS version
- **Swift Charts**: Native charting library for visualizations

### Backend & Services
- **Firebase/Firestore**: Real-time NoSQL database
- **Firebase Auth**: Google Sign-In authentication
- **Azure OpenAI**: GPT-4 for AI features

### Local Storage
- **SwiftData**: Modern Core Data wrapper (iOS 17+)
- **UserDefaults**: Simple key-value storage for preferences

### APIs & Networking
- **URLSession**: Native HTTP client
- **Combine**: Reactive programming for async operations

### Voice & Speech
- **Speech Framework**: iOS native speech recognition
- **AVFoundation**: Audio recording and playback

---

## App Architecture

### Project Structure

```
SpendWiseAI/
├── App/
│   ├── SpendWiseAIApp.swift       # App entry point
│   ├── Config.swift               # API keys (gitignored)
│   └── AppDelegate.swift          # Optional lifecycle hooks
│
├── Models/
│   ├── Expense.swift              # Expense data model
│   ├── Category.swift             # Category data model
│   ├── User.swift                 # User profile model
│   └── ChatMessage.swift          # AI chat message model
│
├── Views/
│   ├── Main/
│   │   ├── MainTabView.swift      # Tab navigation container
│   │   ├── ChatView.swift         # Expense input chat interface
│   │   ├── DashboardView.swift    # Analytics dashboard
│   │   ├── CategoriesView.swift   # Category management
│   │   └── AIChatView.swift       # AI assistant chat
│   ├── Auth/
│   │   ├── LoginView.swift        # Google Sign-In screen
│   │   └── OnboardingView.swift   # First-time user flow
│   └── Shared/
│       └── LoadingView.swift      # Reusable loading state
│
├── ViewModels/
│   ├── ChatViewModel.swift        # Expense input logic
│   ├── DashboardViewModel.swift   # Dashboard data aggregation
│   ├── CategoriesViewModel.swift  # Category CRUD operations
│   ├── AIChatViewModel.swift      # AI conversation logic
│   └── AuthViewModel.swift        # Authentication state
│
├── Services/
│   ├── AI/
│   │   ├── AzureOpenAIService.swift      # Azure API client
│   │   └── ExpenseParserService.swift    # NLP expense parsing
│   ├── Auth/
│   │   └── AuthService.swift             # Firebase Auth wrapper
│   ├── Database/
│   │   ├── FirestoreService.swift        # Firestore CRUD
│   │   └── LocalStorageService.swift     # Local cache
│   └── Speech/
│       └── SpeechRecognitionService.swift # Voice input
│
├── Components/
│   ├── Cards/
│   │   ├── ExpenseCard.swift      # Single expense display
│   │   └── CategoryCard.swift     # Category summary card
│   ├── Charts/
│   │   ├── PieChartView.swift     # Spending by category
│   │   └── TrendChartView.swift   # Monthly trend line
│   ├── Input/
│   │   ├── VoiceButton.swift      # Microphone button
│   │   └── MessageBubble.swift    # Chat bubble component
│   └── Common/
│       ├── CategoryPill.swift     # Category badge
│       └── EmptyStateView.swift   # No data placeholder
│
├── Utilities/
│   ├── Extensions/
│   │   ├── Date+Extensions.swift  # Date formatting
│   │   ├── Double+Extensions.swift # Currency formatting
│   │   └── Color+Extensions.swift # Custom colors
│   ├── Constants.swift            # App-wide constants
│   └── NetworkMonitor.swift       # Connectivity detection
│
└── Resources/
    ├── Assets.xcassets            # Images, colors, icons
    ├── GoogleService-Info.plist   # Firebase config (gitignored)
    └── Localizable.strings        # Localization (future)
```

---

## Data Models

### Expense Model

```swift
struct Expense: Identifiable, Codable {
    var id: String
    var userId: String
    var amount: Double
    var category: String
    var description: String
    var person: String?
    var date: Date
    var createdAt: Date
    var updatedAt: Date

    // Computed properties
    var formattedAmount: String {
        return "$\(String(format: "%.2f", amount))"
    }
}
```

### Category Model

```swift
struct Category: Identifiable, Codable {
    var id: String
    var name: String
    var color: String          // Hex color
    var icon: String           // SF Symbol name
    var isDefault: Bool
    var totalSpent: Double
    var transactionCount: Int

    // Predefined categories
    static let defaultCategories = [
        "Food & Dining",
        "Transportation",
        "Groceries",
        "Entertainment",
        "Shopping",
        "Healthcare",
        "Other"
    ]
}
```

### User Model

```swift
struct User: Identifiable, Codable {
    var id: String             // Firebase UID
    var email: String
    var displayName: String
    var photoURL: String?
    var createdAt: Date
    var customCategories: [String]
    var preferences: UserPreferences
}

struct UserPreferences: Codable {
    var currency: String = "USD"
    var voiceEnabled: Bool = true
    var notificationsEnabled: Bool = false
}
```

### ChatMessage Model

```swift
struct ChatMessage: Identifiable, Codable {
    var id: String
    var content: String
    var isFromUser: Bool
    var timestamp: Date
    var relatedExpenseId: String?
}
```

---

## Service Layer

### 1. AzureOpenAIService

**Purpose**: Handle all Azure OpenAI API calls

```swift
class AzureOpenAIService {
    func parseExpense(_ input: String) async throws -> ParsedExpense
    func categorizeExpense(_ description: String) async throws -> String
    func generateInsight(for expenses: [Expense], query: String) async throws -> String
    func streamChatResponse(messages: [ChatMessage]) -> AsyncThrowingStream<String, Error>
}
```

**Key Features**:
- Async/await for modern concurrency
- Error handling with custom errors
- Streaming support for chat
- Retry logic for transient failures

### 2. FirestoreService

**Purpose**: Database operations (CRUD)

```swift
class FirestoreService {
    func saveExpense(_ expense: Expense) async throws
    func fetchExpenses(for userId: String, limit: Int?) async throws -> [Expense]
    func updateExpense(_ expense: Expense) async throws
    func deleteExpense(id: String) async throws

    func saveCategory(_ category: Category, for userId: String) async throws
    func fetchCategories(for userId: String) async throws -> [Category]
}
```

### 3. AuthService

**Purpose**: Authentication management

```swift
class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false

    func signInWithGoogle() async throws -> User
    func signOut() throws
    func listenToAuthChanges()
}
```

### 4. SpeechRecognitionService

**Purpose**: Voice-to-text conversion

```swift
class SpeechRecognitionService {
    func requestAuthorization() async -> Bool
    func startRecording() throws
    func stopRecording() -> String
    var isRecording: Bool { get }
}
```

---

## UI/UX Design

### Design System

#### Color Palette

```swift
extension Color {
    // Primary
    static let primaryBackground = Color(hex: "#1C1C1E")  // Dark background
    static let secondaryBackground = Color(hex: "#2C2C2E") // Card background
    static let accentColor = Color(hex: "#FFD60A")        // Yellow accent

    // Category Colors
    static let foodDining = Color(hex: "#FF9F40")
    static let transportation = Color(hex: "#4A90E2")
    static let groceries = Color(hex: "#4CAF50")
    static let entertainment = Color(hex: "#9B59B6")
    static let shopping = Color(hex: "#E91E63")
    static let healthcare = Color(hex: "#F44336")
    static let other = Color(hex: "#9E9E9E")
}
```

#### Typography

```swift
extension Font {
    static let heading1 = Font.system(size: 32, weight: .bold)
    static let heading2 = Font.system(size: 24, weight: .semibold)
    static let body = Font.system(size: 16, weight: .regular)
    static let caption = Font.system(size: 14, weight: .regular)
}
```

#### Spacing

```swift
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}
```

### Screen Designs

#### 1. Chat View (Main Expense Input)
- Bottom text field with microphone button
- Chat bubbles showing conversation history
- Recent expenses displayed as cards
- Monthly total at bottom
- Natural, conversational feel

#### 2. Dashboard
- Summary cards (Total Spent, Categories Count)
- Pie chart (Spending by Category)
- Line chart (Monthly Trend)
- Clean, minimalist layout
- Easy to scan at a glance

#### 3. Categories View
- List of categories with transaction counts
- AI Category Assistant section with suggested prompts
- Add new category button
- Edit/delete actions
- Category insights (most used, unused)

#### 4. AI Chat Assistant
- Full-screen chat interface
- Suggested prompts for common queries
- Natural conversation with AI
- Context-aware responses based on expense data

---

## Navigation Flow

### Tab-Based Navigation

```
┌─────────────────────────────────────┐
│         MainTabView                 │
│  ┌─────┬─────┬─────┬─────────┐    │
│  │Chat │Dash │Cats │AI Chat  │    │
│  └──┬──┴──┬──┴──┬──┴────┬────┘    │
└─────┼─────┼─────┼───────┼──────────┘
      │     │     │       │
      ▼     ▼     ▼       ▼
   ChatView Dashboard Categories AIChatView
```

### Authentication Flow

```
App Launch
    │
    ├─ Not Authenticated → LoginView → MainTabView
    │                          ↓
    └─ Authenticated ──────────┘
```

---

## AI Integration

### Azure OpenAI Implementation

#### 1. Expense Parsing

**Input**: Natural language text
**Process**: Send to GPT-4 with structured prompt
**Output**: Structured JSON

```swift
let prompt = """
You are an expense parser. Extract structured data from natural language input.

Input: "\(userInput)"

Output JSON format:
{
  "amount": <number>,
  "category": "<category>",
  "description": "<description>",
  "person": "<person or null>",
  "date": "<ISO date or null for today>"
}

Categories: Food & Dining, Transportation, Groceries, Entertainment, Shopping, Healthcare, Other
"""
```

#### 2. Category Suggestions

**Context**: User's spending patterns
**Process**: Analyze and suggest optimizations
**Output**: Natural language suggestions

```swift
let prompt = """
Analyze the user's expense categories and provide helpful suggestions:
- Which categories are unused?
- Should any categories be merged?
- Are there patterns that suggest new categories?

Categories: \(categories)
Recent expenses: \(expenses)
"""
```

#### 3. Insights & Chat

**Context**: Full expense history
**Process**: Answer user queries conversationally
**Output**: Friendly, helpful responses

```swift
let prompt = """
You are a friendly financial assistant helping the user understand their spending.
Be conversational, supportive, and provide actionable insights.

User question: "\(query)"
Expense data: \(expenseSummary)
"""
```

---

## Security & Privacy

### API Key Management

1. **Never commit API keys**: Config.swift is gitignored
2. **Environment-based**: Use different keys for dev/prod
3. **Key rotation**: Plan for periodic key updates

### Data Privacy

1. **User isolation**: Firestore rules enforce per-user access
2. **No PII in logs**: Sanitize logging
3. **Local encryption**: Sensitive data encrypted at rest
4. **Secure transmission**: HTTPS for all API calls

### Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

---

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Load expenses in batches
2. **Local Caching**: Store recent data locally with SwiftData
3. **Debouncing**: Delay API calls for search/filter
4. **Image Caching**: Cache user profile photos
5. **Background Sync**: Sync data in background when possible

### API Cost Management

1. **Token Limits**: Set max tokens for OpenAI calls
2. **Caching**: Cache AI responses when appropriate
3. **Batch Operations**: Combine multiple categorizations
4. **Rate Limiting**: Prevent excessive API usage

### Memory Management

1. **Pagination**: Load expenses in pages (50 at a time)
2. **Dispose Resources**: Properly cancel tasks
3. **Weak References**: Avoid retain cycles in closures
4. **Asset Optimization**: Compress images and assets

---

## Design Decisions

### Why Native iOS vs Flutter?

**Decision**: Native iOS (Swift + SwiftUI)

**Reasons**:
1. Voice input is core feature - iOS handles this best
2. Better native feel and performance
3. Easier integration with iOS frameworks
4. Can always port to Android later with Flutter
5. Simpler codebase for single platform

### Why Firebase vs Custom Backend?

**Decision**: Firebase/Firestore

**Reasons**:
1. Fast setup - focus on app, not infrastructure
2. Real-time sync out of the box
3. Google Auth integration
4. Generous free tier
5. Automatic scaling
6. Offline support built-in

### Why Azure OpenAI vs OpenAI Direct?

**Decision**: Azure OpenAI

**Reasons**:
1. Enterprise-grade reliability
2. Better SLA and support
3. Data residency options
4. Easier compliance (if needed)
5. Consistent with enterprise use

### Why MVVM vs MVC/VIPER?

**Decision**: MVVM

**Reasons**:
1. Natural fit for SwiftUI
2. Simpler than VIPER (no over-engineering)
3. Better than MVC for testability
4. Industry standard for SwiftUI apps
5. Clear separation of concerns

---

## Future Considerations

### Planned Improvements

1. **Receipt Scanning**: OCR with Vision framework
2. **Budget Tracking**: Set limits and get alerts
3. **Recurring Expenses**: Auto-log subscription payments
4. **Export Data**: CSV/PDF reports
5. **Dark Mode**: Explicit theme support
6. **Widgets**: Quick expense logging from home screen
7. **Watch App**: Apple Watch companion
8. **Siri Shortcuts**: "Hey Siri, log expense"

### Scalability

- **User Growth**: Firebase scales automatically
- **Data Volume**: Firestore query optimization
- **API Costs**: Monitor and optimize AI usage
- **Performance**: Profile and optimize bottlenecks

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Feb 11, 2026 | Initial design document |

---

## Maintenance

This document should be updated when:
- Major architectural changes occur
- New features are added
- Technology stack changes
- Design patterns evolve

**Document Owner**: Vatsal Khemani
**Last Review**: February 11, 2026
**Next Review**: As needed based on development progress
