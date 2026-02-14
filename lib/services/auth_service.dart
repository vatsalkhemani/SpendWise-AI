// auth_service.dart
// Firebase Authentication Service - Singleton Pattern
// Handles Google Sign-In and auth state management

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication Service - Singleton
/// Manages Firebase Authentication and Google Sign-In
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  // Auth state stream controller
  final _authStateController = StreamController<User?>.broadcast();

  // Public auth state stream
  Stream<User?> get authStateStream => _authStateController.stream;

  // Current user getters
  User? get currentUser => _auth.currentUser;
  String? get userId => _auth.currentUser?.uid;
  String? get userEmail => _auth.currentUser?.email;
  String? get userDisplayName => _auth.currentUser?.displayName;
  String? get userPhotoUrl => _auth.currentUser?.photoURL;

  // Is user signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Initialize the service and listen to auth state changes
  void init() {
    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((User? user) {
      _authStateController.add(user);
    });

    // Emit current state immediately
    _authStateController.add(_auth.currentUser);
  }

  /// Sign in with Google
  /// Returns the User object on success, null on cancellation
  /// Throws on error
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user cancels the sign-in
      if (googleUser == null) {
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Firebase auth errors
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      // Other errors (network, etc.)
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  /// Sign out from Firebase and Google
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Get user display name or fallback
  String getUserDisplayName() {
    return userDisplayName ?? userEmail ?? 'User';
  }

  /// Get user initials for avatar
  String getUserInitials() {
    final name = getUserDisplayName();
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  /// Get user photo URL or null
  String? getUserPhotoUrl() {
    return userPhotoUrl;
  }

  /// Handle Firebase Auth errors
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-credential':
        return 'The credential is invalid or has expired.';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled. Please contact support.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with these credentials.';
      case 'wrong-password':
        return 'Invalid password.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication failed: ${e.message ?? "Unknown error"}';
    }
  }

  /// Dispose resources (call when app is closing)
  void dispose() {
    _authStateController.close();
  }
}
