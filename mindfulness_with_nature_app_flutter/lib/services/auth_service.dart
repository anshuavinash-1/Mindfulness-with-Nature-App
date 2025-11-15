import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  String? _userEmail;
  bool _isLoading = false;

  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userEmail != null;

  // Enhanced email validation (matches your login page regex)
  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final emailRe = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final isValidFormat = emailRe.hasMatch(email);
    
    // Additional security checks
    final isReasonableLength = email.length <= 254;
    final hasNoInvalidChars = !email.contains('..') && 
                             !email.contains(' ') &&
                             !email.startsWith('.') &&
                             !email.endsWith('.');
    
    return isValidFormat && isReasonableLength && hasNoInvalidChars;
  }

  bool _isValidPassword(String password) {
    if (password.isEmpty) return false;
    
    // Match your login page requirement (8+ characters)
    final hasMinLength = password.length >= 8;
    final hasMaxLength = password.length <= 128;
    final hasNoSpaces = !password.contains(' ');
    
    return hasMinLength && hasMaxLength && hasNoSpaces;
  }

  bool _passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  String _sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  Future<bool> login(String email, String password) async {
    // Use the same validation as UI for consistency
    final isValidEmail = _isValidEmail(email);
    final isValidPassword = _isValidPassword(password);

    if (!isValidEmail || !isValidPassword) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    
    // Only authenticate if validation passed
    _userEmail = _sanitizeEmail(email);
    notifyListeners();
    return true;
  }

  /// Enhanced signup with proper validation
  Future<bool> signup(
      String email, String password, String confirmPassword) async {
    // Comprehensive validation matching UI rules
    final isValidEmail = _isValidEmail(email);
    final isValidPassword = _isValidPassword(password);
    final doPasswordsMatch = _passwordsMatch(password, confirmPassword);

    if (!isValidEmail || !isValidPassword || !doPasswordsMatch) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    // Simulate API call with validation
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    
    // Only create account if all validations pass
    _userEmail = _sanitizeEmail(email);
    notifyListeners();
    return true;
  }

  void logout() {
    _userEmail = null;
    notifyListeners();
  }

  // Public validation methods that match your UI validators
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    
    final authService = AuthService();
    if (!authService._isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    
    final authService = AuthService();
    if (!authService._isValidPassword(value)) {
      return 'Password must be at least 8 characters with no spaces';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
}