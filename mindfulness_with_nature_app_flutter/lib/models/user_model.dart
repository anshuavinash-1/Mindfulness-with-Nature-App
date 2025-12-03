// models/app_user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime lastLogin;
  final UserPreferences preferences;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.lastLogin,
    required this.preferences,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      lastLogin: map['lastLogin'] is Timestamp
          ? (map['lastLogin'] as Timestamp).toDate()
          : DateTime.parse(map['lastLogin']),
      preferences: UserPreferences.fromMap(map['preferences'] ?? {}),
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
}

class UserPreferences {
  final String theme;
  final bool notificationsEnabled;
  final double fontScale;

  UserPreferences({
    this.theme = 'forest',
    this.notificationsEnabled = true,
    this.fontScale = 1.0,
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
}
