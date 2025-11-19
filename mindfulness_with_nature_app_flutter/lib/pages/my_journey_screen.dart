import 'package:flutter/material.dart';

class MyJourneyScreen extends StatelessWidget {
  const MyJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journey'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF2E5E3A),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 64, color: Color(0xFF87A96B)),
            SizedBox(height: 16),
            Text(
              'Journey Progress',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E5E3A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your mindfulness journey visualization',
              style: TextStyle(
                color: Color(0xFF708090),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
