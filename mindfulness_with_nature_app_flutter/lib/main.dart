// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
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
    onPrimary: Colors.white,      // Text/Icons on primary color
    onBackground: textCharcoal,   // Text/Icons on background color
    onSurface: textCharcoal,      // Text/Icons on surface color
  ),

  // Apply typography consistency
  textTheme: TextTheme(
    // Use the deep charcoal for all main text styles
    bodyLarge: TextStyle(color: textCharcoal),
    bodyMedium: TextStyle(color: textCharcoal),
    titleLarge: TextStyle(color: textCharcoal, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(color: textCharcoal, fontWeight: FontWeight.w500),
  ),

  // Minimize visual clutter and shadows (minimalistic aesthetic)
  appBarTheme: AppBarTheme(
    color: surfaceOffWhite,
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
  cardTheme: CardTheme(
    color: surfaceOffWhite,
    elevation: 2, // Minimal, soft shadow
    margin: EdgeInsets.all(16.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  )
);

// --- Main Application Entry Point ---

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
        // Add other providers here as needed:
        // ChangeNotifierProvider<MoodService>(create: (_) => MoodService()),
        // ChangeNotifierProvider<PlaceService>(create: (_) => PlaceService()),
      ],
      child: MaterialApp(
        title: 'Mindfulness with Nature App',
        // REQUIRED: Apply the custom theme to implement REQ-008
        theme: calmTheme, 
        
        // Use AuthWrapper to handle authentication state
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
    final authService = Provider.of<AuthService>(context);
    
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