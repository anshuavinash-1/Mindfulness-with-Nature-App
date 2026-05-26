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
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value != null && value.toString().contains('Timestamp')) {
        try {
          final dynamic d = value.toDate();
          if (d is DateTime) return d;
        } catch (_) {}
      }
      return DateTime.now();
    }

    final prefs = data['preferences'] is Map<String, dynamic>
        ? data['preferences'] as Map<String, dynamic>
        : <String, dynamic>{};

    return User(
      uid: data['uid']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      displayName: data['displayName']?.toString(),
      createdAt: parseDate(data['createdAt']),
      lastLogin: parseDate(data['lastLogin']),
      preferences: UserPreferences.fromMap(prefs),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
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

  const UserPreferences({
    required this.theme,
    required this.notificationsEnabled,
    required this.fontScale,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> data) {
    return UserPreferences(
      theme: data['theme']?.toString() ?? 'forest',
      notificationsEnabled: data['notificationsEnabled'] == true,
      fontScale: (data['fontScale'] as num?)?.toDouble() ?? 1.0,
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
