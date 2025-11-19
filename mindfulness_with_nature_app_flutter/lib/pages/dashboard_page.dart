import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'notification_settings_page.dart';
import 'mood_tracking_page.dart';
import 'my_journey_screen.dart'; // For REQ-004 progress visualization

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int _meditationMinutes = 0;
  int _completedSessions = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addMeditationSession(int minutes) {
    if (mounted) {
      setState(() {
        _meditationMinutes += minutes;
        _completedSessions += 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Color(0xFFF8F4E9), // Pale Sand - REQ-008
      appBar: AppBar(
        backgroundColor: Colors.white, // White background for minimalism
        foregroundColor: Color(0xFF36454F), // Charcoal - REQ-008
        elevation: 0,
        title: Text(
          'Mindfulness with Nature',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E5E3A), // Deep Forest - REQ-008
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
            icon: Icon(Icons.notifications_outlined, color: Color(0xFF87A96B)), // Sage Green
            tooltip: 'Reminder Settings',
          ),
          IconButton(
            onPressed: () {
              authService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            icon: Icon(Icons.logout_outlined, color: Color(0xFF87A96B)), // Sage Green
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeTab(completedSessions: _completedSessions),
          MeditationTab(onSessionComplete: _addMeditationSession),
          const MoodTrackingPage(),
          MyJourneyScreen(), // Using the REQ-004 implementation
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF87A96B), // Sage Green - REQ-008
          unselectedItemColor: Color(0xFFB8B8B8), // Stone - REQ-008
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement_outlined),
              activeIcon: Icon(Icons.self_improvement),
              label: 'Meditate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mood_outlined),
              activeIcon: Icon(Icons.mood),
              label: 'Mood',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_outlined),
              activeIcon: Icon(Icons.eco),
              label: 'Journey',
            ),
          ],
        ),
      ),
    );
  }
}

// Home Tab
class HomeTab extends StatelessWidget {
  final int completedSessions;

  const HomeTab({super.key, required this.completedSessions});

  void _showComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName coming soon!'),
        backgroundColor: Color(0xFF87A96B), // Sage Green
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFD1E5F0), // Pale Sky Blue - REQ-008
                  Color(0xFFF8F4E9), // Pale Sand - REQ-008
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF87A96B).withOpacity(0.1),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFF87A96B), // Sage Green
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.eco, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E5E3A), // Deep Forest
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ready for your mindful moment?',
                            style: TextStyle(
                              color: Color(0xFF708090), // Slate
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(color: Color(0xFFD8E4D3)), // Pale Sage
                SizedBox(height: 12),
                Text(
                  'Logged in as: ${authService.userEmail ?? "(not available)"}',
                  style: TextStyle(
                    color: Color(0xFF708090), // Slate
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Sessions completed: $completedSessions',
                  style: TextStyle(
                    color: Color(0xFF87A96B), // Sage Green
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E5E3A), // Deep Forest
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildActionCard(
                icon: Icons.self_improvement,
                title: 'Start Meditation',
                color: Color(0xFF87A96B), // Sage Green
                onTap: () {
                  // Navigate to meditation tab
                  Provider.of<AuthService>(context, listen: false)
                      .navigateToMeditation?.call();
                },
              ),
              _buildActionCard(
                icon: Icons.forest,
                title: 'Nature Sounds',
                color: Color(0xFFA2C4D9), // Soft Sky Blue
                onTap: () {
                  _showComingSoon(context, 'Nature Sounds');
                },
              ),
              _buildActionCard(
                icon: Icons.nature_people,
                title: 'Breathing Exercise',
                color: Color(0xFFE6D7B8), // Sand
                onTap: () {
                  _showComingSoon(context, 'Breathing Exercises');
                },
              ),
              _buildActionCard(
                icon: Icons.nightlight_round,
                title: 'Sleep Stories',
                color: Color(0xFFB8C9A9), // Soft Sage
                onTap: () {
                  _showComingSoon(context, 'Sleep Stories');
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Today's Focus
          Text(
            'Today\'s Focus',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E5E3A), // Deep Forest
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFD8E4D3)), // Pale Sage
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFD700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.emoji_objects, color: Color(0xFFFFB300), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Mindfulness',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E5E3A), // Deep Forest
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Take 5 minutes to focus on your breath and be present',
                        style: TextStyle(
                          color: Color(0xFF708090), // Slate
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, 
                     color: Color(0xFF87A96B), size: 20), // Sage Green
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Progress Preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFD8E4D3)), // Pale Sage
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Journey Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E5E3A), // Deep Forest
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$completedSessions',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF87A96B), // Sage Green
                            ),
                          ),
                          Text(
                            'Sessions',
                            style: TextStyle(
                              color: Color(0xFF708090), // Slate
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Color(0xFFD8E4D3), // Pale Sage
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${(completedSessions / 7).ceil()}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF87A96B), // Sage Green
                            ),
                          ),
                          Text(
                            'Weeks',
                            style: TextStyle(
                              color: Color(0xFF708090), // Slate
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to Journey tab
                      Provider.of<AuthService>(context, listen: false)
                          .navigateToJourney?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF87A96B), // Sage Green
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text('View Full Progress'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0xFFD8E4D3), width: 1), // Pale Sage
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF36454F), // Charcoal
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Meditation Tab
class MeditationTab extends StatefulWidget {
  final Function(int)? onSessionComplete;

