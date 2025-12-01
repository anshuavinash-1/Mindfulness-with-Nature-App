import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart'; 
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

// REQ-008: Muted, Earthy Color Palette Definition

// Core Colors
final Color primarySageGreen = Color(0xFF8FBC8F); // Primary button, active states
final Color accentSoftSkyBlue = Color(0xFFADD8E6); // Secondary accent, highlights
final Color backgroundSand = Color(0xFFF5F5DC); // Main screen background
final Color surfaceOffWhite = Color(0xFFFAF0E6); // Card/container surface
final Color textCharcoal = Color(0xFF36454F); // Primary text color (not pure black)

// REQ-008: Calm, Minimalistic ThemeData
final ThemeData calmTheme = ThemeData(
  // Global Scaffold Background
  scaffoldBackgroundColor: backgroundSand,

  // Define the core color scheme based on the earthy palette
  colorScheme: ColorScheme.light(
    primary: primarySageGreen,
    secondary: accentSoftSkyBlue,
    background: backgroundSand,
    surface: surfaceOffWhite,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: textCharcoal,
    onSurface: textCharcoal,
  ),

  // Apply typography consistency
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: textCharcoal),
    bodyMedium: TextStyle(color: textCharcoal),
    titleLarge: TextStyle(color: textCharcoal, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(color: textCharcoal, fontWeight: FontWeight.w500),
  ),

  // Minimize visual clutter and shadows (minimalistic aesthetic)
  appBarTheme: AppBarTheme(
    backgroundColor: surfaceOffWhite,
    elevation: 0,
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
      elevation: 1,
    ),
  ),

  // Style for Cards/Containers
  cardTheme: CardThemeData(
    color: surfaceOffWhite,
    elevation: 2,
    margin: EdgeInsets.all(16.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

void main() {
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
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: backgroundSand,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primarySageGreen),
              ),
            ),
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

// Optional: Keep or remove this example screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nature Sessions'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
            ElevatedButton(
              onPressed: () {},
              child: const Text('Start Mindfulness'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primarySageGreen,
        child: const Icon(Icons.person_outline, color: Colors.white),
      ),
    );
  }
}