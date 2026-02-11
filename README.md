# SpendWise AI 💰🤖

An AI-powered expense tracking iOS app that makes managing your finances effortless. Track expenses through natural language (text or voice), get automatic categorization, visualize spending patterns, and chat with your AI financial buddy.

## Overview

SpendWise AI is your intelligent expense tracking companion. Simply tell it what you spent - like "spent $25 on lunch at McDonald's with Sarah" - and it automatically logs, categorizes, and analyzes your expenses. No forms, no hassle, just natural conversation.

### Key Features

- **🎙️ Natural Language Input**: Type or speak your expenses naturally
- **🤖 AI Auto-Categorization**: Azure OpenAI automatically categorizes expenses
- **📊 Visual Dashboard**: Beautiful charts showing spending patterns and trends
- **💬 AI Chat Assistant**: Ask questions about your spending, get insights and recommendations
- **🏷️ Smart Categories**: Manage and customize expense categories with AI suggestions
- **🔄 Cloud Sync**: Google Sign-In with Firebase for seamless data sync across devices
- **📱 Offline Support**: Works offline, syncs when connected

## Tech Stack

- **Platform**: iOS 16+
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Backend**: Firebase/Firestore
- **Authentication**: Firebase Auth (Google Sign-In)
- **AI**: Azure OpenAI API (GPT-4)
- **Voice**: iOS Speech Recognition Framework
- **Charts**: Swift Charts
- **Data**: SwiftData/Core Data (local) + Firestore (cloud)

## Project Structure

```
SpendWiseAI/
├── .gitignore                     # Prevents API key leaks
├── README.md                      # This file
├── DESIGN.md                      # Design decisions and architecture
├── FEATURES.md                    # Detailed feature specifications
├── SpendWiseAI.xcodeproj/         # Xcode project
├── SpendWiseAI/
│   ├── App/
│   │   ├── SpendWiseAIApp.swift   # Main app entry point
│   │   └── Config.swift           # API keys (gitignored)
│   ├── Models/                    # Data models
│   ├── Views/                     # SwiftUI views
│   ├── ViewModels/                # View models (business logic)
│   ├── Services/                  # API services (Azure, Firebase, Auth)
│   ├── Components/                # Reusable UI components
│   ├── Utilities/                 # Helpers and extensions
│   └── Resources/                 # Assets, fonts, etc.
└── SpendWiseAITests/              # Unit tests
```

## Prerequisites

Before you begin, ensure you have:

- macOS with Xcode 15+ installed
- iOS 16+ target device or simulator
- Azure OpenAI account with API access
- Firebase project set up
- Google Cloud Console project (for Google Sign-In)
- Apple Developer account (for device testing)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/vatsalkhemani/SpendWise-AI.git
cd SpendWise\ AI
```

### 2. Azure OpenAI Setup

1. Go to [Azure Portal](https://portal.azure.com)
2. Create an Azure OpenAI resource
3. Deploy a GPT-4 model
4. Note your:
   - API Endpoint
   - API Key
   - Deployment Name

### 3. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project (or use existing)
3. Add an iOS app to your project
4. Download `GoogleService-Info.plist`
5. Enable **Firestore Database**:
   - Start in production mode
   - Choose a location
6. Enable **Authentication**:
   - Go to Authentication > Sign-in method
   - Enable Google Sign-In
7. Set up Firestore Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Configure the Project

1. Open the project in Xcode:
   ```bash
   open SpendWiseAI.xcodeproj
   ```

2. Add `GoogleService-Info.plist` to the project (drag into Xcode)

3. Create `Config.swift` in the `App/` folder:

```swift
// Config.swift
// ⚠️ This file is gitignored - never commit API keys!

import Foundation

struct AzureOpenAIConfig {
    static let endpoint = "YOUR_AZURE_ENDPOINT"
    static let apiKey = "YOUR_AZURE_API_KEY"
    static let deploymentName = "gpt-4"
    static let apiVersion = "2024-02-15-preview"
}

