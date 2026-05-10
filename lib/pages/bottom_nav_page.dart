import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'activities_page.dart';
import 'progress_page.dart';
import 'mood_page.dart';
import 'community_page.dart';
import 'bottom_nav.dart';

class BottomNavPage extends StatefulWidget {
  final String userName;

  const BottomNavPage({super.key, this.userName = 'User'});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(userName: widget.userName),
      ActivitiesPage(),
      MoodSettingsPage(),
      ProgressPage(),
      CommunityPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
