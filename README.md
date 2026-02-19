# SpendWise AI

**AI-powered expense tracking made effortless.**

SpendWise AI is a cross-platform expense tracking application that uses artificial intelligence to automatically categorize and analyze your spending. Simply tell it what you spent—by typing, speaking, or photographing a receipt—and let AI handle the rest.

Built with Flutter for Web, iOS, Android, and Desktop.

[![Flutter](https://img.shields.io/badge/Flutter-3.38.9-blue)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.8-blue)](https://dart.dev)

---

## Screenshots

<div align="center">

<table>
  <tr>
    <td align="center" width="50%">
      <img src="lib/Images/image (3).jpg" width="100%" alt="Chat Screen"><br>
      <b>Chat Screen</b><br>
      Natural Language & Voice Input
    </td>
    <td align="center" width="50%">
      <img src="lib/Images/image (4).jpg" width="100%" alt="Dashboard"><br>
      <b>Dashboard</b><br>
      Live Analytics & Spending Overview
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <img src="lib/Images/image (5).jpg" width="100%" alt="Categories"><br>
      <b>Categories</b><br>
      Budget Tracking & Management
    </td>
    <td align="center" width="50%">
      <img src="lib/Images/image (6).jpg" width="100%" alt="Analytics"><br>
      <b>Analytics</b><br>
      6-Month Trends & AI Insights
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2">
      <img src="lib/Images/image (8).png" width="50%" alt="All Expenses"><br>
      <b>All Expenses</b><br>
      Search & Advanced Filters
    </td>
  </tr>
</table>

</div>

---

## Why SpendWise AI?

Traditional expense tracking is tedious. SpendWise AI changes that by understanding natural language and automating the entire process. No forms to fill, no categories to select—just tell it what you spent and move on with your day.

**Three ways to log expenses:**
- Type naturally: "spent $25 on lunch at Chipotle"
- Speak: Tap the microphone and say it
- Snap: Take a photo of your receipt

The AI automatically extracts the amount, categorizes the expense, and syncs it across all your devices instantly.

---

## Core Features

### Intelligent Input
- **Natural Language Processing**: Type expenses as you would tell a friend
- **Voice Recognition**: Speak your expenses hands-free
- **Receipt Scanning**: Photograph receipts for automatic data extraction
- **Smart Categorization**: AI automatically assigns categories based on context

### Analytics & Insights
- **Real-time Dashboard**: See your spending at a glance with interactive charts
- **Trend Analysis**: Track spending patterns over 6 months
- **Budget Tracking**: Set budgets per category with visual progress indicators
- **AI Insights**: Get personalized spending summaries and recommendations

### Data Management
- **Edit & Delete**: Full control over your expense history
- **Advanced Search**: Filter by category, date range, amount, or description
- **Recurring Expenses**: Set up automatic tracking for regular bills
- **Data Export**: Download your data as CSV or formatted reports

### Sync & Collaboration
- **Cloud Sync**: Automatic synchronization across all devices
- **Real-time Updates**: Changes appear instantly on all your devices
- **Offline Support**: Works without internet, syncs when reconnected
- **User Profiles**: Google Sign-In with secure authentication

---

## Technology Stack

### Frontend
- **Flutter 3.38.9** - Cross-platform UI framework
- **Dart 3.10.8** - Programming language
- **Material Design** - Modern, responsive UI components

### AI & Machine Learning
- **Azure OpenAI (GPT-4o)** - Natural language understanding and insights
- **Azure Computer Vision** - Receipt OCR and text extraction

### Backend Services
- **Firebase Authentication** - Secure Google Sign-In
- **Cloud Firestore** - Real-time cloud database
- **Hive** - Local database for offline support

### Key Libraries
- `fl_chart` - Interactive charts and visualizations
- `speech_to_text` - Voice input recognition
- `image_picker` - Camera and gallery access
- `cloud_firestore` - Cloud synchronization

---

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Azure OpenAI API access
- Azure Computer Vision API access (for receipt scanning)
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

3. **Configure API Keys**

Create `lib/config/config.dart` with your API credentials:

```dart
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
}

class Config {
  static const String azureVisionEndpoint = 'YOUR_VISION_ENDPOINT';
  static const String azureVisionApiKey = 'YOUR_VISION_API_KEY';
}

class FirebaseConfig {
  static const String apiKey = 'YOUR_FIREBASE_API_KEY';
  static const String projectId = 'YOUR_PROJECT_ID';
  static const String webClientId = 'YOUR_WEB_CLIENT_ID';
}
```

**Note:** This file is gitignored for security. Never commit API keys to version control.

4. **Set up Firebase**

- Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/)
- Enable Google Authentication
- Enable Cloud Firestore
- Download configuration files for your platforms

5. **Run the application**

```bash
# For web
flutter run -d chrome

# For mobile
flutter run

# For iOS (requires macOS)
flutter run -d ios
```

---

## Usage

### Adding Expenses

**Text Input:**
```
spent $67.32 on groceries at Walmart
$25.50 lunch with Sarah
coffee $4.50
```

**Voice Input:**
1. Tap the microphone icon
2. Speak your expense naturally
3. AI processes and saves automatically

**Receipt Scanning:**
1. Tap the camera icon
2. Choose "Take Photo" or "Choose from Gallery"
3. Review the extracted data
4. Confirm or edit before saving

### Managing Budgets

1. Navigate to Categories
2. Tap the wallet icon next to any category
3. Enter your monthly budget
4. Track spending with visual progress bars

### Searching Expenses

1. Go to the All Expenses tab
2. Use the search bar for text search
3. Apply filters for category, date range, or amount
4. Clear filters with the chip buttons

### Exporting Data

1. Open the Dashboard
2. Tap the menu icon in the top right
3. Select CSV or Text Report format
4. File downloads automatically

---

## Project Structure

```
lib/
├── main.dart                      # Application entry point
├── config/
│   └── config.dart               # API configuration (gitignored)
├── models/
│   ├── expense.dart              # Expense data model
│   └── category.dart             # Category data model
├── services/
│   ├── azure_openai_service.dart # AI integration
│   ├── ocr_service.dart          # Receipt scanning
│   ├── expense_service.dart      # Data management
│   ├── firestore_service.dart    # Cloud sync
│   └── auth_service.dart         # Authentication
├── screens/
│   ├── chat_screen.dart          # Expense input
│   ├── dashboard_screen.dart     # Analytics overview
│   ├── categories_screen.dart    # Category management
│   ├── analytics_screen.dart     # Detailed analytics
│   └── ai_chat_screen.dart       # AI assistant
└── theme/
    └── app_theme.dart            # UI theming
```

---

## Development

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Hot Reload

While the app is running:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Building for Production

```bash
# Web
flutter build web --release

# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## Cost Considerations

### Azure OpenAI
- Approximately $0.01-0.02 per expense entry
- Estimated $5-15 per month for regular use

### Azure Computer Vision
- Free tier: 5,000 transactions per month
- Most users stay within the free tier
- Paid tier: $1.50 per 1,000 transactions

### Firebase
- Authentication: Free
- Firestore: Free tier includes 50K reads/day, 20K writes/day
- Typical usage stays within free tier limits

---

## Security

- API keys are stored in gitignored `config.dart`
- All API calls use HTTPS
- Firebase security rules enforce user data isolation
- User authentication via secure OAuth (Google Sign-In)

**Important:** Never commit `lib/config/config.dart` to version control.

---

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## Documentation

For detailed technical documentation, see:

- [CLAUDE.md](CLAUDE.md) - Developer guide and architecture
- [MASTER_ROADMAP.md](docs/MASTER_ROADMAP.md) - Project roadmap
- [docs/](docs/) - Additional technical documentation

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Author

**Vatsal Khemani**

- GitHub: [@vatsalkhemani](https://github.com/vatsalkhemani)

---

## Acknowledgments

- Azure OpenAI for natural language processing
- Azure Computer Vision for receipt OCR
- Flutter team for the excellent framework
- Firebase for backend infrastructure

---

Built with Flutter and AI to make expense tracking effortless.
