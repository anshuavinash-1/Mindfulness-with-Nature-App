import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reminder Settings'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Daily Mood Reminder'),
                  subtitle: const Text(
                    'Receive a daily reminder to check in with your mood',
                  ),
                  value: notificationService.isReminderEnabled,
                  onChanged: (bool value) async {
                    if (value && !await notificationService.requestNotificationPermissions()) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enable notifications in your device settings',
                            ),
                          ),
                        );
                      }
                      return;
                    }
                    
                    if (value && notificationService.reminderTime == null) {
                      // If enabling reminders but no time is set, show time picker
                      if (context.mounted) {
                        final TimeOfDay? selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        
                        if (selectedTime != null) {
                          await notificationService.saveSettings(
                            isEnabled: true,
                            time: selectedTime,
                          );
                        }
                      }
                    } else {
                      await notificationService.saveSettings(
                        isEnabled: value,
                        time: notificationService.reminderTime,
                      );
                    }
                  },
                ),
                if (notificationService.isReminderEnabled) ...[
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Reminder Time'),
                    subtitle: Text(
                      notificationService.reminderTime?.format(context) ??
                          'Not set',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: notificationService.reminderTime ??
                            TimeOfDay.now(),
                      );
                      
                      if (selectedTime != null) {
                        await notificationService.saveSettings(
                          isEnabled: true,
                          time: selectedTime,
                        );
                      }
                    },
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Daily reminders can help you maintain a consistent mindfulness practice and track your mood patterns over time.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}