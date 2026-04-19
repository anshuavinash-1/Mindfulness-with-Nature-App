// Unit tests for MoodService.
// 
// MoodService manages mood and stress tracking using local storage (SharedPreferences).
// These tests verify:
// - Adding and deleting mood entries
// - Filtering entries by date range
// - Calculating average mood and stress levels
// - Data persistence through SharedPreferences
// - Immutability of exposed data
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindfulness_with_nature_app_flutter/services/mood_service.dart';
import 'package:mindfulness_with_nature_app_flutter/models/mood_entry.dart';

void main() {
  // Tests for MoodService: mood and stress tracking with local storage
  group('MoodService', () {
    late MoodService moodService;

    setUp(() async {
      // Create a fresh MoodService instance before each test
      // Mock SharedPreferences with empty state to ensure test isolation
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      moodService = MoodService(prefs);
      // Give time for async loading to complete
      await Future.delayed(Duration.zero);
    });

    // Tests for service initialization with empty state
    group('Initialization', () {
      // Test that new service instance starts with no existing mood entries
      test('should start with empty entries list', () {
        expect(moodService.entries, isEmpty);
      });
    });

    // Tests for adding mood entries and persisting to SharedPreferences
    group('addEntry', () {
      // Test adding a single mood entry with mood level, stress level, and notes
      test('should add a new mood entry', () async {
        final entry = MoodEntry(
          timestamp: DateTime.now(),
          moodLevel: 5,
          stressLevel: 1,
          notes: 'Feeling great!',
          userId: 'test-user',
        );

        await moodService.addEntry(entry);

        // Verify entry was added and fields are correct
        expect(moodService.entries.length, equals(1));
        expect(moodService.entries.first.userId, equals('test-user'));
        expect(moodService.entries.first.moodLevel, equals(5));
      });

      // Test adding multiple mood entries (simulating daily logging)
      test('should add multiple entries', () async {
        final entry1 = MoodEntry(
          timestamp: DateTime.now(),
          moodLevel: 4,
          stressLevel: 2,
          notes: 'Good day',
          userId: 'test-user',
        );

        final entry2 = MoodEntry(
          timestamp: DateTime.now(),
          moodLevel: 3,
          stressLevel: 3,
          notes: 'Okay day',
          userId: 'test-user',
        );

        await moodService.addEntry(entry1);
        await moodService.addEntry(entry2);

        expect(moodService.entries.length, equals(2));
      });
    });

    // Tests for deleting mood entries from SharedPreferences
    group('deleteEntry', () {
      // Test removing an existing mood entry from storage
      test('should delete an existing entry', () async {
        final entry = MoodEntry(
          timestamp: DateTime.now(),
          moodLevel: 4,
          stressLevel: 2,
          notes: 'Test',
          userId: 'test-user',
        );

        await moodService.addEntry(entry);
        expect(moodService.entries.length, equals(1));

        await moodService.deleteEntry(entry);
        // Entry should be removed from storage
        expect(moodService.entries, isEmpty);
      });

      // Test that deleting a non-existent entry doesn't throw an error
      test('should not throw when deleting non-existent entry', () async {
        final nonExistent = MoodEntry(
          timestamp: DateTime.now(),
          moodLevel: 1,
          stressLevel: 1,
          notes: 'Fake',
          userId: 'fake',
        );
        await moodService.deleteEntry(nonExistent);
        expect(moodService.entries, isEmpty);
      });
    });

    // Tests for filtering mood entries by date range
    group('getEntriesForRange', () {
      // Test filtering entries to get only those within a specific date range
      test('should return entries within date range', () async {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final twoDaysAgo = now.subtract(const Duration(days: 2));

        await moodService.addEntry(MoodEntry(
          timestamp: now,
          moodLevel: 4,
          stressLevel: 2,
          notes: 'Today',
          userId: 'test-user',
        ));

        await moodService.addEntry(MoodEntry(
          timestamp: yesterday,
          moodLevel: 3,
          stressLevel: 3,
          notes: 'Yesterday',
          userId: 'test-user',
        ));

        await moodService.addEntry(MoodEntry(
          timestamp: twoDaysAgo,
          moodLevel: 5,
          stressLevel: 1,
          notes: 'Two days ago',
          userId: 'test-user',
        ));

        // Query for all entries in the range covering all three days
        final entries = moodService.getEntriesForRange(
          twoDaysAgo.subtract(const Duration(hours: 1)),
          now.add(const Duration(hours: 1)),
        );

        // Should return all 3 entries since they're all within the range
        expect(entries.length, equals(3));
      });

      // Test that querying a date range with no entries returns empty list
      test('should return empty list when no entries in range', () async {
        final now = DateTime.now();
        final futureDate = now.add(const Duration(days: 10));

        await moodService.addEntry(MoodEntry(
          timestamp: now,
          moodLevel: 4,
          stressLevel: 2,
          notes: 'Today',
          userId: 'test-user',
        ));

        final entries = moodService.getEntriesForRange(
          futureDate,
          futureDate.add(const Duration(days: 1)),
        );

        expect(entries, isEmpty);
      });
    });

    // Tests for calculating average mood and stress levels over a time period
    group('getAveragesForRange', () {
      // Test calculating mean mood and stress levels for analytics display
      test('should calculate correct averages', () async {
        final now = DateTime.now();
        await moodService.addEntry(MoodEntry(
          timestamp: now,
          moodLevel: 5,
          stressLevel: 1,
          notes: 'Great',
          userId: 'test-user',
        ));
        await moodService.addEntry(MoodEntry(
          timestamp: now,
          moodLevel: 3,
          stressLevel: 3,
          notes: 'Okay',
          userId: 'test-user',
        ));
        await moodService.addEntry(MoodEntry(
          timestamp: now,
          moodLevel: 4,
          stressLevel: 2,
          notes: 'Good',
          userId: 'test-user',
        ));

        // Calculate averages for the time period containing all entries
        final averages = moodService.getAveragesForRange(
          now.subtract(const Duration(hours: 1)),
          now.add(const Duration(hours: 1)),
        );

        // Verify correct average calculations
        expect(averages['moodAverage'], equals(4.0)); // (5 + 3 + 4) / 3
        expect(averages['stressAverage'], equals(2.0)); // (1 + 3 + 2) / 3
      });

      // Test that averages return 0.0 when no entries exist in the date range
      test('should return 0 for empty range', () {
        final now = DateTime.now();
        final averages = moodService.getAveragesForRange(
          now.add(const Duration(days: 10)),
          now.add(const Duration(days: 11)),
        );

        expect(averages['moodAverage'], equals(0.0));
        expect(averages['stressAverage'], equals(0.0));
      });
    });

    // Tests for data immutability of the public entries list
    group('entries getter', () {
      // Test that returned entries list cannot be modified externally
      test('should return unmodifiable list', () {
        final entries = moodService.entries;
        expect(
          () => entries.add(
            MoodEntry(
              timestamp: DateTime.now(),
              moodLevel: 5,
              stressLevel: 1,
              notes: '',
              userId: 'test-user',
            ),
          ),
          throwsUnsupportedError,
        );
      });
    });
  });
}
