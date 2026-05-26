import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user_model.dart';
import 'pages/dashboard_page.dart';
import 'pages/login_page.dart';
import 'service/notification_service.dart';
import 'services/auth_service.dart';

const Color primarySageGreen = Color(0xFF8FBC8F);
const Color accentSoftSkyBlue = Color(0xFFADD8E6);
const Color backgroundSand = Color(0xFFF5F5DC);
const Color surfaceOffWhite = Color(0xFFFAF0E6);
const Color textCharcoal = Color(0xFF36454F);

final ThemeData calmTheme = ThemeData(
  scaffoldBackgroundColor: backgroundSand,
  colorScheme: const ColorScheme.light(
    primary: primarySageGreen,
    secondary: accentSoftSkyBlue,
    surface: surfaceOffWhite,
    onPrimary: Colors.white,
    onSurface: textCharcoal,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: textCharcoal),
    bodyMedium: TextStyle(color: textCharcoal),
    titleLarge: TextStyle(color: textCharcoal, fontWeight: FontWeight.w600),
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MindfulnessApp());
}

class MindfulnessApp extends StatelessWidget {
  const MindfulnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => NotificationService()..init()),
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return DashboardPage(user: snapshot.data!);
        }

        return const LoginPage();
      },
    );
  }
}
