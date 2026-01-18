// Canonical user model kept in `user_mode.dart` per project preference.
// This file contains the concrete implementation. `user_model.dart` is a
// compatibility re-export so existing imports continue to work.
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime lastLogin;
  final UserPreferences preferences;

  User({
    required this.uid,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.lastLogin,
    required this.preferences,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    final prefsData = data['preferences'] ?? {};
    return User(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: (data['lastLogin'] as Timestamp).toDate(),
      preferences:
          UserPreferences.fromMap(Map<String, dynamic>.from(prefsData)),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'preferences': preferences.toMap(),
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastLogin,
    UserPreferences? preferences,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
    );
  }
}

class UserPreferences {
  final String theme;
  final bool notificationsEnabled;
  final double fontScale;

  UserPreferences({
    required this.theme,
    required this.notificationsEnabled,
    required this.fontScale,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> data) {
    return UserPreferences(
      theme: data['theme'] ?? 'forest',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      fontScale: (data['fontScale'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'fontScale': fontScale,
    };
  }

  UserPreferences copyWith({
    String? theme,
    bool? notificationsEnabled,
    double? fontScale,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}