  const MeditationTab({super.key, this.onSessionComplete});

  @override
  State<MeditationTab> createState() => _MeditationTabState();
}

class _MeditationTabState extends State<MeditationTab> {
  int _selectedDuration = 5;
  bool _isMeditating = false;
  int _remainingSeconds = 0;
  Timer? _timer;

  void _startMeditation() {
    _timer?.cancel();
    
    setState(() {
      _isMeditating = true;
      _remainingSeconds = _selectedDuration * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeMeditation();
          timer.cancel();
        }
      });
    });
  }

  void _completeMeditation() {
    _timer?.cancel();
    setState(() {
      _isMeditating = false;
    });

    widget.onSessionComplete?.call(_selectedDuration);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Meditation Complete! 🎉',
          style: TextStyle(
            color: Color(0xFF2E5E3A), // Deep Forest
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Great job completing your $_selectedDuration minute meditation session.',
          style: TextStyle(color: Color(0xFF708090)), // Slate
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue',
              style: TextStyle(color: Color(0xFF87A96B)), // Sage Green
            ),
          ),
        ],
      ),
    );
  }

  void _stopMeditation() {
    _timer?.cancel();
    setState(() {
      _isMeditating = false;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isMeditating) ...[
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF87A96B).withOpacity(0.1), // Sage Green light
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.self_improvement,
                size: 60,
                color: Color(0xFF87A96B), // Sage Green
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Meditation Timer',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E5E3A), // Deep Forest
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your meditation duration',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF708090), // Slate
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFD8E4D3)), // Pale Sage
              ),
              child: Text(
                '$_selectedDuration minutes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF87A96B), // Sage Green
                ),
              ),
            ),
            const SizedBox(height: 32),
            Slider(
              value: _selectedDuration.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: '$_selectedDuration minutes',
              onChanged: (value) =>
                  setState(() => _selectedDuration = value.toInt()),
              activeColor: Color(0xFF87A96B), // Sage Green
              inactiveColor: Color(0xFFD8E4D3), // Pale Sage
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startMeditation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF87A96B), // Sage Green
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start Meditation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ] else ...[
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: _remainingSeconds / (_selectedDuration * 60),
                    strokeWidth: 8,
                    backgroundColor: Color(0xFFD8E4D3), // Pale Sage
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF87A96B)), // Sage Green
                  ),
                ),
                Column(
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E5E3A), // Deep Forest
                      ),
                    ),
                    Text(
                      'remaining',
                      style: TextStyle(
                        color: Color(0xFF708090), // Slate
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'Focus on your breath...',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Color(0xFF708090), // Slate
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _stopMeditation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDC2626), // Red
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'End Session',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}