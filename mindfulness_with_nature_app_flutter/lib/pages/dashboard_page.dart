import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'login_page.dart';
import 'notification_settings_page.dart';
import 'mood_tracking_page.dart';

// REQ-008: Dashboard Page
class DashboardPage extends StatefulWidget {
  final User user;
  
  const DashboardPage({super.key, required this.user});

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
    // Check mounted for safe state updates
    if (mounted) {
      setState(() {
        _meditationMinutes += minutes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      // REQ-008: Use theme background (Sand/Beige)
      backgroundColor: theme.scaffoldBackgroundColor,
      
      appBar: AppBar(
        // REQ-008: AppBar inherits from theme (Off-White/low elevation)
        // Explicitly setting foreground color to Charcoal for contrast
        foregroundColor: theme.colorScheme.onBackground,
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
            icon: const Icon(Icons.notifications_none), // Use outline icon for minimalism
            tooltip: 'Reminder Settings',
          ),
          IconButton(
            onPressed: () async {
              try {
                await authService.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error signing out: ${e.toString()}'),
                      backgroundColor: Colors.red.shade400,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeTab(user: widget.user),
          MeditationTab(onSessionComplete: _addMeditationSession),
          // Assuming these pages are styled with the theme too
          const MoodTrackingPage(),
          ProgressTab(totalMinutes: _meditationMinutes, user: widget.user), 
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // REQ-008: Use Sage Green for selected item
        selectedItemColor: theme.colorScheme.primary, 
        // REQ-008: Muted Charcoal for unselected items
        unselectedItemColor: theme.colorScheme.onBackground.withOpacity(0.6), 
        backgroundColor: theme.colorScheme.surface, // Off-White background
        elevation: 0, // Minimalist, flat appearance
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement_outlined),
            label: 'Meditate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mood_outlined),
            label: 'Mood',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}

// Home Tab - Refactored for REQ-008
class HomeTab extends StatelessWidget {
  final User user;
  
  const HomeTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section (Card/Container)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface, // REQ-008: Off-White Surface
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // REQ-008: Soft, subtle shadow
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back! 👋',
                  style: theme.textTheme.titleLarge?.copyWith(
                    // REQ-008: Use Charcoal for bold text
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready for your mindful moment?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Logged in as: ${user.email}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Member since: ${_formatDate(user.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Quick Actions Heading
          Text(
            'Quick Actions',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Quick Actions Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              // REQ-008: Icons use Sage Green (Primary) or Soft Sky Blue (Secondary)
              _buildActionCard(
                context,
                icon: Icons.self_improvement_outlined,
                title: 'Start Meditation',
                accentColor: theme.colorScheme.primary, // Sage Green
                onTap: () {},
              ),
              _buildActionCard(
                context,
                icon: Icons.forest_outlined,
                title: 'Nature Sounds',
                accentColor: theme.colorScheme.secondary, // Soft Sky Blue
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.cloud_outlined,
                title: 'Breathing Exercise',
                accentColor: theme.colorScheme.primary.withOpacity(0.7), // Muted Secondary
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.nights_stay_outlined,
                title: 'Sleep Stories',
                accentColor: theme.colorScheme.onBackground.withOpacity(0.5), // Muted Accent
                onTap: () {
                  _showComingSoon(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // User Preferences Section
          Text(
            'Your Preferences',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Preferences Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface, // Off-White
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)), // Soft Sage Border
            ),
            child: Row(
              children: [
                Icon(Icons.settings_outlined, color: theme.colorScheme.primary, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme: ${user.preferences.theme}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Notifications: ${user.preferences.notificationsEnabled ? 'On' : 'Off'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        'Font Scale: ${user.preferences.fontScale}x',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: theme.colorScheme.primary, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  // Helper method updated to use theme colors and minimal elevation
  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    // REQ-008: Card uses theme surface color and minimal elevation
    return Card(
      elevation: 2, 
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: accentColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
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

// Meditation Tab - Refactored for REQ-008
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
    
    if (mounted) {
      setState(() {
        _isMeditating = false;
      });
    }
    
    widget.onSessionComplete?.call(_selectedDuration);
    
    try {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Meditation Complete! 🎉'),
            content: Text('Great job completing your $_selectedDuration minute session.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (mounted) {
                    setState(() {
                      _selectedDuration = 5; 
                    });
                  }
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary), // Use Sage Green accent
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meditation completed! $_selectedDuration minutes'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _stopMeditation() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _isMeditating = false;
      });
    }
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isMeditating) ...[
            // REQ-008: Use Sage Green for primary icon
            Icon(Icons.self_improvement_outlined, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 20),
            Text('Meditation Timer',
                style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary)), // REQ-008: Sage Green title
            const SizedBox(height: 10),
            Text('Choose your meditation duration',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                )),
            const SizedBox(height: 40),
            Text('$_selectedDuration minutes',
                style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground)), // REQ-008: Charcoal text
            const SizedBox(height: 20),
            Slider(
              value: _selectedDuration.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: '$_selectedDuration minutes',
              onChanged: (value) =>
                  setState(() => _selectedDuration = value.toInt()),
              activeColor: theme.colorScheme.primary, // REQ-008: Sage Green slider
            ),
            const SizedBox(height: 40),
            // REQ-008: Button uses theme elevated button style (Sage Green)
            ElevatedButton(
              onPressed: _startMeditation,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('Start Meditation',
                  style: TextStyle(fontSize: 18)),
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
                    // REQ-008: Muted green/sand background for the track
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.15), 
                    // REQ-008: Sage Green progress
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
                Column(
                  children: [
                    Text(_formatTime(_remainingSeconds),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        )),
                    Text('minutes remaining',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.6),
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text('Focus on your breath...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onBackground,
                )),
            const SizedBox(height: 40),
            // Red is retained for this action as it's a stopping/warning action
            ElevatedButton(
              onPressed: _stopMeditation,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400, 
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
              child: const Text('End Session'),
            ),
          ],
        ],
      ),
    );
  }
}

// Progress Tab - Refactored for REQ-008
class ProgressTab extends StatelessWidget {
  final int totalMinutes;
  final User user;

  const ProgressTab({super.key, required this.totalMinutes, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Summary Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface, // REQ-008: Off-White Surface
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // REQ-008: Soft, subtle shadow
                  color: theme.colorScheme.primary.withOpacity(0.1), 
                  blurRadius: 8
                )
              ],
            ),
            child: Column(
              children: [
                Text('Your Mindfulness Journey',
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground)), // Charcoal Text
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                        context, 'Total Minutes', '$totalMinutes', Icons.timer_outlined),
                    _buildStatItem(context, 'Sessions', '${(totalMinutes / 5).ceil()}',
                        Icons.self_improvement_outlined),
                    _buildStatItem(context,
                        'Current Streak', '1 day', Icons.local_fire_department),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: theme.colorScheme.onBackground.withOpacity(0.2)),
                const SizedBox(height: 8),
                Text(
                  'Account Created: ${_formatDate(user.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                Text(
                  'Last Login: ${_formatDate(user.lastLogin)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Achievement/Goal Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.background, // REQ-008: Sand/Beige background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)), // Soft Sage Border
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_outlined, color: Colors.amber[700], size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Great Start!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          )),
                      Text(
                        totalMinutes == 0
                            ? 'Start your first meditation session to begin your journey!'
                            : 'You\'ve meditated for $totalMinutes minutes. Keep going!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Recent Activity Section
          Text('Recent Activity',
              style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground)), // Charcoal Text
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildActivityItem(
                    context, 'Morning Meditation', '5 min', 'Today, 8:00 AM'),
                _buildActivityItem(
                    context, 'Focus Session', '10 min', 'Yesterday, 7:30 PM'),
                if (totalMinutes == 0) ...[
                  _buildActivityItem(
                      context, 'Evening Relaxation', '15 min', 'Nov 8, 6:00 PM'),
                  _buildActivityItem(
                      context, 'Breathing Exercise', '8 min', 'Nov 7, 9:00 AM'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  // Helper method for stats updated for REQ-008
  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 30, color: theme.colorScheme.primary), // REQ-008: Sage Green Icon
        const SizedBox(height: 8),
        Text(value,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, 
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.6)
          )
        ),
      ],
    );
  }

  // Helper method for activity list updated for REQ-008
  Widget _buildActivityItem(BuildContext context, String title, String duration, String time) {
    final theme = Theme.of(context);
    return Card(
      // Inherits theme styling (Off-White, minimal elevation)
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.self_improvement_outlined, color: theme.colorScheme.primary), // Sage Green
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: Text(duration),
        trailing:
            Text(time, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.5))),
      ),
    );
  }
}