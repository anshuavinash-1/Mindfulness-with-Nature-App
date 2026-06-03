import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodStressEntry {
  final DateTime timestamp;
  final int mood;
  final int stress;

  const MoodStressEntry({
    required this.timestamp,
    required this.mood,
    required this.stress,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'mood': mood,
        'stress': stress,
      };

  factory MoodStressEntry.fromJson(Map<String, dynamic> json) {
    return MoodStressEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      mood: (json['mood'] as num).toInt().clamp(1, 10),
      stress: (json['stress'] as num).toInt().clamp(1, 10),
    );
  }
}

class MoodStressTrackerService {
  static const String _storageKey = 'mood_stress_entries_v1';

  // Web entries are intentionally session-only (non-persistent).
  static final List<MoodStressEntry> _webSessionEntries = [];

  Future<List<MoodStressEntry>> loadEntries() async {
    if (kIsWeb) {
      return List<MoodStressEntry>.from(_webSessionEntries)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final entries = decoded
        .map((item) => MoodStressEntry.fromJson(item as Map<String, dynamic>))
        .toList();

    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return entries;
  }

  Future<void> addEntry({
    required int mood,
    required int stress,
    DateTime? now,
  }) async {
    final entry = MoodStressEntry(
      timestamp: now ?? DateTime.now(),
      mood: mood.clamp(1, 10),
      stress: stress.clamp(1, 10),
    );

    if (kIsWeb) {
      _webSessionEntries.add(entry);
      return;
    }

    final entries = await loadEntries();
    entries.add(entry);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<bool> canAddToday({DateTime? now}) async {
    if (kIsWeb) {
      return true;
    }

    final platform = defaultTargetPlatform;
    final enforceDailyLimit =
        platform == TargetPlatform.android || platform == TargetPlatform.iOS;

    if (!enforceDailyLimit) {
      return true;
    }

    final today = now ?? DateTime.now();
    final entries = await loadEntries();
    return !entries.any((entry) => _isSameDay(entry.timestamp, today));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
