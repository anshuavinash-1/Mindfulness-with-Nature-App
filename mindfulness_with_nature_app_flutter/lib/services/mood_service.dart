import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';

class MoodService with ChangeNotifier {
  static const String _storageKey = 'mood_entries';
  final SharedPreferences _prefs;
  List<MoodEntry> _entries = [];

  MoodService(this._prefs) {
    _loadEntries();
  }

  List<MoodEntry> get entries => List.unmodifiable(_entries);

  // Load entries from storage
  Future<void> _loadEntries() async {
    try {
      debugPrint('MoodService: Loading entries from storage');
      final String? entriesJson = _prefs.getString(_storageKey);
      if (entriesJson != null) {
        debugPrint('MoodService: Found stored entries: $entriesJson');
        final List<dynamic> decoded = jsonDecode(entriesJson);
        _entries = decoded.map((item) => MoodEntry.fromJson(item)).toList();
        debugPrint('MoodService: Loaded ${_entries.length} entries');
      } else {
        debugPrint('MoodService: No stored entries found');
        _entries = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('MoodService: Error loading entries - $e');
      _entries = [];
      notifyListeners();
    }
  }

  // Save entries to storage
  Future<void> _saveEntries() async {
    try {
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
    _entries.add(entry);
    await _saveEntries();
    notifyListeners();
  }

  // Get entries for a date range
  List<MoodEntry> getEntriesForRange(DateTime start, DateTime end) {
    return _entries
        .where((entry) =>
            entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end))
        .toList();
  }

  // Get average mood and stress levels for a date range
  Map<String, double> getAveragesForRange(DateTime start, DateTime end) {
    final entriesInRange = getEntriesForRange(start, end);
    if (entriesInRange.isEmpty) {
      return {
        'moodAverage': 0.0,
        'stressAverage': 0.0,
      };
    }

    final moodSum =
        entriesInRange.fold<int>(0, (sum, entry) => sum + entry.moodLevel);
    final stressSum =
        entriesInRange.fold<int>(0, (sum, entry) => sum + entry.stressLevel);

    return {
      'moodAverage': moodSum / entriesInRange.length,
      'stressAverage': stressSum / entriesInRange.length,
    };
  }

  // Delete an entry
  Future<void> deleteEntry(MoodEntry entry) async {
    _entries.removeWhere(
        (e) => e.timestamp == entry.timestamp && e.userId == entry.userId);
    await _saveEntries();
    notifyListeners();
  }
}
