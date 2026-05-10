import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  // Helper method to show Time Picker with consistent theming
  Future<TimeOfDay?> _showStyledTimePicker(
      BuildContext context, TimeOfDay initialTime) async {
    final theme = Theme.of(context);
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: theme.copyWith(
            // REQ-008: Style Time Picker to match the theme
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary, // Sage Green header/accent
              onPrimary:
                  theme.colorScheme.onPrimary, // Off-White text on accent
              surface: theme.colorScheme.surface, // Off-White background
              onSurface: theme.colorScheme.onSurface, // Charcoal text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    theme.colorScheme.primary, // Sage Green buttons
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        return Scaffold(
          // REQ-008: Use themed background color
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            // REQ-008: Use primary color for App Bar background (Sage Green)
            backgroundColor: theme.colorScheme.primary,
            // REQ-008: Use onPrimary color for icons/text (Off-White)
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 1,
            title: Text(
              'Reminder Settings',
              style: GoogleFonts.lora(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Daily Mood Reminder Switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Daily Mood Reminder',
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Receive a daily reminder to check in with your mood',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface
                          .withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  value: notificationService.isReminderEnabled,
                  // REQ-008: Use themed colors for the Switch
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (bool value) async {
                    if (value &&
                        !await notificationService
                            .requestNotificationPermissions()) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Please enable notifications in your device settings',
                            ),
                            backgroundColor: Colors.red.shade400,
                          ),
                        );
                      }
                      return;
                    }

                    if (value && notificationService.reminderTime == null) {
                      // If enabling reminders but no time is set, show time picker
                      if (context.mounted) {
                        final TimeOfDay? selectedTime =
                            await _showStyledTimePicker(
                          context,
                          TimeOfDay.now(),
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

                // Reminder Time Setting
                if (notificationService.isReminderEnabled) ...[
                  const Divider(height: 24),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Reminder Time',
                      style: GoogleFonts.lora(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      notificationService.reminderTime?.format(context) ??
                          'Not set',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withAlpha((0.7 * 255).round()),
                      ),
                    ),
                    trailing: Icon(
                      Icons.access_time,
                      color: theme.colorScheme.primary,
                    ),
                    onTap: () async {
                      final TimeOfDay? selectedTime =
                          await _showStyledTimePicker(
                        context,
                        notificationService.reminderTime ?? TimeOfDay.now(),
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

                // Descriptive text
                Text(
                  'Daily reminders can help you maintain a consistent mindfulness practice and track your mood patterns over time.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface
                        .withAlpha((0.6 * 255).round()),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
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
