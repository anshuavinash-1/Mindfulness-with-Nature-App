// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:provider/provider.dart';
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';
=======

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

// Services
import 'services/auth_service.dart';

// Pages
>>>>>>> origin/main
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'firebase_options.dart';

// -----------------------------------------------------------
// THEME
// -----------------------------------------------------------

<<<<<<< HEAD
// Core Colors
const Color primarySageGreen =
    Color(0xFF8FBC8F); // Primary button, active states
const Color accentSoftSkyBlue =
    Color(0xFFADD8E6); // Secondary accent, highlights
const Color backgroundSand = Color(0xFFF5F5DC); // Main screen background
const Color surfaceOffWhite = Color(0xFFFAF0E6); // Card/container surface
const Color textCharcoal =
    Color(0xFF36454F); // Primary text color (not pure black)
=======
final Color primarySageGreen = const Color(0xFF8FBC8F);
final Color accentSoftSkyBlue = const Color(0xFFADD8E6);
final Color backgroundSand = const Color(0xFFF5F5DC);
final Color surfaceOffWhite = const Color(0xFFFAF0E6);
final Color textCharcoal = const Color(0xFF36454F);
>>>>>>> origin/main

final ThemeData calmTheme = ThemeData(
<<<<<<< HEAD
    // Global Scaffold Background
    scaffoldBackgroundColor: backgroundSand,

    // Define the core color scheme based on the earthy palette
    colorScheme: const ColorScheme.light(
      primary: primarySageGreen,
      secondary: accentSoftSkyBlue,
      surface: surfaceOffWhite,
      onPrimary: Colors.white, // Text/Icons on background color
      onSurface: textCharcoal, // Text/Icons on surface color
=======
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
>>>>>>> origin/main
    ),

<<<<<<< HEAD
    // Apply typography consistency
    textTheme: const TextTheme(
      // Use the deep charcoal for all main text styles
      bodyLarge: TextStyle(color: textCharcoal),
      bodyMedium: TextStyle(color: textCharcoal),
      titleLarge: TextStyle(color: textCharcoal, fontWeight: FontWeight.w600),
      headlineMedium:
          TextStyle(color: textCharcoal, fontWeight: FontWeight.w500),
    ),

    // Minimize visual clutter and shadows (minimalistic aesthetic)
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceOffWhite,
      elevation: 0, // Flat design
      iconTheme: IconThemeData(color: textCharcoal),
      titleTextStyle: TextStyle(
        color: textCharcoal,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Use subtle borders/shapes for buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primarySageGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 1, // Subtle lift
      ),
    ),

    // Style for Cards/Containers
    cardTheme: CardThemeData(
      color: surfaceOffWhite,
      elevation: 2, // Minimal, soft shadow
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
=======
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
>>>>>>> origin/main

// -----------------------------------------------------------
// MAIN
// -----------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

<<<<<<< HEAD
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Sample DB Usage
  // await FirebaseFirestore.instance.collection('test').add({
  //   'message': 'Hello World',
  //   'timestamp': Timestamp.now(),
  // });

  runApp(MyApp(prefs: prefs));

  var firebaseInitialized = false;
  try {
    // Try to initialize Firebase. This will throw on platforms that are not
    // configured (no google-services.json / firebase_options). We catch and
    // continue so the app can run in a degraded mode while you finish setup.
    await firebase_core.Firebase.initializeApp();
    firebaseInitialized = true;
  } catch (e, st) {
    // Do not crash the app if Firebase configuration is missing. Log for
    // visibility and continue with a non-Firebase fallback service.
    debugPrint('Firebase.initializeApp() failed: $e\n$st');
  }

  runApp(MindfulnessApp(firebaseInitialized: firebaseInitialized));
=======
  runApp(const MindfulnessApp());
>>>>>>> origin/main
}

class MindfulnessApp extends StatelessWidget {
  final bool firebaseInitialized;

  const MindfulnessApp({super.key, this.firebaseInitialized = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
<<<<<<< HEAD
        // Provide the AuthService. AuthService is resilient when Firebase
        // isn't initialized and will operate in a degraded mode.
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Add other providers here as needed:
        // ChangeNotifierProvider<MoodService>(create: (_) => MoodService()),
        // ChangeNotifierProvider<PlaceService>(create: (_) => PlaceService()),
      ],
      child: MaterialApp(
        title: 'Mindfulness with Nature App',
        // REQUIRED: Apply the custom theme to implement REQ-008
        theme: calmTheme,

        // Use AuthWrapper to handle authentication state
=======
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'Mindfulness with Nature',
        theme: calmTheme,
>>>>>>> origin/main
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

<<<<<<< HEAD
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
=======
    return StreamBuilder<fb.User?>(
      stream: authService.authStateChanges, // FIXED
>>>>>>> origin/main
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

<<<<<<< HEAD
        // If user is logged in, go to dashboard
        if (snapshot.hasData && snapshot.data != null) {
          return DashboardPage(user: snapshot.data!);
        }

        // If no user, show login page
        return const LoginPage();
=======
        return DashboardPage(user: user); // FIXED
>>>>>>> origin/main
      },
    );

  }
}
<<<<<<< HEAD

// --- Example Screen Utilizing the Theme ---

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme colors are automatically inherited by widgets
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nature Sessions'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // The Card uses surfaceOffWhite for background and textCharcoal for text
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Breathe in the Forest Air',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // The Button uses primarySageGreen
            ElevatedButton(
              onPressed: () {
                // Start session logic
              },
              child: const Text('Start Mindfulness'),
            ),
          ],
        ),
      ),
      // The FloatingActionButton uses primarySageGreen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to profile or settings
        },
        child: const Icon(Icons.person_outline),
      ),
    );
  }
}
=======
>>>>>>> origin/main