struct AppConfig {
    static let appName = "SpendWise AI"
    static let bundleIdentifier = "com.yourcompany.spendwiseai"
}
```

4. Replace placeholders with your actual values

### 5. Install Dependencies

The project uses Swift Package Manager. Dependencies will be resolved automatically when you build.

Required packages:
- Firebase iOS SDK
- Firebase Auth
- Firebase Firestore

### 6. Build and Run

1. Select your target device/simulator
2. Press `Cmd + R` to build and run
3. Sign in with Google when prompted
4. Start tracking expenses!

## Development Principles

This project follows these core principles:

✅ **Always maintain DESIGN.md and FEATURES.md** - Update when making changes
✅ **Focus on functionality** - Working features over optimization
✅ **Keep it clean and simple** - Avoid over-engineering
✅ **API security first** - Never commit API keys or secrets
✅ **Test voice input thoroughly** - Core feature that must work well

## Usage Examples

### Adding Expenses

**Text Input:**
- "spent $67.32 on groceries at Walmart"
- "$25.50 lunch at McDonald's with Sarah"
- "coffee with Mike $18.75"

**Voice Input:**
- Tap microphone icon
- Speak naturally: "I spent forty-five dollars on transportation"
- AI processes and categorizes automatically

### AI Chat Queries

- "What's my total spending this month?"
- "Which category do I spend most on?"
- "Show me food spending trends"
- "Can I afford a $200 purchase this month?"
- "What's my average transaction amount?"

## Features Roadmap

### Phase 1: MVP ✅ (Current)
- Natural language expense input (text + voice)
- AI auto-categorization
- Dashboard with charts
- Category management
- AI chat assistant
- Google authentication
- Cloud sync

### Phase 2: Enhancements
- Receipt scanning with OCR
- Budget alerts and notifications
- Recurring expense tracking
- Data export (CSV, PDF)
- Dark mode support

### Phase 3: Advanced
- iOS Widget for quick logging
- Apple Watch companion app
- Siri shortcuts integration
- Advanced analytics and forecasting
- Multi-currency support

## API Cost Considerations

**Azure OpenAI Usage:**
- Each expense input: ~500 tokens (~$0.01)
- Each chat query: ~1000-2000 tokens (~$0.02-$0.04)
- Estimated monthly cost for active user: ~$5-10

**Firebase:**
- Free tier includes:
  - 50K reads/day
  - 20K writes/day
  - 1GB storage
- Typical user well within free limits

## Security

- All API keys stored in `Config.swift` (gitignored)
- Firestore security rules enforce user data isolation
- Google Sign-In handles authentication securely
- No sensitive data stored locally unencrypted
- HTTPS for all API calls

## Testing

### Manual Testing Checklist

- [ ] Google Sign-In works
- [ ] Text expense input parses correctly
- [ ] Voice input recognizes speech accurately
- [ ] AI categorizes expenses appropriately
- [ ] Expenses sync to Firestore
- [ ] Dashboard displays correct totals
- [ ] Charts render spending data
- [ ] Categories can be edited/created
- [ ] AI chat responds with relevant insights
- [ ] Offline mode works (local cache)
- [ ] App syncs when back online

### Voice Testing Scenarios

- Quiet environment
- Background noise (café, street)
- Different accents
- Various expense formats
- Long/complex descriptions

## Troubleshooting

### Build Errors

**Missing GoogleService-Info.plist:**
- Download from Firebase Console
- Add to Xcode project root

**Config.swift not found:**
- Create file as shown in setup instructions
- Ensure it's added to target

**Azure API errors:**
- Verify endpoint URL is correct
- Check API key is valid
- Ensure deployment name matches

### Runtime Issues

**Voice input not working:**
- Check microphone permissions in Settings
- Ensure running on physical device (not simulator)

**Firestore sync failing:**
- Verify internet connection
- Check Firebase security rules
- Ensure user is authenticated

## Contributing

This is a personal project, but feedback and suggestions are welcome! Feel free to:
- Open issues for bugs or feature requests
- Submit pull requests with improvements
- Share your experience using the app

## License

MIT License - See LICENSE file for details

## Author

Vatsal Khemani ([@vatsalkhemani](https://github.com/vatsalkhemani))

## Acknowledgments

- Azure OpenAI for AI capabilities
- Firebase for backend infrastructure
- SwiftUI community for inspiration
- Design inspiration from modern expense trackers

---

**Built with ❤️ and AI to make expense tracking effortless**

## Support

For questions or issues:
- Email: vatsalkhemani@gmail.com
- GitHub Issues: [Create an issue](https://github.com/vatsalkhemani/SpendWise-AI/issues)

---

Last Updated: February 11, 2026
