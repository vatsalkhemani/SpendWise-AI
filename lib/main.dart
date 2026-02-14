import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/chat_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/login_screen.dart';
import 'services/expense_service.dart';
import 'services/auth_service.dart';
import 'models/expense.dart';
import 'models/category.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(CategoryAdapter());

  // Initialize AuthService (listens to auth state changes)
  AuthService().init();

  runApp(const SpendWiseApp());
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWise AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFD60A),
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        cardColor: const Color(0xFF2C2C2E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD60A),
          secondary: Color(0xFFFFD60A),
          surface: Color(0xFF2C2C2E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1C1E),
          elevation: 0,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

/// Auth Gate - Routes to LoginScreen or AuthenticatedApp based on auth state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateStream,
      initialData: AuthService().currentUser,
      builder: (context, snapshot) {
        // Check if user is authenticated
        final user = snapshot.data;
        if (user != null) {
          return AuthenticatedApp(userId: user.uid);
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

/// Authenticated App - Initializes ExpenseService for user and shows main app
class AuthenticatedApp extends StatefulWidget {
  final String userId;

  const AuthenticatedApp({
    super.key,
    required this.userId,
  });

  @override
  State<AuthenticatedApp> createState() => _AuthenticatedAppState();
}

class _AuthenticatedAppState extends State<AuthenticatedApp> {
  bool _isInitialized = false;
  bool _migrationChecked = false;

  @override
  void initState() {
    super.initState();
    _initializeForUser();
  }

  Future<void> _initializeForUser() async {
    try {
      // Initialize ExpenseService for this user
      await ExpenseService().initForUser(widget.userId);

      // Check if we need to migrate old user123 data (first sign-in only)
      if (!_migrationChecked) {
        final prefs = await SharedPreferences.getInstance();
        final hasMigrated = prefs.getBool('migrated_user123') ?? false;

        if (!hasMigrated) {
          // Try to migrate old data
          await ExpenseService().migrateUser123Data(widget.userId);
          await prefs.setBool('migrated_user123', true);
        }

        _migrationChecked = true;
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing for user: $e');
      // Even on error, show the app
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF1C1C1E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFFFFD60A),
              ),
              SizedBox(height: 16),
              Text(
                'Loading your data...',
                style: TextStyle(
                  color: Color(0xFF98989D),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ChatScreen(),
    const DashboardScreen(),
    const CategoriesScreen(),
    const AIChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF2C2C2E),
        selectedItemColor: const Color(0xFFFFD60A),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'AI Chat',
          ),
        ],
      ),
    );
  }
}
