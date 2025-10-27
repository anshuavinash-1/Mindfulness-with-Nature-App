import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Set the theme for better text readability
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      home: const Scaffold(
        // Set a gentle, nature-inspired background color
        backgroundColor: Color(0xFFE8F5E9), 
        body: Center(
          child: Text(
            'Mindfulness with Nature App',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20), // Dark green color
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
