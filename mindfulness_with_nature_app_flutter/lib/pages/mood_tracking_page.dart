import 'package:flutter/material.dart';

class MoodTrackingPage extends StatelessWidget {
  const MoodTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracking'),
      ),
      body: const Center(
        child: Text('Mood tracking UI goes here'),
      ),
    );
  }
}
