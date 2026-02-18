// services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart' as app_model;

class AuthService with ChangeNotifier {
  fb.FirebaseAuth? _firebaseAuth;
  FirebaseFirestore? _firestore;

  AuthService() {
    // Lazily attempt to access Firebase instances. If Firebase wasn't
    // initialized this will throw; we catch and keep the fields null so the
    // app continues in degraded mode.
    try {
      _firebaseAuth = fb.FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('AuthService: Firebase not available: $e');
      _firebaseAuth = null;
      _firestore = null;
    }
  }

  String? _userEmail;
  bool _isLoading = false;
  app_model.User? _currentUser;

  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userEmail != null;
  app_model.User? get currentUser => _currentUser;

  Stream<app_model.User?> get authStateChanges {
    // If Firebase isn't available return a single null value stream so the
    // UI can render the unauthenticated state.
    if (_firebaseAuth == null) {
      return Stream.value(null);
    }

    return _firebaseAuth!.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _userEmail = null;
        _currentUser = null;
        notifyListeners();
        return null;
      }
      final app_model.User? user = await _getUserFromFirebaseUser(firebaseUser);
      return user;
    });
  }

  Future<app_model.User?> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _ensureFirebaseAvailable();

      final userCredential = await _firebaseAuth!
          .signInWithEmailAndPassword(email: email, password: password);

      // Update last login
      await _updateLastLogin(userCredential.user!.uid);

      final user = await _getUserFromFirebaseUser(userCredential.user!);
      _userEmail = user?.email;
      _currentUser = user;

      _isLoading = false;
      notifyListeners();
      return user;
    } on fb.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw _handleAuthException(e);
    }
  }

  Future<app_model.User?> signUpWithEmail(String email, String password,
      {String? displayName}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _ensureFirebaseAvailable();

      final userCredential =
          await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name in Firebase Auth if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(displayName);
      }

      // Create user document in Firestore
      await _createUserDocument(userCredential.user!, displayName);

      final user = await _getUserFromFirebaseUser(userCredential.user!);
      _userEmail = user?.email;
      _currentUser = user;

      _isLoading = false;
      notifyListeners();
      return user;
    } on fb.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw _handleAuthException(e);
    }
  }

  // Keep your existing simple login method for backward compatibility
  Future<bool> login(String email, String password) async {
    try {
      final user = await signInWithEmail(email, password);
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // Keep your existing simple signup method for backward compatibility
  Future<bool> signup(
      String email, String password, String confirmPassword) async {
    if (password != confirmPassword || password.length < 6) {
      return false;
    }

    try {
      final user = await signUpWithEmail(email, password);
      return user != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    if (_firebaseAuth != null) {
      await _firebaseAuth!.signOut();
    }
    _userEmail = null;
    _currentUser = null;
    notifyListeners();
  }

  // Keep your existing logout method
  void logout() {
    signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      _ensureFirebaseAvailable();
      await _firebaseAuth!.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      _ensureFirebaseAvailable();

      final user = _firebaseAuth!.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore!.collection('users').doc(user.uid).delete();
        // Delete auth account
        await user.delete();
        _userEmail = null;
        _currentUser = null;
        notifyListeners();
      }
    } on fb.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Helper Methods
  Future<app_model.User?> _getUserFromFirebaseUser(fb.User firebaseUser) async {
    try {
      final doc =
          await _firestore!.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        final user = app_model.User.fromMap(doc.data()!);
        // If displayName is null in Firestore, fall back to Firebase Auth displayName
        if (user.displayName == null && firebaseUser.displayName != null) {
          // Update Firestore with the displayName from Firebase Auth
          await _firestore!.collection('users').doc(firebaseUser.uid).update({
            'displayName': firebaseUser.displayName,
          });
          return user.copyWith(displayName: firebaseUser.displayName);
        }
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  Future<void> _createUserDocument(
      fb.User firebaseUser, String? displayName) async {
    final now = DateTime.now();
    final user = app_model.User(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName: displayName,
      createdAt: now,
      lastLogin: now,
      preferences: app_model.UserPreferences(
        theme: 'forest',
        notificationsEnabled: true,
        fontScale: 1.0,
      ),
    );

    await _firestore!
        .collection('users')
        .doc(firebaseUser.uid)
        .set(user.toMap());
  }

  Future<void> _updateLastLogin(String uid) async {
    await _firestore!.collection('users').doc(uid).update({
      'lastLogin': DateTime.now(),
    });
  }

  void _ensureFirebaseAvailable() {
    if (_firebaseAuth == null || _firestore == null) {
      throw AuthException('Firebase is not initialized');
    }
  }

  AuthException _handleAuthException(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('No user found with this email.');
      case 'wrong-password':
        return AuthException('Incorrect password.');
      case 'email-already-in-use':
        return AuthException('An account already exists with this email.');
      case 'weak-password':
        return AuthException('Password is too weak.');
      case 'invalid-email':
        return AuthException('Email address is invalid.');
      default:
        return AuthException('An unexpected error occurred. Please try again.');
    }
  }
}

// Custom exception class
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
