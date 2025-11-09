import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'notification_settings_page.dart';
import 'mood_tracking_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int _meditationMinutes = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addMeditationSession(int minutes) {
    setState(() {
      _meditationMinutes += minutes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Mindfulness Dashboard'),
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
            icon: const Icon(Icons.notifications),
            tooltip: 'Reminder Settings',
          ),
          IconButton(
            onPressed: () {
              // Perform logout and navigate back to the login screen, clearing navigation stack
              authService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeTab(),
          MeditationTab(onSessionComplete: _addMeditationSession),
          const MoodTrackingPage(),
          ProgressTab(totalMinutes: _meditationMinutes),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Meditate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mood),
            label: 'Mood',
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

// Home Tab
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green[100]!,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back! 👋',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready for your mindful moment?',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Logged in as: ${authService.userEmail ?? "(not available)"}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
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
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
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
                color: Colors.green,
                onTap: () {},
              ),
              _buildActionCard(
                icon: Icons.forest,
                title: 'Nature Sounds',
                color: Colors.blue,
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _buildActionCard(
                icon: Icons.nature,
                title: 'Breathing Exercise',
                color: Colors.orange,
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _buildActionCard(
                icon: Icons.nightlight,
                title: 'Sleep Stories',
                color: Colors.purple,
                onTap: () {
                  _showComingSoon(context);
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
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_objects, color: Colors.amber[700], size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Mindfulness',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Take 5 minutes to focus on your breath',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.green[700]),
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
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        duration: Duration(seconds: 2),
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
    setState(() {
      _isMeditating = true;
      _remainingSeconds = _selectedDuration * 60;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
        title: const Text('Meditation Complete! 🎉'),
        content: Text('Great job completing your $_selectedDuration minute session.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isMeditating) ...[
            Icon(Icons.self_improvement, size: 80, color: Colors.green[700]),
            const SizedBox(height: 20),
            const Text('Meditation Timer', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 10),
            const Text('Choose your meditation duration', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 40),
            Text('$_selectedDuration minutes', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),
            Slider(
              value: _selectedDuration.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: '$_selectedDuration minutes',
              onChanged: (value) => setState(() => _selectedDuration = value.toInt()),
              activeColor: Colors.green[700],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _startMeditation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Start Meditation', style: TextStyle(fontSize: 18)),
            ),
          ] else ...[
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _remainingSeconds / (_selectedDuration * 60),
                    strokeWidth: 8,
                    backgroundColor: Colors.green[100],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                  ),
                ),
                Column(
                  children: [
                    Text(_formatTime(_remainingSeconds), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    Text('minutes remaining', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text('Focus on your breath...', style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _stopMeditation,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
              child: const Text('End Session'),
            ),
          ],
        ],
      ),
    );
  }
}

// Progress Tab
class ProgressTab extends StatelessWidget {
  final int totalMinutes;
  
  const ProgressTab({super.key, required this.totalMinutes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.green[100]!, blurRadius: 10)],
            ),
            child: Column(
              children: [
                Text('Your Mindfulness Journey', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800])),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total Minutes', '$totalMinutes', Icons.timer),
                    _buildStatItem('Sessions', '${(totalMinutes / 5).ceil()}', Icons.self_improvement),
                    _buildStatItem('Current Streak', '1 day', Icons.local_fire_department),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber[700], size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Great Start!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        totalMinutes == 0 
                            ? 'Start your first meditation session to begin your journey!'
                            : 'You\'ve meditated for $totalMinutes minutes. Keep going!',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800])),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _buildActivityItem('Morning Meditation', '5 min', 'Today, 8:00 AM'),
                      _buildActivityItem('Focus Session', '10 min', 'Yesterday, 7:30 PM'),
                      if (totalMinutes == 0) ...[
                        _buildActivityItem('Evening Relaxation', '15 min', 'Nov 8, 6:00 PM'),
                        _buildActivityItem('Breathing Exercise', '8 min', 'Nov 7, 9:00 AM'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.green[700]),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildActivityItem(String title, String duration, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.self_improvement, color: Colors.green[700]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(duration),
        trailing: Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ),
    );
  }
}