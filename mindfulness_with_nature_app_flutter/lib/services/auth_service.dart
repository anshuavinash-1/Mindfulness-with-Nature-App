import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  String? _userEmail;
  bool _isLoading = false;

  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 2));
    
    _isLoading = false;
    if (email.isNotEmpty && password.isNotEmpty) {
      _userEmail = email;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<bool> signup(String email, String password, String confirmPassword) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 2));
    
    _isLoading = false;
    if (email.isNotEmpty && password.isNotEmpty && password == confirmPassword) {
      _userEmail = email;
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