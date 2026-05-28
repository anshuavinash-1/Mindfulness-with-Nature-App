import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// Available nature sounds for the daily reminder notification.
enum ReminderSound {
  forestRain,
  morningBirds,
  gentleStream,
  silent;

  String get label {
    switch (this) {
      case ReminderSound.forestRain:
        return 'Forest Rain';
      case ReminderSound.morningBirds:
        return 'Morning Birds';
      case ReminderSound.gentleStream:
        return 'Gentle Stream';
      case ReminderSound.silent:
        return 'Silent';
    }
  }

  String? get assetName {
    switch (this) {
      case ReminderSound.forestRain:
        return 'forest_rain';
      case ReminderSound.morningBirds:
        return 'morning_birds';
      case ReminderSound.gentleStream:
        return 'gentle_stream';
      case ReminderSound.silent:
        return null;
    }
  }

  String get icon {
    switch (this) {
      case ReminderSound.forestRain:
        return '🌧';
      case ReminderSound.morningBirds:
        return '🐦';
      case ReminderSound.gentleStream:
        return '💧';
      case ReminderSound.silent:
        return '🔕';
    }
  }
}

class NotificationService extends ChangeNotifier {
  static const _keyEnabled = 'reminder_enabled';
  static const _keyHour = 'reminder_hour';
  static const _keyMinute = 'reminder_minute';
  static const _keySound = 'reminder_sound';
  static const _keyMessage = 'reminder_message';

  static const String _defaultMessage = "Time for your mindfulness practice 🌿";
  static const int _notificationId = 1001;

  bool _isReminderEnabled = false;
  TimeOfDay? _reminderTime;
  ReminderSound _reminderSound =
      ReminderSound.silent; // default silent until sound files added
  String _reminderMessage = _defaultMessage;
  bool _isNotificationSupported = true;
  String? _supportMessage;

  bool get isReminderEnabled => _isReminderEnabled;
  TimeOfDay? get reminderTime => _reminderTime;
  ReminderSound get reminderSound => _reminderSound;
  String get reminderMessage => _reminderMessage;
  bool get isNotificationSupported => _isNotificationSupported;
  String? get supportMessage => _supportMessage;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── Init — NO timezone init here, main.dart handles it ───────────────────────
  Future<void> init() async {
    if (kIsWeb) {
      _isNotificationSupported = false;
      _supportMessage = 'Daily local reminders are not supported on web yet.';
      await _loadPrefs();
      return;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    try {
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: iOS),
      );
      _isNotificationSupported = true;
      _supportMessage = null;
    } on MissingPluginException {
      _isNotificationSupported = false;
      _supportMessage =
          'Notifications are not available on this platform build.';
    } on PlatformException catch (e) {
      _isNotificationSupported = false;
      _supportMessage = 'Notifications unavailable (${e.code}).';
    }

