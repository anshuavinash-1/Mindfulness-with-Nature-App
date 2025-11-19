class MoodEntry {
  final DateTime timestamp;
  final int moodLevel; // 1-5 scale
  final int stressLevel; // 1-5 scale
  final String? notes;
  final String userId;

  MoodEntry({
    required this.timestamp,
    required this.moodLevel,
    required this.stressLevel,
    this.notes,
    required this.userId,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'moodLevel': moodLevel,
      'stressLevel': stressLevel,
      'notes': notes,
      'userId': userId,
    };
  }

  // Create from JSON for retrieval
  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      timestamp: DateTime.parse(json['timestamp']),
      moodLevel: json['moodLevel'],
      stressLevel: json['stressLevel'],
      notes: json['notes'],
      userId: json['userId'],
    );
  }
}