import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/mood_service.dart';
import 'services/places_service.dart';
import 'services/notification_service.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final prefs = await SharedPreferences.getInstance();
    runApp(MyApp(prefs: prefs));
  } catch (e) {
    // Fallback UI if SharedPreferences fails
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFFF8F4E9),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Color(0xFF87A96B),
                ),
                SizedBox(height: 20),
                Text(
                  'App Initialization Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF36454F),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Please restart the application.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF708090),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => MoodService(prefs)),
        ChangeNotifierProvider(create: (_) => PlacesService(prefs)),
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: MaterialApp(
        title: 'Mindfulness with Nature',
        theme: ThemeData(
          // Color Scheme - Earthy palette for REQ-008
          primaryColor: Color(0xFF87A96B), // Sage Green
          primaryColorLight: Color(0xFFB8C9A9), // Soft Sage
          primaryColorDark: Color(0xFF2E5E3A), // Deep Forest
          scaffoldBackgroundColor: Color(0xFFF8F4E9), // Pale Sand
          canvasColor: Colors.white,
          
          // App Bar Theme
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF36454F), // Charcoal
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Color(0xFF87A96B)),
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF36454F),
            ),
          ),
          
          // Text Theme
          textTheme: TextTheme(
            displayLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF36454F),
            ),
            displayMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF36454F),
            ),
            displaySmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF36454F),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF708090), // Slate
              height: 1.5,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF708090),
              height: 1.5,
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFFB8B8B8), // Stone
            ),
            titleMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF36454F),
            ),
            titleSmall: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF36454F),
            ),
          ),
          
          // Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF87A96B), // Sage Green
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Text Button Theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF87A96B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Outlined Button Theme
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(0xFF87A96B),
              side: BorderSide(color: Color(0xFF87A96B), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Input Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFB8C9A9), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFB8C9A9), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF87A96B), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintStyle: TextStyle(
              color: Color(0xFFB8B8B8),
              fontSize: 16,
            ),
            labelStyle: TextStyle(
              color: Color(0xFF708090),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // Card Theme
          cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ).copyWith(),
          
          // Dialog Theme
          dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ).copyWith(),
          
          // Bottom Navigation Bar Theme
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFF87A96B),
            unselectedItemColor: Color(0xFFB8B8B8),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          
          // Divider Theme
          dividerTheme: DividerThemeData(
            color: Color(0xFFD8E4D3), // Pale Sage
            thickness: 1,
            space: 0,
          ),
          
          // Progress Indicator Theme
          progressIndicatorTheme: ProgressIndicatorThemeData(
            color: Color(0xFF87A96B),
            linearTrackColor: Color(0xFFD8E4D3),
          ),
          
          // Floating Action Button Theme
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF87A96B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          
          useMaterial3: true,
        ),
        home: Consumer<AuthService>(
          builder: (context, auth, _) {
            // Add loading state while checking authentication
            if (auth.isLoading) {
              return Scaffold(
                backgroundColor: Color(0xFFF8F4E9),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF87A96B)),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF708090),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return auth.isLoggedIn ? const DashboardPage() : const LoginPage();
          },
        ),
        debugShowCheckedModeBanner: false,
        
        // Add error handling for routes
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0, // Prevent system font scaling issues
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

// Optional: Add a splash screen component
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F4E9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFF87A96B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.eco,
                color: Colors.white,
                size: 40,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Mindfulness with Nature',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF36454F),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Find your inner peace',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF708090),
              ),
            ),
          ],
        ),
      ),
    );
  }
}