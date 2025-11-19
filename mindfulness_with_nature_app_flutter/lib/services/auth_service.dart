import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  static const String _userEmailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  String? _userEmail;
  String? _authToken;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  String? get userEmail => _userEmail;
  String? get authToken => _authToken;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userEmail != null && _authToken != null;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  // Navigation callbacks for other pages
  VoidCallback? navigateToMeditation;
  VoidCallback? navigateToJourney;

  AuthService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadAuthState();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _userEmail = prefs.getString(_userEmailKey);
      _authToken = prefs.getString(_authTokenKey);
      
      final userDataJson = prefs.getString(_userDataKey);
      if (userDataJson != null) {
        _userData = Map<String, dynamic>.from(jsonDecode(userDataJson));
      }

      // Validate that we have both email and token for logged in state
      if (_userEmail == null || _authToken == null) {
        _userEmail = null;
        _authToken = null;
        _userData = null;
        await prefs.remove(_isLoggedInKey);
      }

      if (kDebugMode) {
        print('AuthService: Loaded auth state - loggedIn: $isLoggedIn, user: $_userEmail');
      }
    } catch (e) {
      _error = 'Failed to load authentication state';
      if (kDebugMode) {
        print('AuthService: Error loading auth state - $e');
      }
    }
  }

  Future<bool> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_userEmail != null) {
        await prefs.setString(_userEmailKey, _userEmail!);
        await prefs.setBool(_isLoggedInKey, true);
      } else {
        await prefs.remove(_userEmailKey);
        await prefs.remove(_isLoggedInKey);
      }

      if (_authToken != null) {
        await prefs.setString(_authTokenKey, _authToken!);
      } else {
        await prefs.remove(_authTokenKey);
      }

      if (_userData != null) {
        await prefs.setString(_userDataKey, jsonEncode(_userData!));
      } else {
        await prefs.remove(_userDataKey);
      }

      return true;
    } catch (e) {
      _error = 'Failed to save authentication state';
      if (kDebugMode) {
        print('AuthService: Error saving auth state - $e');
      }
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      final trimmedEmail = email.trim().toLowerCase();
      
      // Enhanced validation
      if (!_isValidEmail(trimmedEmail)) {
        _error = 'Please enter a valid email address';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.isEmpty) {
        _error = 'Please enter your password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _error = 'Password must be at least 6 characters';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Simulate successful login
      // In a real app, this would be an API call to your backend
      _userEmail = trimmedEmail;
      _authToken = _generateAuthToken(trimmedEmail);
      _userData = {
        'email': trimmedEmail,
        'name': _extractNameFromEmail(trimmedEmail),
        'joinedAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
        'preferences': {
          'theme': 'light',
          'notifications': true,
          'dailyReminders': true,
        }
      };

      final success = await _saveAuthState();
      
      if (!success) {
        _userEmail = null;
        _authToken = null;
        _userData = null;
        _error = 'Failed to save login state';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('AuthService: User logged in successfully - $_userEmail');
      }
      
      return true;
    } catch (e) {
      _error = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('AuthService: Login error - $e');
      }
      return false;
    }
  }

  Future<bool> signup(String email, String password, String confirmPassword) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      final trimmedEmail = email.trim().toLowerCase();
      
      // Enhanced validation
      if (!_isValidEmail(trimmedEmail)) {
        _error = 'Please enter a valid email address';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.isEmpty || confirmPassword.isEmpty) {
        _error = 'Please fill in all password fields';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password != confirmPassword) {
        _error = 'Passwords do not match';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _error = 'Password must be at least 6 characters';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!_isStrongPassword(password)) {
        _error = 'Password should include uppercase, lowercase, and numbers';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Simulate successful signup
      // In a real app, this would be an API call to your backend
      _userEmail = trimmedEmail;
      _authToken = _generateAuthToken(trimmedEmail);
      _userData = {
        'email': trimmedEmail,
        'name': _extractNameFromEmail(trimmedEmail),
        'joinedAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
        'preferences': {
          'theme': 'light',
          'notifications': true,
          'dailyReminders': true,
        },
        'stats': {
          'meditationSessions': 0,
          'moodEntries': 0,
          'currentStreak': 0,
        }
      };

      final success = await _saveAuthState();
      
      if (!success) {
        _userEmail = null;
        _authToken = null;
        _userData = null;
        _error = 'Failed to save account';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('AuthService: User signed up successfully - $_userEmail');
      }
      
      return true;
    } catch (e) {
      _error = 'Signup failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('AuthService: Signup error - $e');
      }
      return false;
    }
  }

  Future<void> logout() async {
    _userEmail = null;
    _authToken = null;
    _userData = null;
    _error = null;
    
    await _saveAuthState();
    notifyListeners();

    if (kDebugMode) {
      print('AuthService: User logged out');
    }
  }

  Future<bool> updateUserData(Map<String, dynamic> updates) async {
    if (_userData == null) return false;

    try {
      _userData = {..._userData!, ...updates};
      final success = await _saveAuthState();
      
      if (success) {
        notifyListeners();
        if (kDebugMode) {
          print('AuthService: User data updated');
        }
      }
      
      return success;
    } catch (e) {
      _error = 'Failed to update user data';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (newPassword.length < 6) {
        _error = 'New password must be at least 6 characters';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!_isStrongPassword(newPassword)) {
        _error = 'New password should include uppercase, lowercase, and numbers';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Simulate successful password change
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('AuthService: Password changed successfully');
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to change password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> clearError() async {
    _error = null;
    notifyListeners();
  }

  // Validation helpers
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&"*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+'
    );
    return emailRegex.hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    // At least one uppercase, one lowercase, one number
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigits = RegExp(r'[0-9]').hasMatch(password);
    
    return hasUppercase && hasLowercase && hasDigits;
  }

  String _generateAuthToken(String email) {
    // In a real app, this would come from your backend
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'mock_token_${email}_$timestamp';
  }

  String _extractNameFromEmail(String email) {
    final namePart = email.split('@').first;
    return namePart[0].toUpperCase() + namePart.substring(1);
  }

  // Check if user exists (for demo purposes)
  Future<bool> checkUserExists(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate checking against existing users
    final existingUsers = ['demo@mindfulness.com', 'test@example.com'];
    return existingUsers.contains(email.toLowerCase());
  }

  // Forgot password simulation
  Future<bool> requestPasswordReset(String email) async {
    if (!_isValidEmail(email)) {
      _error = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    // Always return true in demo to avoid revealing which emails exist
    notifyListeners();
    return true;
  }
}