# SpendWise AI - Feature Specifications

**Version:** 1.0
**Last Updated:** February 11, 2026
**Status:** Active Development

---

## Table of Contents

1. [Feature Overview](#feature-overview)
2. [Feature 1: Natural Language Expense Input](#feature-1-natural-language-expense-input)
3. [Feature 2: Automatic AI Categorization](#feature-2-automatic-ai-categorization)
4. [Feature 3: Dashboard & Insights](#feature-3-dashboard--insights)
5. [Feature 4: Category Management](#feature-4-category-management)
6. [Feature 5: AI Chat Assistant](#feature-5-ai-chat-assistant)
7. [Feature 6: Authentication & Sync](#feature-6-authentication--sync)
8. [Feature 7: Voice Input](#feature-7-voice-input)
9. [AI Prompt Templates](#ai-prompt-templates)
10. [API Contracts](#api-contracts)
11. [Error Handling](#error-handling)
12. [Future Features](#future-features)

---

## Feature Overview

| Feature | Priority | Status | Sprint |
|---------|----------|--------|--------|
| Natural Language Input | P0 | In Development | 2 |
| Auto Categorization | P0 | In Development | 2 |
| Dashboard & Charts | P0 | Planned | 3 |
| Category Management | P1 | Planned | 4 |
| AI Chat Assistant | P1 | Planned | 5 |
| Authentication & Sync | P0 | Planned | 1 |
| Voice Input | P0 | In Development | 2 |

**Priority Levels:**
- P0: Must-have for MVP
- P1: Important for complete experience
- P2: Nice-to-have enhancements
- P3: Future considerations

---

## Feature 1: Natural Language Expense Input

### Description
Users can log expenses by typing natural language descriptions in a chat-style interface. The AI parses the input and extracts structured expense data.

### User Stories

**US-1.1**: As a user, I want to type expense descriptions naturally so I don't have to fill out forms.

**US-1.2**: As a user, I want immediate feedback when I log an expense so I know it was recorded.

**US-1.3**: As a user, I want to see my recent expenses in the chat history so I can review what I've logged.

### Acceptance Criteria

✅ User can type in a text field at bottom of screen
✅ Pressing send/return submits the expense
✅ AI extracts: amount, category, description, person, date
✅ Expense appears as a message bubble in chat
✅ User sees a confirmation with parsed details
✅ Failed parses show error message with retry option
✅ Monthly total updates immediately

### Input Examples

| User Input | Expected Parsing |
|------------|------------------|
| "spent $25 on lunch at McDonald's" | amount: 25, category: Food & Dining, desc: "lunch at McDonald's" |
| "$67.32 groceries at Walmart" | amount: 67.32, category: Groceries, desc: "groceries at Walmart" |
| "coffee with Mike $18.75" | amount: 18.75, category: Food & Dining, person: "Mike", desc: "coffee" |
| "45 dollars on uber" | amount: 45, category: Transportation, desc: "uber" |
| "bought shoes for $120" | amount: 120, category: Shopping, desc: "shoes" |

### Edge Cases

- **No amount specified**: Show error "Please include an amount"
- **Ambiguous category**: AI makes best guess, user can edit
- **Multiple amounts**: Parse first amount found
- **Invalid input**: "What did I spend on?" → Show helpful error
- **Very long description**: Truncate to 200 characters

### Technical Implementation

```swift
// ChatViewModel.swift
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var isProcessing: Bool = false

    private let aiService: AzureOpenAIService
    private let firestoreService: FirestoreService

    func submitExpense() async {
        guard !currentInput.isEmpty else { return }

        isProcessing = true
        defer { isProcessing = false }

        do {
            // 1. Add user message
            let userMessage = ChatMessage(
                content: currentInput,
                isFromUser: true,
                timestamp: Date()
            )
            messages.append(userMessage)

            // 2. Parse with AI
            let parsed = try await aiService.parseExpense(currentInput)

            // 3. Create expense
            let expense = Expense(
                amount: parsed.amount,
                category: parsed.category,
                description: parsed.description,
                person: parsed.person,
                date: parsed.date ?? Date()
            )

            // 4. Save to Firestore
            try await firestoreService.saveExpense(expense)

            // 5. Add confirmation message
            let confirmMessage = ChatMessage(
                content: "Added: \(expense.formattedAmount) - \(expense.description)",
                isFromUser: false,
                timestamp: Date(),
                relatedExpenseId: expense.id
            )
            messages.append(confirmMessage)

            // 6. Clear input
            currentInput = ""

        } catch {
            // Show error message
            let errorMessage = ChatMessage(
                content: "Sorry, I couldn't process that. Please try again.",
                isFromUser: false,
                timestamp: Date()
            )
            messages.append(errorMessage)
        }
    }
}
```

### UI Components

- **ChatView**: Main container with message list and input field
- **MessageBubble**: Individual chat message component
- **ExpenseCard**: Rich display of parsed expense
- **InputBar**: Text field with send button

### Dependencies

- AzureOpenAIService for parsing
- FirestoreService for saving
- ChatMessage model

---

## Feature 2: Automatic AI Categorization

### Description
AI automatically assigns expenses to categories based on description. Users can override if needed.

### Default Categories

1. **Food & Dining** (🍽️)
   - Restaurants, cafes, fast food, coffee shops
   - Example: "lunch", "dinner", "Starbucks", "McDonald's"

2. **Transportation** (🚗)
   - Uber, Lyft, gas, parking, public transit
   - Example: "uber", "gas", "parking", "metro"

3. **Groceries** (🛒)
   - Supermarkets, grocery stores
   - Example: "Walmart", "groceries", "supermarket"

4. **Entertainment** (🎬)
   - Movies, concerts, events, streaming
   - Example: "movie", "Netflix", "concert"

5. **Shopping** (🛍️)
   - Clothing, electronics, general retail
   - Example: "shoes", "Amazon", "mall"

6. **Healthcare** (💊)
   - Doctor, pharmacy, medical
   - Example: "doctor", "pharmacy", "medicine"

7. **Other** (📦)
   - Miscellaneous, uncategorized
   - Fallback category

### User Stories

**US-2.1**: As a user, I want expenses automatically categorized so I don't have to manually select.

**US-2.2**: As a user, I want to edit the category if the AI got it wrong.

**US-2.3**: As a user, I want the AI to learn from my corrections over time.

### Acceptance Criteria

✅ AI assigns category during expense parsing
✅ Category appears in expense confirmation
✅ User can tap to change category
✅ Category changes reflect immediately
✅ AI considers user's correction history in future predictions
✅ Confidence score shown for ambiguous categorizations

### Categorization Logic

```swift
// CategorizationService.swift
class CategorizationService {
    func categorize(description: String, userHistory: [Expense]) async throws -> String {
        // Build prompt with user's past categorization choices
        let examples = buildUserExamples(from: userHistory)

        let prompt = """
        Categorize this expense into one of:
        Food & Dining, Transportation, Groceries, Entertainment,
        Shopping, Healthcare, Other

        User's past categorizations:
        \(examples)

        New expense: "\(description)"

        Return only the category name.
        """

        let category = try await aiService.complete(prompt: prompt)
        return category.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
```

### Learning from Corrections

When user changes a category:
1. Store correction in user profile
2. Include in future prompts as examples
3. After 3+ corrections, prioritize user preference

Example:
- User changes "Starbucks" from "Food & Dining" to "Transportation" 3 times
- Future "Starbucks" expenses default to "Transportation"

---

## Feature 3: Dashboard & Insights

### Description
Visual dashboard showing spending summary, charts, and trends.

### User Stories

**US-3.1**: As a user, I want to see my total spending this month at a glance.

**US-3.2**: As a user, I want to visualize spending breakdown by category.

**US-3.3**: As a user, I want to see spending trends over time.

**US-3.4**: As a user, I want to know which categories I'm spending most on.

### Dashboard Components

#### 1. Summary Cards

**Total Spent**:
- Current month total
- Large, prominent display
- $ formatting

**Active Categories**:
- Number of categories with transactions this month
- Shows budget diversity

#### 2. Spending by Category (Pie Chart)

**Data**:
- Current month expenses grouped by category
- Percentage of total for each category
- Color-coded by category

**Interactions**:
- Tap slice to see category details
- Long press for category insights

#### 3. Monthly Spending Trend (Line Chart)

**Data**:
- Last 6 months of total spending
- Month labels on X-axis
- Dollar amounts on Y-axis

**Insights**:
- Trend line (increasing/decreasing)
- Average monthly spending
- Month with highest spending

#### 4. Recent Transactions

**Display**:
- Last 5 expenses
- Category, description, amount
- Tap to view/edit

### Acceptance Criteria

✅ Dashboard loads within 2 seconds
✅ Charts render smoothly
✅ Data updates in real-time when expenses added
✅ Tap interactions work on all charts
✅ Empty state shown when no data
✅ Pull to refresh updates data

### Technical Implementation

```swift
@MainActor
class DashboardViewModel: ObservableObject {
    @Published var totalSpent: Double = 0
    @Published var activeCategories: Int = 0
    @Published var categoryBreakdown: [CategorySpending] = []
    @Published var monthlyTrend: [MonthlySpending] = []
    @Published var recentExpenses: [Expense] = []

    func loadDashboardData() async {
        async let total = calculateTotalSpent()
        async let categories = calculateCategoryBreakdown()
        async let trend = calculateMonthlyTrend()
        async let recent = fetchRecentExpenses()

        totalSpent = await total
        categoryBreakdown = await categories
        activeCategories = categoryBreakdown.count
        monthlyTrend = await trend
        recentExpenses = await recent
    }
}
```

### Data Models

```swift
struct CategorySpending: Identifiable {
    let id: String
    let category: String
    let amount: Double
    let percentage: Double
    let color: Color
}

struct MonthlySpending: Identifiable {
    let id: String
    let month: String
    let amount: Double
    let date: Date
}
```

---

## Feature 4: Category Management

### Description
Users can view, edit, create, and delete expense categories. AI provides suggestions for optimization.

### User Stories

**US-4.1**: As a user, I want to see all my categories with spending totals.

**US-4.2**: As a user, I want to create custom categories for my specific needs.

**US-4.3**: As a user, I want to edit category names and colors.

**US-4.4**: As a user, I want AI suggestions for optimizing my categories.

**US-4.5**: As a user, I want to see which categories are unused.

### Features

#### 1. Category List

**Display**:
- Category name
- Total spent
- Number of transactions
- Color indicator
- Edit/delete buttons

**Sorting Options**:
- By spending (highest first)
- By transaction count
- Alphabetical

#### 2. AI Category Assistant

**Suggested Prompts**:
- "Suggest new categories"
- "Which categories are unused?"
- "Should I merge any categories?"
- "Analyze my category usage"

**Interactions**:
- Tap prompt to get AI insights
- AI analyzes spending patterns
- Provides actionable recommendations

#### 3. Create Custom Category

**Form Fields**:
- Name (required)
- Color picker
- Icon selector (SF Symbols)

**Validation**:
- Name must be unique
- Max 20 characters
- Cannot use reserved names

#### 4. Edit/Delete Category

**Edit**:
- Change name, color, icon
- Cannot edit default categories

**Delete**:
- Show confirmation dialog
- Reassign expenses to "Other"
- Cannot delete default categories

### Acceptance Criteria

✅ All categories display with correct totals
✅ User can create custom category
✅ User can edit custom categories
✅ User can delete custom categories (with confirmation)
✅ Default categories cannot be deleted
✅ AI suggestions are relevant and helpful
✅ Unused categories highlighted
✅ Changes sync to Firestore immediately

### Category Insights

**Unused Categories**:
- Show categories with 0 transactions in last 30 days
- Suggest deletion or merging

**Over-categorization**:
- If > 10 categories, suggest consolidation
- Identify categories with < 3 transactions

**Under-categorization**:
- If > 30% in "Other", suggest new categories
- Analyze "Other" descriptions for patterns

---

## Feature 5: AI Chat Assistant

### Description
Conversational AI assistant that answers questions about spending, provides insights, and helps with financial planning.

### User Stories

**US-5.1**: As a user, I want to ask questions about my spending in natural language.

**US-5.2**: As a user, I want personalized insights based on my spending patterns.

**US-5.3**: As a user, I want spending advice and recommendations.

**US-5.4**: As a user, I want the AI to remember context during conversation.

### Sample Conversations

#### Example 1: Basic Query

**User**: "What's my total spending this month?"
**AI**: "You've spent $172.56 this month across 5 transactions. That's $27.44 less than your average month!"

#### Example 2: Category Analysis

**User**: "Which category do I spend most on?"
**AI**: "Your biggest expense category is Food & Dining at $67.32 (39% of total). You've made 3 food purchases this month, averaging $22.44 per transaction."

#### Example 3: Trend Analysis

**User**: "Show me food spending trends"
**AI**: "Your food spending has been consistent:
- This month: $67.32 (3 transactions)
- Last month: $54.20 (4 transactions)
- 3 months ago: $71.10 (5 transactions)

You tend to spend more on weekends! 🍽️"

#### Example 4: Planning

**User**: "Can I afford a $200 purchase this month?"
**AI**: "Based on your current spending ($172.56) and average monthly total ($200), a $200 purchase would bring you to $372.56 - about 86% over your usual spending. Consider waiting until next month, or look for ways to reduce other categories."

### Suggested Prompts

**Spending Queries**:
- "What's my total spending?"
- "Which category do I spend most on?"
- "What's my average transaction?"
- "Show me food spending trends"
- "Any spending patterns?"

**Insights & Advice**:
- "How can I save money?"
- "What should I cut back on?"
- "Am I spending more than usual?"
- "What's unusual about my spending?"

**Planning**:
- "Can I afford [amount]?"
- "How much can I spend this week?"
- "Set a budget for [category]"

### Technical Implementation

```swift
@MainActor
class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var isStreaming: Bool = false

    private let aiService: AzureOpenAIService
    private let expenseService: FirestoreService

    func sendMessage() async {
        guard !currentInput.isEmpty else { return }

        // Add user message
        let userMessage = ChatMessage(
            content: currentInput,
            isFromUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)

        // Fetch expense context
        let expenses = await expenseService.fetchExpenses(limit: 50)
        let context = buildExpenseContext(from: expenses)

        // Build conversation history
        let conversationHistory = messages.map {
            "\($0.isFromUser ? "User" : "Assistant"): \($0.content)"
        }.joined(separator: "\n")

        // Create prompt
        let prompt = buildChatPrompt(
            query: currentInput,
            context: context,
            history: conversationHistory
        )

        currentInput = ""

        // Stream response
        var aiMessage = ChatMessage(
            content: "",
            isFromUser: false,
            timestamp: Date()
        )
        messages.append(aiMessage)

        do {
            let stream = try await aiService.streamChatResponse(prompt: prompt)
            for try await chunk in stream {
                aiMessage.content += chunk
                if let index = messages.firstIndex(where: { $0.id == aiMessage.id }) {
                    messages[index] = aiMessage
                }
            }
        } catch {
            aiMessage.content = "Sorry, I encountered an error. Please try again."
            if let index = messages.firstIndex(where: { $0.id == aiMessage.id }) {
                messages[index] = aiMessage
            }
        }
    }
}
```

### Context Building

```swift
func buildExpenseContext(from expenses: [Expense]) -> String {
    let total = expenses.reduce(0) { $0 + $1.amount }
    let categoryBreakdown = Dictionary(grouping: expenses) { $0.category }
        .mapValues { $0.reduce(0) { $0 + $1.amount } }

    return """
    Total Spent: $\(String(format: "%.2f", total))
    Number of Transactions: \(expenses.count)
    Categories: \(categoryBreakdown)
    Recent Expenses: \(expenses.prefix(5).map { "\($0.description): $\($0.amount)" })
    """
}
```

---

## Feature 6: Authentication & Sync

### Description
Google Sign-In authentication with Firestore cloud sync.

### User Stories

**US-6.1**: As a user, I want to sign in with Google so I don't need another password.

**US-6.2**: As a user, I want my data synced across devices.

**US-6.3**: As a user, I want to work offline and sync later.

**US-6.4**: As a user, I want to sign out securely.

### Authentication Flow

1. **First Launch**: Show login screen with "Sign in with Google" button
2. **Sign In**: Google OAuth flow → Firebase Auth
3. **Success**: Navigate to main app
4. **Persistent**: Stay signed in across app launches
5. **Sign Out**: Clear local data, return to login

### Sync Strategy

**Local-First Approach**:
1. All operations work offline (write to local cache)
2. Sync to Firestore when online
3. Conflict resolution: last-write-wins
4. Periodic background sync

### Implementation

```swift
@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = true

    private let auth = Auth.auth()

    func signInWithGoogle() async throws {
        // Google Sign-In flow
        // 1. Get Google credentials
        // 2. Firebase auth with credentials
        // 3. Create/fetch user profile
        // 4. Update currentUser
    }

    func signOut() throws {
        try auth.signOut()
        currentUser = nil
        isAuthenticated = false
    }

    func listenToAuthChanges() {
        auth.addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            if let user = user {
                Task {
                    await self?.fetchUserProfile(uid: user.uid)
                }
            }
        }
    }
}
```

---

## Feature 7: Voice Input

### Description
Speech-to-text for hands-free expense logging.

### User Stories

**US-7.1**: As a user, I want to speak expenses instead of typing.

**US-7.2**: As a user, I want visual feedback while recording.

**US-7.3**: As a user, I want to cancel recording if needed.

### Flow

1. User taps microphone button
2. Request microphone permission (if first time)
3. Start recording (show waveform animation)
4. User speaks: "I spent twenty-five dollars on lunch"
5. User taps stop OR auto-stop after 10 seconds of silence
6. Convert speech to text
7. Submit as expense input
8. Process same as text input

### Acceptance Criteria

✅ Microphone permission requested appropriately
✅ Recording indicator visible while active
✅ Accurate transcription (> 90% accuracy in quiet environment)
✅ Handles background noise gracefully
✅ Cancel button works
✅ Fallback to text input if speech fails

### Implementation

```swift
class SpeechRecognitionService: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var transcription: String = ""

    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionTask: SFSpeechRecognitionTask?

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func startRecording() throws {
        // Set up audio engine
        // Start recognition task
        // Update transcription as words are recognized
    }

    func stopRecording() -> String {
        // Stop audio engine
        // Finalize transcription
        // Return final text
    }
}
```

---

## AI Prompt Templates

### Expense Parsing Prompt

```
You are an expense parser. Extract structured data from natural language.

Input: "{userInput}"

Extract and return ONLY valid JSON in this exact format:
{
  "amount": <number>,
  "category": "<category>",
  "description": "<brief description>",
  "person": "<person name or null>",
  "date": "<ISO date or null>"
}

Categories (choose ONLY from this list):
- Food & Dining
- Transportation
- Groceries
- Entertainment
- Shopping
- Healthcare
- Other

Rules:
- Amount must be a positive number
- Category must be from the list above
- Description should be brief (< 50 chars)
- Person is optional (null if not mentioned)
- Date is optional (null for today)
- Return ONLY the JSON, no other text
```

### Categorization Prompt

```
Categorize this expense description into exactly ONE category.

Description: "{description}"

Categories:
- Food & Dining: restaurants, cafes, food delivery, groceries at restaurants
- Transportation: uber, lyft, gas, parking, public transit, car expenses
- Groceries: supermarkets, grocery stores, food shopping
- Entertainment: movies, concerts, streaming, games, hobbies
- Shopping: clothing, electronics, general retail, online shopping
- Healthcare: doctor, pharmacy, medical expenses, fitness
- Other: anything that doesn't fit above

User's past categorizations:
{userExamples}

Return ONLY the category name, nothing else.
```

### Insights & Chat Prompt

```
You are a friendly, supportive financial assistant helping the user understand their spending.

Personality:
- Conversational and warm
- Encouraging and non-judgmental
- Provide actionable insights
- Use emojis sparingly (1-2 max)
- Keep responses concise (< 150 words)

Context:
{expenseContext}

Conversation History:
{conversationHistory}

User Question: "{query}"

Provide a helpful, insightful response.
```

### Category Suggestions Prompt

```
Analyze the user's expense categories and provide optimization suggestions.

Categories:
{categories}

Recent Expenses (last 30 days):
{recentExpenses}

Provide suggestions for:
1. Unused categories (0 transactions)
2. Categories that could be merged
3. New categories that might be useful
4. Over-categorization (too many categories)

Be specific and actionable. Format as a bulleted list.
```

---

## API Contracts

### Azure OpenAI API

**Endpoint**: `https://{resource-name}.openai.azure.com/openai/deployments/{deployment-id}/chat/completions?api-version=2024-02-15-preview`

**Request**:
```json
{
  "messages": [
    {"role": "system", "content": "..."},
    {"role": "user", "content": "..."}
  ],
  "temperature": 0.7,
  "max_tokens": 500,
  "stream": false
}
```

**Response**:
```json
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "total_tokens": 123
  }
}
```

### Firestore API

**Collections**:
- `/users/{userId}`
- `/users/{userId}/expenses/{expenseId}`
- `/users/{userId}/categories/{categoryId}`

**Expense Document**:
```json
{
  "id": "string",
  "userId": "string",
  "amount": 25.00,
  "category": "Food & Dining",
  "description": "Lunch at McDonald's",
  "person": "Sarah",
  "date": "2026-02-11T12:00:00Z",
  "createdAt": "2026-02-11T12:00:00Z",
  "updatedAt": "2026-02-11T12:00:00Z"
}
```

---

## Error Handling

### Error Types

1. **Network Errors**: No internet connection
2. **API Errors**: Azure/Firebase failures
3. **Parsing Errors**: Invalid input or AI response
4. **Permission Errors**: Microphone access denied
5. **Auth Errors**: Sign-in failures

### Error Messages

| Error Type | User Message | Action |
|------------|--------------|--------|
| No Internet | "You're offline. Your expense will sync when you're back online." | Save locally |
| API Failure | "Something went wrong. Please try again." | Retry button |
| Parse Error | "I couldn't understand that. Try: 'spent $25 on lunch'" | Show example |
| Permission Denied | "Microphone access needed for voice input." | Settings link |
| Auth Failed | "Sign-in failed. Please try again." | Retry |

### Retry Logic

- Exponential backoff for API failures
- Max 3 retries
- Fallback to local-only mode if persistent failures

---

## Future Features

### Phase 2: Enhancements

**Receipt Scanning**:
- Camera capture
- OCR with Vision framework
- Extract amount, merchant, date
- Auto-categorize

**Budget Tracking**:
- Set monthly/category budgets
- Progress indicators
- Alerts when approaching limit

**Recurring Expenses**:
- Mark expenses as recurring
- Auto-log subscriptions
- Reminders for upcoming bills

**Data Export**:
- CSV export
- PDF reports
- Email/share options

### Phase 3: Advanced

**Widgets**:
- Quick expense logging widget
- Monthly total widget
- Category breakdown widget

**Apple Watch**:
- View recent expenses
- Log expenses with Siri
- Daily spending summary

**Siri Shortcuts**:
- "Hey Siri, log expense"
- "Hey Siri, what's my spending?"

**Multi-Currency**:
- Support multiple currencies
- Auto-conversion
- Travel mode

---

## Version History

| Version | Date | Features Added |
|---------|------|----------------|
| 1.0 | Feb 11, 2026 | Initial feature specifications |

---

## Document Maintenance

**Update Triggers**:
- New feature added
- Feature modified
- User stories change
- API contracts update
- Acceptance criteria evolve

**Owner**: Vatsal Khemani
**Last Review**: February 11, 2026
**Next Review**: After Sprint 2 completion
