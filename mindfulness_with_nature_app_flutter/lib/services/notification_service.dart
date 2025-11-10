import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _reminderTimeKey = 'mood_reminder_time';
  static const String _reminderEnabledKey = 'mood_reminder_enabled';

  bool _isReminderEnabled = false;
  TimeOfDay? _reminderTime;

  bool get isReminderEnabled => _isReminderEnabled;
  TimeOfDay? get reminderTime => _reminderTime;

  NotificationService() {
    _initializeNotifications();
    _loadSettings();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isReminderEnabled = prefs.getBool(_reminderEnabledKey) ?? false;

    final savedHour = prefs.getInt('${_reminderTimeKey}_hour');
    final savedMinute = prefs.getInt('${_reminderTimeKey}_minute');

    if (savedHour != null && savedMinute != null) {
      _reminderTime = TimeOfDay(hour: savedHour, minute: savedMinute);
    }

    notifyListeners();
  }

  Future<void> saveSettings({
    required bool isEnabled,
    TimeOfDay? time,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, isEnabled);

    if (time != null) {
      await prefs.setInt('${_reminderTimeKey}_hour', time.hour);
      await prefs.setInt('${_reminderTimeKey}_minute', time.minute);
    }

    _isReminderEnabled = isEnabled;
    _reminderTime = time;

    if (isEnabled && time != null) {
      await _scheduleDailyNotification(time);
    } else {
      await cancelNotifications();
    }

    notifyListeners();
  }

  Future<void> _scheduleDailyNotification(TimeOfDay time) async {
    await cancelNotifications(); // Cancel existing notifications

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Time for Mindfulness',
      'Take a moment to check in with your mood and find peace in nature.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mood_reminders',
          'Mood Reminders',
          channelDescription: 'Daily reminders to track your mood',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<bool> requestNotificationPermissions() async {
    if (await _checkNotificationPermissions()) {
      return true;
    }

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? androidGranted = await androidPlugin?.areNotificationsEnabled();

    final IOSFlutterLocalNotificationsPlugin? iOSPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    final bool? iOSGranted = await iOSPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return (androidGranted ?? false) || (iOSGranted ?? false);
  }

  Future<bool> _checkNotificationPermissions() async {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final iOSPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    // Check Android permissions
    final bool? androidEnabled = await androidPlugin?.areNotificationsEnabled();

    // Check iOS permissions
    final bool? iOSEnabled =
        await iOSPlugin?.pendingNotificationRequests().then(
              (requests) => requests.isNotEmpty,
            );

    return (androidEnabled ?? false) || (iOSEnabled ?? false);
  }
}
