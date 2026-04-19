// Unit tests for User and UserPreferences models.
// 
// These tests verify:
// - Object construction with required and optional fields
// - Firestore data serialization/deserialization (toMap/fromMap)
// - Timestamp conversion between Firestore and DateTime
// - Immutable object copying with copyWith pattern
// - Null handling and default values
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindfulness_with_nature_app_flutter/models/user_model.dart';

void main() {
  // Tests for User model: authentication user data with Firebase integration
  group('User Model', () {
    // Shared test fixtures used across multiple tests
    final testDate = DateTime(2025, 1, 1);
    final testPreferences = UserPreferences(
      theme: 'forest',
      notificationsEnabled: true,
      fontScale: 1.0,
    );

    final testUser = User(
      uid: 'test-uid-123',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: testDate,
      lastLogin: testDate,
      preferences: testPreferences,
    );

    // Tests for User object creation and field assignment
    group('Constructor', () {
      // Test creating a complete User object with all required and optional fields
      test('should create user with all fields', () {
        // Verify all fields are correctly assigned during construction
        expect(testUser.uid, equals('test-uid-123'));
        expect(testUser.email, equals('test@example.com'));
        expect(testUser.displayName, equals('Test User'));
        expect(testUser.createdAt, equals(testDate));
        expect(testUser.lastLogin, equals(testDate));
        expect(testUser.preferences, equals(testPreferences));
      });

      // Test that optional displayName field accepts null values
      test('should create user with null displayName', () {
        final user = User(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: null,
          createdAt: testDate,
          lastLogin: testDate,
          preferences: testPreferences,
        );
        expect(user.displayName, isNull);
      });
    });

    // Tests for deserializing User from Firestore database maps
    group('fromMap', () {
      // Test converting Firestore map with Timestamp fields to User object
      test('should create user from map with Timestamp', () {
        final map = {
          'uid': 'test-uid-123',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'createdAt': Timestamp.fromDate(testDate),
          'lastLogin': Timestamp.fromDate(testDate),
          'preferences': {
            'theme': 'forest',
            'notificationsEnabled': true,
            'fontScale': 1.0,
          },
        };

        final user = User.fromMap(map);
        // Verify proper conversion from Firestore format to User object
        expect(user.uid, equals('test-uid-123'));
        expect(user.email, equals('test@example.com'));
        expect(user.displayName, equals('Test User'));
      });

      // Test that missing uid field defaults to empty string instead of crashing
      test('should handle empty uid with default', () {
        final map = {
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(testDate),
          'lastLogin': Timestamp.fromDate(testDate),
          'preferences': {},
        };

        final user = User.fromMap(map);
        expect(user.uid, equals(''));
      });

      // Test that null displayName in database is preserved (not converted to empty string)
      test('should handle null displayName', () {
        final map = {
          'uid': 'test-uid',
          'email': 'test@example.com',
          'displayName': null,
          'createdAt': Timestamp.fromDate(testDate),
          'lastLogin': Timestamp.fromDate(testDate),
          'preferences': {},
        };

        final user = User.fromMap(map);
        expect(user.displayName, isNull);
      });
    });

    // Tests for serializing User to Firestore database maps
    group('toMap', () {
      // Test converting User object to Firestore map with proper types
      test('should convert user to map', () {
        final map = testUser.toMap();

        // Verify all fields are present in the map
        expect(map['uid'], equals('test-uid-123'));
        expect(map['email'], equals('test@example.com'));
        expect(map['displayName'], equals('Test User'));
        // DateTimes must be converted to Firestore Timestamps
        expect(map['createdAt'], isA<Timestamp>());
        expect(map['lastLogin'], isA<Timestamp>());
        expect(map['preferences'], isA<Map<String, dynamic>>());
      });

      // Test that null displayName is included in map (not omitted)
      test('should include null displayName in map', () {
        final user = User(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: null,
          createdAt: testDate,
          lastLogin: testDate,
          preferences: testPreferences,
        );

        final map = user.toMap();
        expect(map['displayName'], isNull);
      });
    });

    // Tests for creating modified copies of User objects (immutability pattern)
    group('copyWith', () {
      // Test creating a copy with modified uid while keeping other fields unchanged
      test('should copy user with new uid', () {
        final newUser = testUser.copyWith(uid: 'new-uid');
        expect(newUser.uid, equals('new-uid'));
        expect(newUser.email, equals(testUser.email));
      });

      // Test creating a copy with modified email address
      test('should copy user with new email', () {
        final newUser = testUser.copyWith(email: 'new@example.com');
        expect(newUser.email, equals('new@example.com'));
        expect(newUser.uid, equals(testUser.uid));
      });

      // Test creating a copy with modified display name
      test('should copy user with new displayName', () {
        final newUser = testUser.copyWith(displayName: 'New Name');
        expect(newUser.displayName, equals('New Name'));
      });

      // Test that displayName is preserved when not specified in copyWith
      test('should keep displayName when copyWith called without it', () {
        final newUser = testUser.copyWith();
        expect(newUser.displayName, equals(testUser.displayName));
      });

      // Test that copyWith with no arguments creates an identical copy
      test('should copy user without changes', () {
        final newUser = testUser.copyWith();
        expect(newUser.uid, equals(testUser.uid));
        expect(newUser.email, equals(testUser.email));
        expect(newUser.displayName, equals(testUser.displayName));
      });
    });
  });

  // Tests for UserPreferences model: user settings and customization options
  group('UserPreferences Model', () {
    final testPreferences = UserPreferences(
      theme: 'forest',
      notificationsEnabled: true,
      fontScale: 1.5,
    );

    // Tests for UserPreferences object creation
    group('Constructor', () {
      // Test creating UserPreferences with theme, notifications, and font scale
      test('should create preferences with all fields', () {
        expect(testPreferences.theme, equals('forest'));
        expect(testPreferences.notificationsEnabled, isTrue);
        expect(testPreferences.fontScale, equals(1.5));
      });
    });

    // Tests for deserializing UserPreferences from database maps
    group('fromMap', () {
      // Test converting database map to UserPreferences object
      test('should create preferences from map', () {
        final map = {
          'theme': 'ocean',
          'notificationsEnabled': false,
          'fontScale': 2.0,
        };

        final prefs = UserPreferences.fromMap(map);
        expect(prefs.theme, equals('ocean'));
        expect(prefs.notificationsEnabled, isFalse);
        expect(prefs.fontScale, equals(2.0));
      });

      // Test that missing fields use sensible defaults (forest theme, notifications on, 1.0 scale)
      test('should use defaults for missing fields', () {
        final map = <String, dynamic>{};
        final prefs = UserPreferences.fromMap(map);

        expect(prefs.theme, equals('forest'));
        expect(prefs.notificationsEnabled, isTrue);
        expect(prefs.fontScale, equals(1.0));
      });

      // Test that integer fontScale values are converted to double
      test('should handle int fontScale', () {
        final map = {
          'theme': 'forest',
          'notificationsEnabled': true,
          'fontScale': 2,
        };

        final prefs = UserPreferences.fromMap(map);
        expect(prefs.fontScale, equals(2.0));
      });
    });

    // Tests for serializing UserPreferences to database maps
    group('toMap', () {
      // Test converting UserPreferences object to database map
      test('should convert preferences to map', () {
        final map = testPreferences.toMap();

        expect(map['theme'], equals('forest'));
        expect(map['notificationsEnabled'], isTrue);
        expect(map['fontScale'], equals(1.5));
      });
    });

    // Tests for creating modified copies of UserPreferences (immutability pattern)
    group('copyWith', () {
      // Test creating a copy with modified theme setting
      test('should copy preferences with new theme', () {
        final newPrefs = testPreferences.copyWith(theme: 'ocean');
        expect(newPrefs.theme, equals('ocean'));
        expect(newPrefs.notificationsEnabled,
            equals(testPreferences.notificationsEnabled));
      });

      // Test creating a copy with modified notification setting
      test('should copy preferences with new notification setting', () {
        final newPrefs = testPreferences.copyWith(notificationsEnabled: false);
        expect(newPrefs.notificationsEnabled, isFalse);
        expect(newPrefs.theme, equals(testPreferences.theme));
      });

      // Test creating a copy with modified font scale (accessibility)
      test('should copy preferences with new font scale', () {
        final newPrefs = testPreferences.copyWith(fontScale: 2.0);
        expect(newPrefs.fontScale, equals(2.0));
      });

      // Test that copyWith with no arguments creates an identical copy
      test('should copy preferences without changes', () {
        final newPrefs = testPreferences.copyWith();
        expect(newPrefs.theme, equals(testPreferences.theme));
        expect(newPrefs.notificationsEnabled,
            equals(testPreferences.notificationsEnabled));
        expect(newPrefs.fontScale, equals(testPreferences.fontScale));
      });
    });
  });
}
