import 'package:uuid/uuid.dart';

class MoodEntry {
  final String id;
  final DateTime timestamp;
  final int moodLevel;
  final int stressLevel;
  final String? notes;
  final String userId;

  MoodEntry({
    String? id,
    required this.timestamp,
    required this.moodLevel,
    required this.stressLevel,
    this.notes,
    required this.userId,
  }) : id = id ?? const Uuid().v4();

  // Add toJson and fromJson methods if not present
  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'moodLevel': moodLevel,
        'stressLevel': stressLevel,
        'notes': notes,
        'userId': userId,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        moodLevel: json['moodLevel'],
        stressLevel: json['stressLevel'],
        notes: json['notes'],
        userId: json['userId'],
      );
}