    await _loadPrefs();
  }

  // ── Persistence ───────────────────────────────────────────────────────────────
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isReminderEnabled = prefs.getBool(_keyEnabled) ?? false;

    final hour = prefs.getInt(_keyHour);
    final minute = prefs.getInt(_keyMinute);
    if (hour != null && minute != null) {
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    }

    final soundIndex = prefs.getInt(_keySound) ?? 3; // default silent (index 3)
    _reminderSound = ReminderSound.values[soundIndex.clamp(
      0,
      ReminderSound.values.length - 1,
    )];

    _reminderMessage = prefs.getString(_keyMessage) ?? _defaultMessage;

    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, _isReminderEnabled);
    if (_reminderTime != null) {
      await prefs.setInt(_keyHour, _reminderTime!.hour);
      await prefs.setInt(_keyMinute, _reminderTime!.minute);
    }
    await prefs.setInt(_keySound, _reminderSound.index);
    await prefs.setString(_keyMessage, _reminderMessage);
  }

  // ── Public API ────────────────────────────────────────────────────────────────
  Future<void> setReminderEnabled(bool value) async {
    if (value && !_isNotificationSupported) {
      _isReminderEnabled = false;
      await _savePrefs();
      notifyListeners();
      return;
    }

    _isReminderEnabled = value;
    await _savePrefs();
    if (value && _reminderTime != null) {
      await _scheduleDaily();
    } else {
      await _cancelAll();
    }
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    await _savePrefs();
    if (_isReminderEnabled) await _scheduleDaily();
    notifyListeners();
  }

  Future<void> setReminderSound(ReminderSound sound) async {
    _reminderSound = sound;
    await _savePrefs();
    if (_isReminderEnabled && _reminderTime != null) await _scheduleDaily();
    notifyListeners();
  }

  Future<void> setReminderMessage(String message) async {
    _reminderMessage =
        message.trim().isEmpty ? _defaultMessage : message.trim();
    await _savePrefs();
    if (_isReminderEnabled && _reminderTime != null) await _scheduleDaily();
    notifyListeners();
  }

  // ── Scheduling ────────────────────────────────────────────────────────────────
  Future<void> _scheduleDaily() async {
    if (!_isNotificationSupported) {
      return;
    }

    await _cancelAll();
    if (_reminderTime == null) return;

    // tz.local is correctly set by main.dart using flutter_timezone
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _reminderTime!.hour,
      _reminderTime!.minute,
      0, // seconds
    );

    // If time already passed today (or within 5 seconds), push to tomorrow
    if (scheduled.isBefore(now) || scheduled.difference(now).inSeconds < 5) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    debugPrint('⏰ Now:           $now');
    debugPrint('⏰ Scheduled for: $scheduled');
    debugPrint('⏰ In minutes:    ${scheduled.difference(now).inMinutes}');

    final androidDetails = AndroidNotificationDetails(
      'mindfulness_reminder',
      'Daily Mindfulness Reminder',
      channelDescription: 'Your daily meditation reminder',
      importance: Importance.max,
      priority: Priority.max,
      sound: _reminderSound.assetName != null
          ? RawResourceAndroidNotificationSound(_reminderSound.assetName!)
          : null,
      playSound: _reminderSound != ReminderSound.silent,
    );

    final iosDetails = DarwinNotificationDetails(
      sound: _reminderSound.assetName != null
          ? '${_reminderSound.assetName!}.caf'
          : null,
      presentSound: _reminderSound != ReminderSound.silent,
    );

    try {
      await _plugin.zonedSchedule(
        _notificationId,
        'Mindfulness with Nature',
        _reminderMessage,
        scheduled,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException catch (e) {
      debugPrint(
        '⚠️ Exact alarm scheduling failed (${e.code}). Falling back to inexact schedule.',
      );
      await _plugin.zonedSchedule(
        _notificationId,
        'Mindfulness with Nature',
        _reminderMessage,
        scheduled,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    try {
      // Debug: confirm it was registered
      final pending = await _plugin.pendingNotificationRequests();
      debugPrint('✅ Pending notifications: ${pending.length}');
      for (final p in pending) {
        debugPrint('   → id:${p.id} | title:${p.title} | body:${p.body}');
      }
    } on MissingPluginException {
      debugPrint(
          '⚠️ pendingNotificationRequests unavailable on this platform.');
    }
  }

  Future<void> _cancelAll() async {
    if (!_isNotificationSupported) {
      return;
    }

    try {
      await _plugin.cancel(_notificationId);
      debugPrint('🔕 Notification cancelled');
    } on MissingPluginException {
      debugPrint('⚠️ cancel unavailable on this platform.');
    }
  }

  Future<bool> requestPermissions() async {
    if (!_isNotificationSupported) {
      return false;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iOS = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final androidNotificationGranted =
        await android?.requestNotificationsPermission() ?? true;
    final androidExactAlarmGranted =
        await android?.requestExactAlarmsPermission() ?? true;
    final iosGranted = await iOS?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return androidNotificationGranted && androidExactAlarmGranted && iosGranted;
  }
}
