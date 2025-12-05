import 'package:flutter/material.dart';

/// Simple in-app NotificationService used by the settings UI.
///
/// This is a lightweight placeholder implementation that stores settings
/// in memory. It's intentionally simple so analyzer and UI pages can
/// reference `NotificationService`. For production you'd replace this with
/// platform-specific notification permission checks and persistent storage.
class NotificationService with ChangeNotifier {
  bool _isReminderEnabled = false;
  TimeOfDay? _reminderTime;

  bool get isReminderEnabled => _isReminderEnabled;
  TimeOfDay? get reminderTime => _reminderTime;

  /// Request notification permissions from the platform.
  /// For now return true to simulate permission granted.
  Future<bool> requestNotificationPermissions() async {
    // TODO: Integrate with flutter_local_notifications / permission_handler
    return true;
  }

  /// Save settings (in-memory for this placeholder).
  Future<void> saveSettings({required bool isEnabled, TimeOfDay? time}) async {
    _isReminderEnabled = isEnabled;
    _reminderTime = time;
    notifyListeners();
  }
}
