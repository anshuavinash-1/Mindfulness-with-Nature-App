import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage>
    with TickerProviderStateMixin {
  // Activities list - shown as pills
  final List<Map<String, dynamic>> activities = [
    {
      "name": "Being Present",
      "icon": Icons.self_improvement,
      "color": Color(0xFF6B9080),
    },
    {"name": "Feeling Lighter", "icon": Icons.air, "color": Color(0xFFA4C3B2)},
    {
      "name": "Connecting with Nature",
      "icon": Icons.nature_people,
      "color": Color(0xFF88AB8E),
    },
    {"name": "Grattitude", "icon": Icons.favorite, "color": Color(0xFFEAB8A3)},
    {
      "name": "Gentle Movements",
      "icon": Icons.accessibility_new,
      "color": Color(0xFFB8A99A),
    },
    {
      "name": "Feeling Grounded",
      "icon": Icons.landscape,
      "color": Color(0xFF8D9B6A),
    },
    {"name": "Joyfulness", "icon": Icons.wb_sunny, "color": Color(0xFFFFD89C)},
    {
      "name": "Playfulness",
      "icon": Icons.celebration,
      "color": Color(0xFFB5C99A),
    },
    {
      "name": "Practice Indoors",
      "icon": Icons.home,
      "color": Color(0xFF9DB4AB),
    },
  ];

  String? selectedActivity;

  // Slider state - 5 to 60 minutes
  double duration = 5;
  Timer? timer;
  int remainingSeconds = 300;
  bool isSessionActive = false;
  bool showCompletionFeedback = false;

  late AnimationController _breatheController;
  late AnimationController _pulseController;
  late Animation<double> _breatheAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    remainingSeconds = (duration * 60).toInt();

    _breatheController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
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
    setState(() {
      isSessionActive = false;
      showCompletionFeedback = true;
    });
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: false,
      builder: (_) => _buildCompletionDialog(),
    );
  }

  Widget _buildCompletionDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF3B2F2F),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Color(0xFF8B7355)),
            const SizedBox(height: 20),
            const Text(
              'Session Complete! 🌿',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (selectedActivity != null)
              Text(
                selectedActivity!,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            const SizedBox(height: 8),
            Text(
              '${duration.toInt()} minutes of mindfulness',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/mood');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D2B1F),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Log Mood',
                      style: TextStyle(color: Colors.white),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  String formatTime(int sec) {
    final min = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return "$min:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6CBC0),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Activities",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A6FA5),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "What brings you peace today?",
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF4A6FA5).withOpacity(0.85),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Activity Pills - Wrap layout like the image
              _buildActivityPills(),

              const SizedBox(height: 36),

              // Duration Section
              _buildDurationSection(),

              const SizedBox(height: 28),

              // Timer / Hourglass Display
              _buildTimerDisplay(),

              const SizedBox(height: 24),

              // Slider
              _buildSlider(),

              const SizedBox(height: 32),

              // Start Session Button
              _buildStartButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityPills() {
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: activities.map((activity) {
        final name = activity['name'] as String;
        final isSelected = selectedActivity == name;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedActivity = name;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF3D2B1F)
                  : const Color(0xFFEBE3D8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF3D2B1F)
                    : const Color(0xFFCCC0B0),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF3D2B1F).withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF3D2B1F),
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Duration",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A6FA5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${duration.toInt()} Minutes",
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4A6FA5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerDisplay() {
    return Center(
      child: AnimatedBuilder(
        animation: isSessionActive
            ? _breatheAnimation
            : const AlwaysStoppedAnimation(1.0),
        builder: (context, child) {
          return Transform.scale(
            scale: _breatheAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (isSessionActive)
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Text(
                        formatTime(remainingSeconds),
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D2B1F),
                          letterSpacing: 3,
                        ),
                      ),
                    )
                  else
                    // Hourglass icon like the image
                    Icon(
                      Icons.hourglass_bottom,
                      size: 90,
                      color: const Color(0xFF3D2B1F).withOpacity(0.85),
                    ),
                  if (isSessionActive) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Breathe... Relax...',
                      style: TextStyle(
                        color: const Color(0xFF3D2B1F).withOpacity(0.6),
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlider() {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF3D2B1F),
            inactiveTrackColor: const Color(0xFFBFB2A3),
            thumbColor: const Color(0xFFEBE3D8),
            overlayColor: const Color(0xFF3D2B1F).withOpacity(0.15),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            trackHeight: 3,
          ),
          child: Slider(
            value: duration,
            min: 5,
            max: 60,
            divisions: 11,
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "5 MINS",
                style: TextStyle(
                  color: Color(0xFF3D2B1F),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                "60 MINS",
                style: TextStyle(
                  color: Color(0xFF3D2B1F),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    if (isSessionActive) {
      return GestureDetector(
        onTap: stopSession,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF8B3A3A),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B3A3A).withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "End Session",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );
    }

    if (showCompletionFeedback) {
      return GestureDetector(
        onTap: () {
          setState(() {
            showCompletionFeedback = false;
            selectedActivity = null;
            duration = 5;
            remainingSeconds = 300;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF3D2B1F),
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Center(
            child: Text(
              "Start New Session",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: selectedActivity != null ? startSession : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selectedActivity != null
              ? const Color(0xFF3D2B1F)
              : const Color(0xFF3D2B1F).withOpacity(0.45),
          borderRadius: BorderRadius.circular(40),
          boxShadow: selectedActivity != null
              ? [
                  BoxShadow(
                    color: const Color(0xFF3D2B1F).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            selectedActivity != null
                ? "Start Session"
                : "Select an activity first",
            style: TextStyle(
              color: Colors.white.withOpacity(
                selectedActivity != null ? 1.0 : 0.7,
              ),
              fontSize: selectedActivity != null ? 20 : 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
