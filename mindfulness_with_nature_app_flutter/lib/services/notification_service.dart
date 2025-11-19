import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _reminderTimeKey = 'mood_reminder_time';
  static const String _reminderEnabledKey = 'mood_reminder_enabled';
  static const int _notificationId = 0;
  static const String _channelId = 'mood_reminders';
  static const String _channelName = 'Mindfulness Reminders';
  static const String _channelDescription = 'Daily reminders for mood tracking and mindfulness practice';

  bool _isReminderEnabled = false;
  TimeOfDay? _reminderTime;
  bool _isInitialized = false;
  String? _error;

  bool get isReminderEnabled => _isReminderEnabled;
  TimeOfDay? get reminderTime => _reminderTime;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  NotificationService() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _initializeNotifications();
      await _loadSettings();
      _isInitialized = true;
      _error = null;
      notifyListeners();
      
      developer.log('Notification service initialized successfully');
    } catch (e) {
      _error = 'Failed to initialize notification service: ${e.toString()}';
      _isInitialized = false;
      notifyListeners();
      developer.log('Notification service initialization failed: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      // Initialize timezones
      tz.initializeTimeZones();

      // Android notification channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        showBadge: true,
        playSound: true,
      );

      // Create notification channel for Android 8.0+
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(channel);

      // iOS notification settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
      );

      developer.log('Local notifications initialized successfully');
    } catch (e) {
      developer.log('Failed to initialize local notifications: $e');
      rethrow;
    }
  }

  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    developer.log('Received local notification: $title - $body');
  }

  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    developer.log('Notification tapped: ${response.id} - ${response.payload}');
    // Handle notification tap - could navigate to mood tracking page
  }

  static void _onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
    developer.log('Background notification tapped: ${response.id}');
    // Handle background notification tap
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isReminderEnabled = prefs.getBool(_reminderEnabledKey) ?? false;

      final savedHour = prefs.getInt('${_reminderTimeKey}_hour');
      final savedMinute = prefs.getInt('${_reminderTimeKey}_minute');

      if (savedHour != null && savedMinute != null) {
        _reminderTime = TimeOfDay(hour: savedHour, minute: savedMinute);
      } else {
        // Default reminder time: 8:00 PM
        _reminderTime = const TimeOfDay(hour: 20, minute: 0);
      }

      developer.log('Loaded notification settings: enabled=$_isReminderEnabled, time=$_reminderTime');
    } catch (e) {
      _error = 'Failed to load notification settings: ${e.toString()}';
      developer.log('Error loading notification settings: $e');
    }
  }

  Future<bool> saveSettings({
    required bool isEnabled,
    TimeOfDay? time,
  }) async {
    if (!_isInitialized) {
      _error = 'Notification service not initialized';
      notifyListeners();
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save settings to persistent storage
      await prefs.setBool(_reminderEnabledKey, isEnabled);

      final timeToSave = time ?? _reminderTime ?? const TimeOfDay(hour: 20, minute: 0);
      await prefs.setInt('${_reminderTimeKey}_hour', timeToSave.hour);
      await prefs.setInt('${_reminderTimeKey}_minute', timeToSave.minute);

      // Update local state
      _isReminderEnabled = isEnabled;
      _reminderTime = timeToSave;
      _error = null;

      // Schedule or cancel notifications based on new settings
      if (isEnabled) {
        final success = await _scheduleDailyNotification(timeToSave);
        if (!success) {
          _error = 'Failed to schedule notification';
          await prefs.setBool(_reminderEnabledKey, false);
          _isReminderEnabled = false;
        }
      } else {
        await _cancelNotifications();
      }

      notifyListeners();
      
      developer.log('Notification settings saved: enabled=$isEnabled, time=$timeToSave');
      return true;
    } catch (e) {
      _error = 'Failed to save notification settings: ${e.toString()}';
      notifyListeners();
      developer.log('Error saving notification settings: $e');
      return false;
    }
  }

  Future<bool> _scheduleDailyNotification(TimeOfDay time) async {
    try {
      await _cancelNotifications(); // Clear any existing notifications

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
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

      // Notification details
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          enableLights: true,
          playSound: true,
          timeoutAfter: 3600000, // 1 hour timeout
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: 1,
          subtitle: 'Daily mindfulness check-in',
        ),
      );

      // Schedule the notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        _notificationId,
        '🌿 Time for Mindfulness',
        'Take a moment to check in with your mood and find peace in nature.',
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      developer.log('Daily notification scheduled for $scheduledDate');
      return true;
    } catch (e) {
      developer.log('Failed to schedule notification: $e');
      return false;
    }
  }

  Future<void> _cancelNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancel(_notificationId);
      developer.log('Notifications cancelled');
    } catch (e) {
      developer.log('Error cancelling notifications: $e');
    }
  }

  Future<bool> requestNotificationPermissions() async {
    if (!_isInitialized) {
      _error = 'Notification service not initialized';
      notifyListeners();
      return false;
    }

    try {
      bool permissionsGranted = false;

      // Check Android permissions
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final bool? androidGranted = await androidPlugin.areNotificationsEnabled();
        if (androidGranted == true) {
          permissionsGranted = true;
        } else {
          // On Android, we can't request permissions programmatically
          // User must enable in system settings
          _error = 'Please enable notifications in your device settings';
          notifyListeners();
          return false;
        }
      }

      // Check iOS permissions
      final IOSFlutterLocalNotificationsPlugin? iOSPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iOSPlugin != null) {
        final bool? iOSGranted = await iOSPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        permissionsGranted = iOSGranted ?? false;
      }

      developer.log('Notification permissions requested: $permissionsGranted');
      return permissionsGranted;
    } catch (e) {
      _error = 'Failed to request notification permissions: ${e.toString()}';
      notifyListeners();
      developer.log('Error requesting notification permissions: $e');
      return false;
    }
  }

  Future<bool> checkNotificationPermissions() async {
    try {
      bool hasPermissions = false;

      // Check Android
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? androidEnabled = await androidPlugin?.areNotificationsEnabled();

      // Check iOS by attempting to schedule a test notification
      final IOSFlutterLocalNotificationsPlugin? iOSPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      
      // For iOS, we'll check if we can get pending notifications
      final List<PendingNotificationRequest> pendingNotifications =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      
      final bool iOSEnabled = pendingNotifications.isNotEmpty || iOSPlugin != null;

      hasPermissions = (androidEnabled ?? false) || iOSEnabled;

      developer.log('Notification permissions check: $hasPermissions');
      return hasPermissions;
    } catch (e) {
      developer.log('Error checking notification permissions: $e');
      return false;
    }
  }

  // Test notification for debugging
  Future<bool> showTestNotification() async {
    try {
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await flutterLocalNotificationsPlugin.show(
        _notificationId + 1, // Different ID to avoid conflict
        'Test Notification',
        'This is a test notification from Mindfulness App',
        notificationDetails,
      );

      developer.log('Test notification shown successfully');
      return true;
    } catch (e) {
      developer.log('Failed to show test notification: $e');
      return false;
    }
  }

  // Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      developer.log('Error getting pending notifications: $e');
      return [];
    }
  }

  // Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reinitialize the service
  Future<void> reinitialize() async {
    _isInitialized = false;
    _error = null;
    notifyListeners();
    await _initialize();
  }
}