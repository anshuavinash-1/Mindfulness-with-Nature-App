// models/user_model.dart
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

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      createdAt: DateTime.parse(map['createdAt']),
      lastLogin: DateTime.parse(map['lastLogin']),
      preferences: UserPreferences(
        theme: map['preferences']?['theme'] ?? 'forest',
        notificationsEnabled: map['preferences']?['notificationsEnabled'] ?? true,
        fontScale: (map['preferences']?['fontScale'] ?? 1.0).toDouble(),
      ),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'preferences': {
        'theme': preferences.theme,
        'notificationsEnabled': preferences.notificationsEnabled,
        'fontScale': preferences.fontScale,
      },
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
}

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
