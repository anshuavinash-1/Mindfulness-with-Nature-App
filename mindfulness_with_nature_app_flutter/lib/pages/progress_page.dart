import 'package:flutter/material.dart';
import '../widgets/positive_feedback.dart';
import '../utils/feedback_utils.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  // Sample progress data
  final List<Map<String, dynamic>> achievements = [
    {'title': 'First Session', 'completed': true, 'type': 'leaf'},
    {'title': '7-Day Streak', 'completed': false, 'type': 'sun'},
    {'title': 'Nature Explorer', 'completed': true, 'type': 'flower'},
    {'title': 'Mindful Week', 'completed': false, 'type': 'bird'},
    {'title': 'Deep Focus', 'completed': true, 'type': 'ripple'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdde3c2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Progress",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374834),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Celebrate your mindfulness journey",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF374834),
                ),
              ),
              const SizedBox(height: 30),
              
              // Achievements section
              const Text(
                "Achievements",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374834),
                ),
              ),
              const SizedBox(height: 20),
              
              // Achievement cards with micro-interactions
              ...achievements.map((achievement) {
                return _buildAchievementCard(achievement, context);
              }).toList(),
              
              const SizedBox(height: 30),
              
              // Test button for micro-interactions
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Test different feedback types
                    final types = FeedbackType.values
                        .where((type) => type != FeedbackType.random)
                        .toList();
                    final randomType = types[DateTime.now().millisecond % types.length];
                    
                    FeedbackUtils.showPositiveFeedback(
                      context,
                      type: randomType,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Test Micro-interaction',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAchievementCard(
    Map<String, dynamic> achievement,
    BuildContext context,
  ) {
    bool completed = achievement['completed'] as bool;
    String type = achievement['type'] as String;
    
    return GestureDetector(
      onTap: completed ? () {
        // Show micro-interaction when tapping completed achievements
        _showAchievementFeedback(type, context);
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xfff3f0d8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: completed 
                ? const Color(0xFF4CAF50) 
                : const Color(0xFF374834).withOpacity(0.3),
            width: completed ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Achievement icon with potential animation
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: completed 
                    ? const Color(0xFF4CAF50).withOpacity(0.2)
                    : const Color(0xFF374834).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _getAchievementIcon(type, completed: completed),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: completed 
                          ? const Color(0xFF374834)
                          : const Color(0xFF374834).withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    completed ? 'Completed! 🎉' : 'Keep going...',
                    style: TextStyle(
                      fontSize: 14,
                      color: completed 
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF374834).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              completed ? Icons.check_circle : Icons.circle_outlined,
              color: completed 
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF374834).withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _getAchievementIcon(String type, {required bool completed}) {
    switch (type) {
      case 'leaf':
        return Icon(
          Icons.eco,
          color: completed 
              ? const Color(0xFF4CAF50)
              : const Color(0xFF374834).withOpacity(0.5),
          size: 30,
        );
      case 'sun':
        return Icon(
          Icons.wb_sunny,
          color: completed 
              ? Colors.amber
              : const Color(0xFF374834).withOpacity(0.5),
          size: 30,
        );
      case 'flower':
        return Icon(
          Icons.local_florist,
          color: completed 
              ? const Color(0xFFE91E63)
              : const Color(0xFF374834).withOpacity(0.5),
          size: 30,
        );
      case 'bird':
        return Icon(
          Icons.flight,
          color: completed 
              ? const Color(0xFF03A9F4)
              : const Color(0xFF374834).withOpacity(0.5),
          size: 30,
        );
      case 'ripple':
        return Icon(
          Icons.waves,
          color: completed 
              ? const Color(0xFF00BCD4)
              : const Color(0xFF374834).withOpacity(0.5),
          size: 30,
        );
      default:
        return Icon(
          Icons.emoji_events,
          color: completed 
              ? const Color(0xFFFFC107)
              : const Color(0xFF374834).withOpacity(0.5),
          size: 30,
        );
    }
  }
  
  void _showAchievementFeedback(String type, BuildContext context) {
    FeedbackType feedbackType;
    
    switch (type) {
      case 'leaf': feedbackType = FeedbackType.leaf; break;
      case 'sun': feedbackType = FeedbackType.sun; break;
      case 'flower': feedbackType = FeedbackType.flower; break;
      case 'bird': feedbackType = FeedbackType.bird; break;
      case 'ripple': feedbackType = FeedbackType.ripple; break;
      default: feedbackType = FeedbackType.sparkle;
    }
    
    FeedbackUtils.showPositiveFeedback(
      context,
      type: feedbackType,
      size: 100,
      duration: const Duration(seconds: 1),
    );
  }
}