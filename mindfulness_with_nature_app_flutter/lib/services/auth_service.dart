// services/auth_service.dart

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

  // Getters
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  AppUser? get currentUser => _currentUser;

  // -----------------------------------------------------
  //  FIX OPTION 2 – This stream MUST return fb.User?
  // -----------------------------------------------------
  Stream<fb.User?> get authStateChanges {
    return _auth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        _currentUser = null;
        _userEmail = null;
        notifyListeners();
        return null;
      }

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
      throw _handleAuthException(e);
    }
  }

  // -----------------------------------------------------
  //  SIGN OUT
  // -----------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
    _userEmail = null;
    _currentUser = null;
    notifyListeners();
  }

  // -----------------------------------------------------
  //  DELETE ACCOUNT
  // -----------------------------------------------------
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();

        _userEmail = null;
        _currentUser = null;
        notifyListeners();
      }
    } on fb.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // -----------------------------------------------------
  //  FIRESTORE HELPERS
  // -----------------------------------------------------

  Future<AppUser?> _getUserModel(fb.User firebaseUser) async {
    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (!doc.exists) {
      await _createUserDocument(firebaseUser);
      final newDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      return AppUser.fromMap(newDoc.data()!);
    }

    return AppUser.fromMap(doc.data()!);
  }

  Future<void> _createUserDocument(fb.User firebaseUser) async {
    final now = DateTime.now();

    final user = AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName ?? "",
      createdAt: now,
      lastLogin: now,
      preferences: UserPreferences(
        theme: 'forest',
        notificationsEnabled: true,
        fontScale: 1.0,
      ),
    );

    await _firestore.collection('users').doc(firebaseUser.uid).set(user.toMap());
  }

  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': Timestamp.fromDate(DateTime.now()),
    });
  }

  // -----------------------------------------------------
  //  ERROR HANDLER
  // -----------------------------------------------------
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
  @override
  String toString() => message;
}
