// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

// Services
import 'services/auth_service.dart';

// Pages
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

// -----------------------------------------------------------
// THEME
// -----------------------------------------------------------

final Color primarySageGreen = const Color(0xFF8FBC8F);
final Color accentSoftSkyBlue = const Color(0xFFADD8E6);
final Color backgroundSand = const Color(0xFFF5F5DC);
final Color surfaceOffWhite = const Color(0xFFFAF0E6);
final Color textCharcoal = const Color(0xFF36454F);

final ThemeData calmTheme = ThemeData(
  scaffoldBackgroundColor: backgroundSand,

  colorScheme: ColorScheme.light(
    primary: primarySageGreen,
    secondary: accentSoftSkyBlue,
    background: backgroundSand,
    surface: surfaceOffWhite,
    onPrimary: Colors.white,
    onBackground: textCharcoal,
    onSurface: textCharcoal,
  ),

  textTheme: TextTheme(
    bodyLarge: TextStyle(color: textCharcoal),
    bodyMedium: TextStyle(color: textCharcoal),
    titleLarge: TextStyle(color: textCharcoal, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(color: textCharcoal, fontWeight: FontWeight.w500),
  ),

  appBarTheme: AppBarTheme(
    color: surfaceOffWhite,
    elevation: 0,
    iconTheme: IconThemeData(color: textCharcoal),
    titleTextStyle: TextStyle(
      color: textCharcoal,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primarySageGreen,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
    ),
  ),

  cardTheme: CardThemeData(
    color: surfaceOffWhite,
    elevation: 2,
    margin: const EdgeInsets.all(16.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

// -----------------------------------------------------------
// MAIN
// -----------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MindfulnessApp());
}

class MindfulnessApp extends StatelessWidget {
  const MindfulnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'Mindfulness with Nature',
        theme: calmTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// -----------------------------------------------------------
// AUTH WRAPPER
// -----------------------------------------------------------

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<fb.User?>(
      stream: authService.authStateChanges, // FIXED
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Scaffold(
        //     body: Center(child: CircularProgressIndicator()),
        //   );
        // }

        final user = snapshot.data;

        if (user == null) {
          return const LoginPage();
        }

        return DashboardPage(user: user); // FIXED
      },
    );

  }
}
