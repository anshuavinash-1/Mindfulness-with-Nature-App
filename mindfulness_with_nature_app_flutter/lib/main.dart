import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'models/user_model.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('✅ Firebase initialized successfully');

  // Run the app
  runApp(const MindfulnessApp());
}

class MindfulnessApp extends StatelessWidget {
  const MindfulnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the AuthService
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Initialize notifications lazily so the first frame is not blocked.
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: MaterialApp(
        title: 'Mindfulness with Nature App',
        theme: calmTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// --- Auth Wrapper to handle authentication state ---

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // listen: false — the stream is cached in AuthService; we must not
    // recreate the StreamBuilder's stream on every notifyListeners() call
    // or the loading spinner reappears on every auth state notification.
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is logged in, go to dashboard
        if (snapshot.hasData && snapshot.data != null) {
          return DashboardPage(user: snapshot.data!);
        }

        // If no user, show login page
        return const LoginPage();
      },
    );
  }
}

// --- Quick Settings Widget for Dashboard (Integrated notification toggle) ---

class QuickSettingsWidget extends StatelessWidget {
  const QuickSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Settings',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Daily Reminders'),
              subtitle: const Text('Get notified to check your mood daily'),
              value: notificationService.isReminderEnabled,
              onChanged: (bool value) async {
                if (value && !await notificationService.requestNotificationPermissions()) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enable notifications in settings'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                  return;
                }

                if (value && notificationService.reminderTime == null) {
                  if (!context.mounted) {
                    return;
                  }

                  // If enabling but no time set, show time picker
                  final TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 19, minute: 0),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: theme.copyWith(
                          colorScheme: theme.colorScheme.copyWith(
                            primary: theme.colorScheme.primary,
                            onPrimary: theme.colorScheme.onPrimary,
                            surface: theme.colorScheme.surface,
                            onSurface: theme.colorScheme.onSurface,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (selectedTime != null && context.mounted) {
                    final formattedTime = selectedTime.format(context);
                    await notificationService.saveSettings(
                      isEnabled: true,
                      time: selectedTime,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Daily reminder set for $formattedTime'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    await notificationService.saveSettings(
                      isEnabled: false,
                      time: notificationService.reminderTime,
                    );
                  }
                } else {
                  await notificationService.saveSettings(
                    isEnabled: value,
                    time: notificationService.reminderTime,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(value ? 'Reminders enabled' : 'Reminders disabled'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                }
              },
              activeThumbColor: theme.colorScheme.primary,
            ),
            if (notificationService.isReminderEnabled && notificationService.reminderTime != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Text(
                  'Daily reminder at ${notificationService.reminderTime!.format(context)}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
