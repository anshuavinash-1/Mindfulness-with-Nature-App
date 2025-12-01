// services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../contracts/auth_service_contract.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier implements AuthServiceContract {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _userEmail;
  bool _isLoading = false;
  User? _currentUser;

  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userEmail != null;
  User? get currentUser => _currentUser;

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) {
      if (firebaseUser == null) {
        _userEmail = null;
        _currentUser = null;
        notifyListeners();
        return null;
      }
      return _getUserFromFirebaseUser(firebaseUser);
    });
  }

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login
      await _updateLastLogin(userCredential.user!.uid);

      final user = await _getUserFromFirebaseUser(userCredential.user!);
      _userEmail = user?.email;
      _currentUser = user;

      _isLoading = false;
      notifyListeners();
      return user;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw _handleAuthException(e);
    }
  }

  @override
  Future<User?> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
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
    } on FirebaseAuthException catch (e) {
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

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _userEmail = null;
    _currentUser = null;
    notifyListeners();
  }

  // Keep your existing logout method
  void logout() {
    signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        // Delete auth account
        await user.delete();
        _userEmail = null;
        _currentUser = null;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Helper Methods
  Future<User?> _getUserFromFirebaseUser(User firebaseUser) async {
    try {
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return User.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> _createUserDocument(User firebaseUser) async {
    final now = DateTime.now();
    final user = User(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName,
      createdAt: now,
      lastLogin: now,
      preferences: UserPreferences(
        theme: 'forest',
        notificationsEnabled: true,
        fontScale: 1.0,
      ),
    );

    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(user.toMap());
  }

  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': Timestamp.fromDate(DateTime.now()),
    });
  }

  AuthException _handleAuthException(FirebaseAuthException e) {
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
