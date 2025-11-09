import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  String? _userEmail;
  bool _isLoading = false;

  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userEmail != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    _isLoading = false;
    final trimmedEmail = email.trim();
    if (trimmedEmail.isNotEmpty && password.isNotEmpty) {
      _userEmail = trimmedEmail;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  /// Simple signup implementation that mirrors [login].
  /// In a real app this should call your backend.
  Future<bool> signup(String email, String password, String confirmPassword) async {
    _isLoading = true;
    notifyListeners();

    // Basic client-side checks
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    final trimmedEmail = email.trim();
    if (trimmedEmail.isNotEmpty && password.isNotEmpty && password == confirmPassword && password.length >= 6) {
      _userEmail = trimmedEmail;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  void logout() {
    _userEmail = null;
    notifyListeners();
  }
}