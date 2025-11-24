import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';

// The MoodService manages the persistent storage and retrieval of
// mood and stress entries, as well as providing analytical calculations.
class MoodService with ChangeNotifier {
  static const String _storageKey = 'mood_entries';
  final SharedPreferences _prefs;
  List<MoodEntry> _entries = [];

  // Constructor loads existing data immediately upon instantiation.
  MoodService(this._prefs) {
    _loadEntries();
  }

  // Getter for the mood entries, returns an unmodifiable list for safety.
  List<MoodEntry> get entries => List.unmodifiable(_entries);

  // Load entries from storage
  Future<void> _loadEntries() async {
    try {
      debugPrint('MoodService: Loading entries from storage');
      final String? entriesJson = _prefs.getString(_storageKey);
      if (entriesJson != null) {
        debugPrint('MoodService: Found stored entries.');
        final List<dynamic> decoded = jsonDecode(entriesJson);
        // Map decoded JSON back to MoodEntry objects
        _entries = decoded.map((item) => MoodEntry.fromJson(item)).toList();
        debugPrint('MoodService: Loaded ${_entries.length} entries');
      } else {
        debugPrint('MoodService: No stored entries found');
        _entries = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('MoodService: Error loading entries - $e');
      _entries = []; // Clear list on error to prevent bad state
      notifyListeners();
    }
  }

  // Save entries to storage
  Future<void> _saveEntries() async {
    try {
      // Encode the list of entries to a JSON string
      final String encoded =
          jsonEncode(_entries.map((e) => e.toJson()).toList());
      final success = await _prefs.setString(_storageKey, encoded);
      debugPrint('MoodService: Saving entries - Success: $success');
      debugPrint('MoodService: Number of entries: ${_entries.length}');
    } catch (e) {
      debugPrint('MoodService: Error saving entries - $e');
    }
  }

  // Add a new mood entry
  Future<void> addEntry(MoodEntry entry) async {
    // Add the new entry to the list
    _entries.add(entry);
    // Persist the updated list
    await _saveEntries();
    // Notify listeners (UI widgets) that data has changed
    notifyListeners();
  }

  // Get entries for a specific date range (exclusive of the end date)
  List<MoodEntry> getEntriesForRange(DateTime start, DateTime end) {
    return _entries
        .where((entry) =>
            entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end))
        .toList();
  }

  // Calculate average mood and stress levels for a date range
  Map<String, double> getAveragesForRange(DateTime start, DateTime end) {
    final entriesInRange = getEntriesForRange(start, end);
    if (entriesInRange.isEmpty) {
      return {
        'moodAverage': 0.0,
        'stressAverage': 0.0,
      };
    }

    // Calculate sum of mood and stress levels using fold
    final moodSum =
        entriesInRange.fold<int>(0, (sum, entry) => sum + entry.moodLevel);
    final stressSum =
        entriesInRange.fold<int>(0, (sum, entry) => sum + entry.stressLevel);

    // Return averages
    return {
      'moodAverage': moodSum / entriesInRange.length,
      'stressAverage': stressSum / entriesInRange.length,
    };
  }

  // Delete an entry (currently based on exact timestamp and userId match)
  Future<void> deleteEntry(MoodEntry entry) async {
    _entries.removeWhere(
        (e) => e.timestamp == entry.timestamp && e.userId == entry.userId);
    await _saveEntries();
    notifyListeners();
  }
}
