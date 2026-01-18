import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/positive_feedback.dart';
import '../utils/feedback_utils.dart';
import 'dart:ui';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage>
    with TickerProviderStateMixin {
  // Activities list with icons
  final List<Map<String, dynamic>> activities = [
    {"name": "Being Present", "icon": Icons.self_improvement, "color": Color(0xFF6B9080)},
    {"name": "Feeling Lighter", "icon": Icons.air, "color": Color(0xFFA4C3B2)},
    {"name": "Connecting with Nature", "icon": Icons.nature_people, "color": Color(0xFF88AB8E)},
    {"name": "Gratitude", "icon": Icons.favorite, "color": Color(0xFFEAB8A3)},
    {"name": "Gentle Movements", "icon": Icons.accessibility_new, "color": Color(0xFFB8A99A)},
    {"name": "Feeling Grounded", "icon": Icons.landscape, "color": Color(0xFF8D9B6A)},
    {"name": "Joyfulness", "icon": Icons.wb_sunny, "color": Color(0xFFFFD89C)},
    {"name": "Playfulness", "icon": Icons.celebration, "color": Color(0xFFB5C99A)},
    {"name": "Practice Indoors", "icon": Icons.home, "color": Color(0xFF9DB4AB)},
  ];

  String? selectedActivity;
  Color? selectedColor;

  // Slider state
  double duration = 10; // default 10 minutes
  Timer? timer;
  int remainingSeconds = 600;
  bool isSessionActive = false;
  bool showCompletionFeedback = false;

  // Animation controllers
  late AnimationController _breatheController;
  late AnimationController _pulseController;
  late Animation<double> _breatheAnimation;
  late Animation<double> _pulseAnimation;

  final Random _random = Random();
  FeedbackType? _lastFeedbackType;

  @override
  void initState() {
    super.initState();
    remainingSeconds = (duration * 60).toInt();

    // Breathing animation for active session
    _breatheController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    // Pulse animation for timer
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _breatheController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void startSession() {
    setState(() {
      isSessionActive = true;
      showCompletionFeedback = false;
      remainingSeconds = (duration * 60).toInt();
    });

    timer?.cancel();
    _breatheController.repeat(reverse: true);

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (remainingSeconds <= 0) {
        timer?.cancel();
        _breatheController.stop();
        _onSessionComplete();
      } else {
        setState(() {
          remainingSeconds--;
        });

        // Pulse every second
        _pulseController.forward().then((_) => _pulseController.reverse());
      }
    });
  }

  void stopSession() {
    timer?.cancel();
    _breatheController.stop();
    setState(() {
      isSessionActive = false;
    });
  }

  void _onSessionComplete() {
    final types = FeedbackType.values
        .where((type) => type != FeedbackType.random)
        .toList();
    _lastFeedbackType = types[_random.nextInt(types.length)];

    setState(() {
      isSessionActive = false;
      showCompletionFeedback = true;
    });

    _showCompletionFeedback();
    _saveSessionData();
  }

  void _showCompletionFeedback() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => const FullScreenNatureAnimation(),
    );

    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      Navigator.of(context).pop();

      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.6),
        barrierDismissible: false,
        builder: (_) => _buildCompletionDialog(),
      );
    });
  }

  Widget _buildCompletionDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A4D2E).withOpacity(0.95),
              const Color(0xFF0F2922).withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated checkmark
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50),
                    const Color(0xFF45A049),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Session Complete! 🌿',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            if (selectedActivity != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: selectedColor?.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  selectedActivity!,
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Text(
              '${duration.toInt()} minutes of mindfulness',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToMoodPage();
                    },
                    icon: const Icon(Icons.mood, size: 20),
                    label: const Text('Log Mood'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        showCompletionFeedback = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.white54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveSessionData() {
    debugPrint('Session saved: $selectedActivity for $duration minutes');
  }

  void _navigateToMoodPage() {
    Navigator.pushNamed(context, '/mood');
  }

  String formatTime(int sec) {
    final min = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return "$min:$s";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE8F5E9),
              const Color(0xFFC8E6C9),
              const Color(0xFFA5D6A7),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Header with icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.spa,
                        color: Color(0xFF2E7D32),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Mindful Activities",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  "What brings you peace today?",
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFF2E7D32).withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 32),

                // Activity Cards Grid
                _buildActivityGrid(),

                const SizedBox(height: 40),

                // Duration Section
                _buildDurationSection(),

                const SizedBox(height: 32),

                // Timer Display
                _buildTimerDisplay(size),

                const SizedBox(height: 32),

                // Control Buttons
                _buildControlButtons(size),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isSelected = selectedActivity == activity['name'];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedActivity = activity['name'];
              selectedColor = activity['color'];
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  activity['color'],
                  activity['color'].withOpacity(0.7),
                ],
              )
                  : null,
              color: isSelected ? null : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withOpacity(0.6)
                    : activity['color'].withOpacity(0.3),
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: activity['color'].withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  activity['icon'],
                  size: 36,
                  color: isSelected ? Colors.white : activity['color'],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    activity['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDurationSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.schedule,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                "Session Duration",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${duration.toInt()} minutes",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: selectedColor ?? const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: selectedColor ?? const Color(0xFF4CAF50),
              inactiveTrackColor: const Color(0xFF81C784).withOpacity(0.3),
              thumbColor: selectedColor ?? const Color(0xFF2E7D32),
              overlayColor: (selectedColor ?? const Color(0xFF4CAF50)).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 6,
            ),
            child: Slider(
              value: duration,
              min: 2 / 60,
              max: 45,
              onChanged: isSessionActive
                  ? null
                  : (value) {
                setState(() {
                  duration = value;
                  remainingSeconds = (duration * 60).toInt();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "2 SEC",
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "45 MIN",
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(Size size) {
    return AnimatedBuilder(
      animation: isSessionActive ? _breatheAnimation : const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheAnimation.value,
          child: Container(
            width: size.width * 0.85,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSessionActive
                    ? [
                  selectedColor?.withOpacity(0.3) ?? const Color(0xFF81C784).withOpacity(0.3),
                  selectedColor?.withOpacity(0.1) ?? const Color(0xFFA5D6A7).withOpacity(0.1),
                ]
                    : [
                  Colors.white.withOpacity(0.7),
                  Colors.white.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSessionActive
                    ? (selectedColor ?? const Color(0xFF4CAF50))
                    : Colors.white.withOpacity(0.5),
                width: 3,
              ),
              boxShadow: [
                if (isSessionActive)
                  BoxShadow(
                    color: (selectedColor ?? const Color(0xFF4CAF50)).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
              ],
            ),
            child: Column(
              children: [
                if (isSessionActive && remainingSeconds > 0)
                  Icon(
                    Icons.self_improvement,
                    size: 80,
                    color: selectedColor ?? const Color(0xFF4CAF50),
                  )
                else if (showCompletionFeedback)
                  const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Color(0xFF4CAF50),
                  )
                else
                  Icon(
                    Icons.timer,
                    size: 80,
                    color: const Color(0xFF2E7D32).withOpacity(0.6),
                  ),

                const SizedBox(height: 16),

                ScaleTransition(
                  scale: isSessionActive ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                  child: Text(
                    formatTime(remainingSeconds),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: isSessionActive
                          ? (selectedColor ?? const Color(0xFF2E7D32))
                          : const Color(0xFF2E7D32).withOpacity(0.7),
                      letterSpacing: 2,
                    ),
                  ),
                ),

                if (isSessionActive) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (selectedColor ?? const Color(0xFF4CAF50)).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Breathe... Relax... Let go...',
                      style: TextStyle(
                        color: selectedColor ?? const Color(0xFF2E7D32),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButtons(Size size) {
    if (!isSessionActive && !showCompletionFeedback) {
      return _buildStartButton(size);
    } else if (isSessionActive) {
      return _buildStopButton(size);
    } else {
      return _buildNewSessionButton(size);
    }
  }

  Widget _buildStartButton(Size size) {
    final canStart = selectedActivity != null;

    return Column(
      children: [
        GestureDetector(
          onTap: canStart ? startSession : null,
          child: Container(
            width: size.width * 0.85,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: canStart
                  ? LinearGradient(
                colors: [
                  selectedColor ?? const Color(0xFF4CAF50),
                  (selectedColor ?? const Color(0xFF4CAF50)).withOpacity(0.7),
                ],
              )
                  : null,
              color: canStart ? null : const Color(0xFF81C784).withOpacity(0.3),
              borderRadius: BorderRadius.circular(30),
              boxShadow: canStart
                  ? [
                BoxShadow(
                  color: (selectedColor ?? const Color(0xFF4CAF50)).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_filled,
                  color: canStart ? Colors.white : Colors.white70,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  canStart ? "Begin Session" : "Select an activity first",
                  style: TextStyle(
                    color: canStart ? Colors.white : Colors.white70,
                    fontSize: canStart ? 22 : 18,
                    fontWeight: canStart ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!canStart) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.touch_app, color: Color(0xFF2E7D32), size: 16),
              SizedBox(width: 8),
              Text(
                "Tap an activity above to continue",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStopButton(Size size) {
    return Column(
      children: [
        GestureDetector(
          onTap: stopSession,
          child: Container(
            width: size.width * 0.85,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE57373), Color(0xFFEF5350)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE57373).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.stop_circle, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  "End Session",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: (selectedColor ?? const Color(0xFF4CAF50)).withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: (selectedColor ?? const Color(0xFF4CAF50)).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite,
                color: selectedColor ?? const Color(0xFF2E7D32),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Practicing: $selectedActivity',
                style: TextStyle(
                  color: selectedColor ?? const Color(0xFF2E7D32),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewSessionButton(Size size) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              showCompletionFeedback = false;
              selectedActivity = null;
              selectedColor = null;
              duration = 10;
              remainingSeconds = 600;
            });
          },
          child: Container(
            width: size.width * 0.85,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.refresh, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  "Start New Session",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.celebration, color: Color(0xFF4CAF50), size: 24),
              SizedBox(width: 12),
              Text(
                'Wonderful! You completed your practice',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Full-screen nature animation (keeping your existing one)
class FullScreenNatureAnimation extends StatefulWidget {
  const FullScreenNatureAnimation({super.key});

  @override
  State<FullScreenNatureAnimation> createState() =>
      _FullScreenNatureAnimationState();
}

class _FullScreenNatureAnimationState extends State<FullScreenNatureAnimation>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<AnimatedElement> _birds = [];
  final List<AnimatedElement> _leaves = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _generateElements();

    Future.delayed(const Duration(milliseconds: 6200), () {
      if (mounted) {
        _fadeController.reverse();
      }
    });
  }

  void _generateElements() {
    for (int i = 0; i < 6; i++) {
      _birds.add(AnimatedElement(
        controller: AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 3000 + _random.nextInt(2000)),
        )..repeat(),
        startX: _random.nextDouble(),
        startY: _random.nextDouble() * 0.4,
        endX: _random.nextDouble(),
        endY: _random.nextDouble() * 0.4 + 0.1,
      ));
    }

    for (int i = 0; i < 18; i++) {
      _leaves.add(AnimatedElement(
          controller: AnimationController(
              vsync: this,
              duration: Duration(milliseconds: 2500 + _random.nextInt(2500)),
          )..repeat(),
        startX: _random.nextDouble(),
        startY: -0.1,
        endX: _random.nextDouble(),
        endY: 1.1,
        rotation: _random.nextDouble() * 6.28,
      ));
    }
  }
  @override
  void dispose() {
    _fadeController.dispose();
    for (var bird in _birds) {
      bird.controller.dispose();
    }
    for (var leaf in _leaves) {
      leaf.controller.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: size.width,
          height: size.height,
          color: Colors.black.withOpacity(0.2),
          child: Stack(
            children: [
              ..._leaves.map((leaf) => _buildLeaf(leaf, size)),
              ..._birds.map((bird) => _buildBird(bird, size)),
            ],
          ),
        ),
      ),
    );}
  Widget _buildBird(AnimatedElement bird, Size size) {
    return AnimatedBuilder(
        animation: bird.controller,
        builder: (context, child) {
          final progress = bird.controller.value;
          final curvedProgress = Curves.easeInOut.transform(progress);
          final rotationProgress = sin(progress * 2 * pi) * 0.5;
          final drift = sin(progress * 3 * pi) * 0.08;
          return Positioned(
            left: size.width * (bird.startX + (bird.endX - bird.startX) * curvedProgress + drift),
            top: size.height * (bird.startY + (bird.endY - bird.startY) * curvedProgress),
            child: Transform.rotate(
              angle: bird.rotation + rotationProgress,
              child: Icon(
                Icons.eco,
                size: 44 + _random.nextDouble() * 16,
                color: Colors.green.shade300.withOpacity(0.6 + _random.nextDouble() * 0.4),
              ),
            ),
          );
        },
    );
  }
  Widget _buildLeaf(AnimatedElement leaf, Size size) {
    return AnimatedBuilder(
        animation: leaf.controller,
        builder: (context, child) {
          final progress = leaf.controller.value;
          final curvedProgress = Curves.easeInOut.transform(progress);
          final verticalWave = sin(progress * 3 * pi) * 0.03;return Positioned(
            left: size.width * (leaf.startX + (leaf.endX - leaf.startX) * curvedProgress),
            top: size.height * (leaf.startY + (leaf.endY - leaf.startY) * curvedProgress + verticalWave),
            child: Transform.rotate(
              angle: (leaf.endX - leaf.startX) * 0.3 + sin(progress * 4 * pi) * 0.1,
              child: Text(
                '🌿',
                style: TextStyle(
                  fontSize: 48 + _random.nextDouble() * 12,
                ),
              ),
            ),
          );
        },
    );
  }
}

class AnimatedElement {
  final AnimationController controller;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double rotation;
  AnimatedElement({
    required this.controller,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    this.rotation = 0,
  });
}