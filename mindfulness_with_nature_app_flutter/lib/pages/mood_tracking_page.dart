import 'package:flutter/material.dart';

class MoodTrackingPage extends StatelessWidget {
  const MoodTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracking'),
        backgroundColor: Colors.purple[800],
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            // Add mood selection UI here
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Mood emoji/icon buttons
                Icon(Icons.sentiment_very_dissatisfied, size: 40),
                Icon(Icons.sentiment_dissatisfied, size: 40),
                Icon(Icons.sentiment_neutral, size: 40),
                Icon(Icons.sentiment_satisfied, size: 40),
                Icon(Icons.sentiment_very_satisfied, size: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}