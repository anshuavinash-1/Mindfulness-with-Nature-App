import 'package:flutter/material.dart';
import 'tabs/home_tab.dart';
import 'tabs/meditation_timer_tab.dart';
import 'tabs/progress_tab.dart';
import '../mood_tracking_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const MeditationTimerTab(),
    const ProgressTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindfulness with Nature'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MoodTrackingPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Meditate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}