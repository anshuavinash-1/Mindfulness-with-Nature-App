import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isLoading = false;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFDC2626), // Error red
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF87A96B), // Sage Green
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _toggleReminders(bool value) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final notificationService = Provider.of<NotificationService>(context, listen: false);

    try {
      if (value) {
        // Enable reminders
        final hasPermission = await notificationService.requestNotificationPermissions();
        
        if (!mounted) return;

        if (!hasPermission) {
          _showErrorSnackBar('Please enable notifications in your device settings');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Show time picker for new time selection
        final TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: notificationService.reminderTime ?? const TimeOfDay(hour: 20, minute: 0),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF87A96B), // Sage Green
                  onPrimary: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );

        if (!mounted) return;

        if (selectedTime != null) {
          await notificationService.saveSettings(
            isEnabled: true,
            time: selectedTime,
          );
          _showSuccessSnackBar('Daily reminders enabled for ${selectedTime.format(context)}');
        } else {
          // User canceled time selection, don't enable reminders
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else {
        // Disable reminders
        await notificationService.saveSettings(
          isEnabled: false,
          time: notificationService.reminderTime,
        );
        _showSuccessSnackBar('Daily reminders disabled');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to update reminder settings');
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changeReminderTime() async {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: notificationService.reminderTime ?? const TimeOfDay(hour: 20, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF87A96B), // Sage Green
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        await notificationService.saveSettings(
          isEnabled: true,
          time: selectedTime,
        );
        _showSuccessSnackBar('Reminder time updated to ${selectedTime.format(context)}');
      } catch (e) {
        _showErrorSnackBar('Failed to update reminder time');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F4E9), // Pale Sand
      appBar: AppBar(
        title: Text(
          'Reminder Settings',
          style: TextStyle(
            color: Color(0xFF2E5E3A), // Deep Forest
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Color(0xFF87A96B), // Sage Green
      ),
      body: Consumer<NotificationService>(
        builder: (context, notificationService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFD1E5F0), // Pale Sky Blue
                        Color(0xFFF8F4E9), // Pale Sand
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF87A96B).withOpacity(0.1),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF87A96B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.notifications_active, color: Color(0xFF87A96B), size: 20),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Mindfulness Reminders',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E5E3A), // Deep Forest
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Set daily reminders to help maintain your mindfulness practice and track your emotional wellbeing consistently.',
                        style: TextStyle(
                          color: Color(0xFF708090), // Slate
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Settings Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Reminder Toggle
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFFD8E4D3)), // Pale Sage
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFF87A96B).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.psychology,
                                color: Color(0xFF87A96B),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Mood Check-in',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E5E3A), // Deep Forest
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Receive a gentle reminder to track your mood and stress levels',
                                    style: TextStyle(
                                      color: Color(0xFF708090), // Slate
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            if (_isLoading)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF87A96B)),
                                ),
                              )
                            else
                              Switch(
                                value: notificationService.isReminderEnabled,
                                onChanged: _toggleReminders,
                                activeColor: Color(0xFF87A96B), // Sage Green
                              ),
                          ],
                        ),
                      ),

                      if (notificationService.isReminderEnabled) ...[
                        const SizedBox(height: 20),
                        Divider(color: Color(0xFFD8E4D3)), // Pale Sage
                        const SizedBox(height: 20),

                        // Time Setting
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color(0xFFD8E4D3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xFFA2C4D9).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.access_time,
                                  color: Color(0xFFA2C4D9), // Soft Sky Blue
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reminder Time',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E5E3A),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      notificationService.reminderTime?.format(context) ?? 'Not set',
                                      style: TextStyle(
                                        color: Color(0xFF708090),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              IconButton(
                                onPressed: _isLoading ? null : _changeReminderTime,
                                icon: Icon(
                                  Icons.edit,
                                  color: Color(0xFF87A96B),
                                ),
                                tooltip: 'Change time',
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Benefits Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFEBF8FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFB8C9A9).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.emoji_objects, size: 16, color: Color(0xFF2E5E3A)),
                                SizedBox(width: 8),
                                Text(
                                  'Why set reminders?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E5E3A),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Regular check-ins help you:\n• Build consistent mindfulness habits\n• Track emotional patterns over time\n• Develop greater self-awareness\n• Maintain mental wellbeing',
                              style: TextStyle(
                                color: Color(0xFF708090),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tips Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFD8E4D3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Tips for Effective Reminders',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E5E3A),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Choose a time when you\'re usually relaxed\n• Keep your notifications brief and gentle\n• Use reminders as prompts, not pressures\n• Adjust the time if it doesn\'t fit your routine',
                        style: TextStyle(
                          color: Color(0xFF708090),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}