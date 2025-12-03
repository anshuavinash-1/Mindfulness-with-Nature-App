import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'bottom_nav.dart';
import 'home_screen.dart';
import 'activities_page.dart';
import 'mood_page.dart';
import 'transfarmation.dart';
import 'community_page.dart';


class DashboardPage extends StatefulWidget {
  final fb.User user;

  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    final email = widget.user.email ?? "User";

    _tabs = [
      HomeScreen(userName: email),
      const ActivitiesPage(),
      const MoodSettingsPage(),
      const TransformationPage(),
      const CommunityPage()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _tabs[_currentIndex],

      // Dynamic + external
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
