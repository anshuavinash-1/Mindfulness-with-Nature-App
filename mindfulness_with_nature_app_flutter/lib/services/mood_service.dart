import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';

class MoodService with ChangeNotifier {
  static const String _storageKey = 'mood_entries';
  final SharedPreferences _prefs;
  List<MoodEntry> _entries = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  MoodService(this._prefs) {
    _initialize();
  }

  List<MoodEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  int get entriesCount => _entries.length;

  // Get today's entries
  List<MoodEntry> get todayEntries {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    return getEntriesForRange(todayStart, todayEnd);
  }

  // Get this week's entries
  List<MoodEntry> get thisWeekEntries {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return getEntriesForRange(weekStart, weekEnd);
  }

  Future<void> _initialize() async {
    await _loadEntries();
    _isInitialized = true;
    notifyListeners();
  }

  // Load entries from storage with enhanced error handling
  Future<void> _loadEntries() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('MoodService: Loading entries from storage');
      }

      final String? entriesJson = _prefs.getString(_storageKey);
      
      if (entriesJson != null && entriesJson.isNotEmpty) {
        if (kDebugMode) {
          print('MoodService: Found stored entries');
        }

        final List<dynamic> decoded = jsonDecode(entriesJson);
        _entries = decoded.map((item) => MoodEntry.fromJson(item)).toList();
        
        // Sort entries by timestamp (newest first)
        _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        if (kDebugMode) {
          print('MoodService: Loaded ${_entries.length} entries');
        }
      } else {
        if (kDebugMode) {
          print('MoodService: No stored entries found');
        }
        _entries = [];
      }
    } catch (e) {
      _error = 'Failed to load mood entries: ${e.toString()}';
      _entries = [];
      if (kDebugMode) {
        print('MoodService: Error loading entries - $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save entries to storage with error handling
  Future<bool> _saveEntries() async {
    try {
      final String encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
      final success = await _prefs.setString(_storageKey, encoded);
      
      if (kDebugMode) {
        print('MoodService: Saving ${_entries.length} entries - Success: $success');
      }
      
      return success;
    } catch (e) {
      _error = 'Failed to save mood entries: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('MoodService: Error saving entries - $e');
      }
      return false;
    }
  }

  // Add a new mood entry with validation
  Future<bool> addEntry(MoodEntry entry) async {
    // Validate entry data
    if (entry.moodLevel < 1 || entry.moodLevel > 5) {
      _error = 'Mood level must be between 1 and 5';
      notifyListeners();
      return false;
    }

    if (entry.stressLevel < 1 || entry.stressLevel > 5) {
      _error = 'Stress level must be between 1 and 5';
      notifyListeners();
      return false;
    }

    // Check for duplicate entries (same user and timestamp within 5 minutes)
    final duplicate = _entries.firstWhere(
      (e) => 
        e.userId == entry.userId &&
        e.timestamp.difference(entry.timestamp).abs() < const Duration(minutes: 5),
      orElse: () => MoodEntry(
        timestamp: DateTime.now(),
        moodLevel: 0,
        stressLevel: 0,
        userId: '',
      ),
    );

    if (duplicate.userId.isNotEmpty) {
      _error = 'You already have an entry for this time';
      notifyListeners();
      return false;
    }

    _entries.add(entry);
    
    // Sort entries by timestamp (newest first)
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    final success = await _saveEntries();
    
    if (success) {
      _error = null;
      notifyListeners();
      if (kDebugMode) {
        print('MoodService: Added new mood entry for user ${entry.userId}');
      }
      return true;
    } else {
      // Rollback on failure
      _entries.remove(entry);
      return false;
    }
  }

  // Update an existing entry
  Future<bool> updateEntry(MoodEntry updatedEntry) async {
    final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
    
    if (index == -1) {
      _error = 'Mood entry not found';
      notifyListeners();
      return false;
    }

    // Validate updated data
    if (updatedEntry.moodLevel < 1 || updatedEntry.moodLevel > 5 ||
        updatedEntry.stressLevel < 1 || updatedEntry.stressLevel > 5) {
      _error = 'Mood and stress levels must be between 1 and 5';
      notifyListeners();
      return false;
    }

    final originalEntry = _entries[index];
    _entries[index] = updatedEntry;
    
    final success = await _saveEntries();
    
    if (!success) {
      // Rollback on failure
      _entries[index] = originalEntry;
      return false;
    }

    _error = null;
    notifyListeners();
    return true;
  }

  // Delete an entry
  Future<bool> deleteEntry(String entryId) async {
    final entry = _entries.firstWhere(
      (e) => e.id == entryId,
      orElse: () => MoodEntry(
        timestamp: DateTime.now(),
        moodLevel: 0,
        stressLevel: 0,
        userId: '',
      ),
    );

    if (entry.id.isEmpty) {
      _error = 'Mood entry not found';
      notifyListeners();
      return false;
    }

    _entries.removeWhere((e) => e.id == entryId);
    final success = await _saveEntries();
    
    if (!success) {
      // Rollback on failure
      _entries.add(entry);
      return false;
    }

    _error = null;
    notifyListeners();
    return true;
  }

  // Delete entries by user
  Future<bool> deleteEntriesByUser(String userId) async {
    final userEntries = _entries.where((e) => e.userId == userId).toList();
    _entries.removeWhere((e) => e.userId == userId);
    
    final success = await _saveEntries();
    
    if (!success) {
      // Rollback on failure
      _entries.addAll(userEntries);
      _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return false;
    }

    _error = null;
    notifyListeners();
    return true;
  }

  // Get entries for a date range
  List<MoodEntry> getEntriesForRange(DateTime start, DateTime end) {
    return _entries.where((entry) =>
      entry.timestamp.isAfter(start.subtract(const Duration(seconds: 1))) &&
      entry.timestamp.isBefore(end)
    ).toList();
  }

  // Get entries for a specific day
  List<MoodEntry> getEntriesForDay(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return getEntriesForRange(dayStart, dayEnd);
  }

  // Get average mood and stress levels for a date range
  Map<String, double> getAveragesForRange(DateTime start, DateTime end) {
    final entriesInRange = getEntriesForRange(start, end);
    
    if (entriesInRange.isEmpty) {
      return {
        'moodAverage': 0.0,
        'stressAverage': 0.0,
        'entryCount': 0.0,
      };
    }

    final moodSum = entriesInRange.fold<int>(0, (sum, entry) => sum + entry.moodLevel);
    final stressSum = entriesInRange.fold<int>(0, (sum, entry) => sum + entry.stressLevel);

    return {
      'moodAverage': moodSum / entriesInRange.length,
      'stressAverage': stressSum / entriesInRange.length,
      'entryCount': entriesInRange.length.toDouble(),
    };
  }

  // Get mood trends (last 7 days)
  Map<String, double> getWeeklyTrends() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return getAveragesForRange(weekAgo, now);
  }

  // Get entries by user
  List<MoodEntry> getEntriesByUser(String userId) {
    return _entries.where((entry) => entry.userId == userId).toList();
  }

  // Get latest entry for a user
  MoodEntry? getLatestEntryForUser(String userId) {
    try {
      return _entries.firstWhere((entry) => entry.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Check if user has entry for today
  bool hasEntryForToday(String userId) {
    return todayEntries.any((entry) => entry.userId == userId);
  }

  // Get mood statistics
  Map<String, dynamic> getMoodStatistics(String userId) {
    final userEntries = getEntriesByUser(userId);
    
    if (userEntries.isEmpty) {
      return {
        'totalEntries': 0,
        'averageMood': 0.0,
        'averageStress': 0.0,
        'moodTrend': 'stable',
        'mostCommonMood': 3,
      };
    }

    final moodSum = userEntries.fold<int>(0, (sum, entry) => sum + entry.moodLevel);
    final stressSum = userEntries.fold<int>(0, (sum, entry) => sum + entry.stressLevel);
    
    // Calculate mood frequency
    final moodFrequency = <int, int>{};
    for (var entry in userEntries) {
      moodFrequency[entry.moodLevel] = (moodFrequency[entry.moodLevel] ?? 0) + 1;
    }
    
    final mostCommonMood = moodFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'totalEntries': userEntries.length,
      'averageMood': moodSum / userEntries.length,
      'averageStress': stressSum / userEntries.length,
      'mostCommonMood': mostCommonMood,
      'moodTrend': _calculateTrend(userEntries),
    };
  }

  String _calculateTrend(List<MoodEntry> entries) {
    if (entries.length < 2) return 'stable';
    
    final recentEntries = entries.take(5).toList();
    final olderEntries = entries.skip(5).take(5).toList();
    
    if (olderEntries.isEmpty) return 'stable';
    
    final recentAvg = recentEntries.fold<int>(0, (sum, e) => sum + e.moodLevel) / recentEntries.length;
    final olderAvg = olderEntries.fold<int>(0, (sum, e) => sum + e.moodLevel) / olderEntries.length;
    
    if (recentAvg > olderAvg + 0.5) return 'improving';
    if (recentAvg < olderAvg - 0.5) return 'declining';
    return 'stable';
  }

  // Clear all entries (for testing or account reset)
  Future<bool> clearAllEntries() async {
    final previousEntries = List<MoodEntry>.from(_entries);
    _entries.clear();
    
    final success = await _saveEntries();
    if (!success) {
      _entries = previousEntries;
      return false;
    }
    
    _error = null;
    notifyListeners();
    return true;
  }

  // Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh data from storage
  Future<void> refresh() async {
    await _loadEntries();
  }
}