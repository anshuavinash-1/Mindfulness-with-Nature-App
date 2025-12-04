// services/auth_service.dart
<<<<<<< HEAD
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
=======

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart'; // AppUser model

class AuthService with ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _userEmail;
  bool _isLoading = false;
  AppUser? _currentUser;
>>>>>>> origin/main

  // Getters
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
<<<<<<< HEAD
  bool get isLoggedIn => _userEmail != null;
  app_model.User? get currentUser => _currentUser;

  Stream<app_model.User?> get authStateChanges {
    // If Firebase isn't available return a single null value stream so the
    // UI can render the unauthenticated state.
    if (_firebaseAuth == null) {
      return Stream.value(null);
    }

    return _firebaseAuth!.authStateChanges().asyncMap((firebaseUser) async {
=======
  AppUser? get currentUser => _currentUser;

  // -----------------------------------------------------
  //  FIX OPTION 2 – This stream MUST return fb.User?
  // -----------------------------------------------------
  Stream<fb.User?> get authStateChanges {
    return _auth.authStateChanges().map((firebaseUser) {
>>>>>>> origin/main
      if (firebaseUser == null) {
        _currentUser = null;
        _userEmail = null;
        notifyListeners();
        return null;
      }
<<<<<<< HEAD
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
=======

      // Load Firestore data in background (non-blocking)
      _loadUserModel(firebaseUser);

      return firebaseUser; // <--- FIXED: return fb.User NOT AppUser
    });
  }

  // Background loader (non-blocking)
  Future<void> _loadUserModel(fb.User fbUser) async {
    final model = await _getUserModel(fbUser);
    _currentUser = model;
    _userEmail = model?.email;
    notifyListeners();
  }

  // -----------------------------------------------------
  //  LOGIN
  // -----------------------------------------------------
  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _updateLastLogin(cred.user!.uid);

      // Firestore model loads automatically from stream
    } on fb.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } finally {
      _setLoading(false);
    }
  }

  // -----------------------------------------------------
  //  SIGNUP
  // -----------------------------------------------------
  Future<void> signUpWithEmail(String email, String password) async {
    _setLoading(true);

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _createUserDocument(cred.user!);

      // Firestore model loads automatically
    } on fb.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } finally {
      _setLoading(false);
    }
  }

  // -----------------------------------------------------
  //  PASSWORD RESET
  // -----------------------------------------------------
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
>>>>>>> origin/main
      throw _handleAuthException(e);
    }
  }

<<<<<<< HEAD
  Future<app_model.User?> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _ensureFirebaseAvailable();

      final userCredential =
          await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _createUserDocument(userCredential.user!);

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
=======
  // -----------------------------------------------------
  //  SIGN OUT
  // -----------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
>>>>>>> origin/main
    _userEmail = null;
    _currentUser = null;
    notifyListeners();
  }

<<<<<<< HEAD
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
=======
  // -----------------------------------------------------
  //  DELETE ACCOUNT
  // -----------------------------------------------------
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
>>>>>>> origin/main
        await user.delete();

        _userEmail = null;
        _currentUser = null;
        notifyListeners();
      }
    } on fb.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

<<<<<<< HEAD
  // Helper Methods
  Future<app_model.User?> _getUserFromFirebaseUser(fb.User firebaseUser) async {
    try {
      final doc =
          await _firestore!.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return app_model.User.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
=======
  // -----------------------------------------------------
  //  FIRESTORE HELPERS
  // -----------------------------------------------------

  Future<AppUser?> _getUserModel(fb.User firebaseUser) async {
    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (!doc.exists) {
      await _createUserDocument(firebaseUser);
      final newDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      return AppUser.fromMap(newDoc.data()!);
>>>>>>> origin/main
    }

    return AppUser.fromMap(doc.data()!);
  }

  Future<void> _createUserDocument(fb.User firebaseUser) async {
    final now = DateTime.now();
<<<<<<< HEAD
    final user = app_model.User(
=======

    final user = AppUser(
>>>>>>> origin/main
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName ?? "",
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

<<<<<<< HEAD
  void _ensureFirebaseAvailable() {
    if (_firebaseAuth == null || _firestore == null) {
      throw AuthException('Firebase is not initialized');
    }
  }

=======
  // -----------------------------------------------------
  //  ERROR HANDLER
  // -----------------------------------------------------
>>>>>>> origin/main
  AuthException _handleAuthException(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('No user found with this email.');
      case 'wrong-password':
        return AuthException('Incorrect password.');
      case 'email-already-in-use':
        return AuthException('Email already exists.');
      case 'weak-password':
        return AuthException('Password is too weak.');
      case 'invalid-email':
        return AuthException('Invalid email format.');
      default:
        return AuthException('Unexpected error. Try again.');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

// ---------------------------------------------------------
//  CUSTOM EXCEPTION
// ---------------------------------------------------------
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
<<<<<<< HEAD

=======
>>>>>>> origin/main
  @override
  String toString() => message;
}
