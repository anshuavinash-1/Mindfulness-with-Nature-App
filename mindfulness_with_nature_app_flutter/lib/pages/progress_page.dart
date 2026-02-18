import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../widgets/positive_feedback.dart';
import '../utils/feedback_utils.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _scaleController;
  bool _showCelebration = true;

  // Sample progress data
  final List<Map<String, dynamic>> achievements = [
    {'title': 'First Session', 'completed': true, 'type': 'leaf'},
    {'title': '7-Day Streak', 'completed': false, 'type': 'sun'},
    {'title': 'Nature Explorer', 'completed': true, 'type': 'flower'},
    {'title': 'Mindful Week', 'completed': false, 'type': 'bird'},
    {'title': 'Deep Focus', 'completed': true, 'type': 'ripple'},
  ];

  @override
  void initState() {
    super.initState();

    // Main celebration animation controller
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Scale animation for the center ring
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Start celebration animation when page opens
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _celebrationController.forward();
        _scaleController.forward();

        // Hide celebration after animation completes
        Future.delayed(const Duration(milliseconds: 3500), () {
          if (mounted) {
            setState(() {
              _showCelebration = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdde3c2),
      body: Stack(
        children: [
          SafeArea(
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
                        setState(() {
                          _showCelebration = true;
                          _celebrationController.reset();
                          _scaleController.reset();
                          _celebrationController.forward();
                          _scaleController.forward();

                          Future.delayed(const Duration(milliseconds: 3500),
                              () {
                            if (mounted) {
                              setState(() {
                                _showCelebration = false;
                              });
                            }
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF556B2F),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        'Replay Celebration',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Celebration overlay with blur
          if (_showCelebration) ...[
            // Blur background
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10,
                sigmaY: 10,
              ),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),

            // Celebration animation
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _celebrationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: CelebrationPainter(
                      animation: _celebrationController,
                      scaleAnimation: _scaleController,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ],
        ],
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
      onTap: completed
          ? () {
              // Show micro-interaction when tapping completed achievements
              _showAchievementFeedback(type, context);
            }
          : null,
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
      case 'leaf':
        feedbackType = FeedbackType.leaf;
        break;
      case 'sun':
        feedbackType = FeedbackType.sun;
        break;
      case 'flower':
        feedbackType = FeedbackType.flower;
        break;
      case 'bird':
        feedbackType = FeedbackType.bird;
        break;
      case 'ripple':
        feedbackType = FeedbackType.ripple;
        break;
      default:
        feedbackType = FeedbackType.sparkle;
    }

    FeedbackUtils.showPositiveFeedback(
      context,
      type: feedbackType,
      size: 100,
      duration: const Duration(seconds: 1),
    );
  }
}

// Particle class for natural elements
class NatureParticle {
  Offset position;
  Offset velocity;
  double rotation;
  double rotationSpeed;
  double size;
  Color color;
  String type; // 'leaf', 'drop', 'flower', 'petal'
  double opacity;

  NatureParticle({
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.type,
    this.opacity = 1.0,
  });
}

class CelebrationPainter extends CustomPainter {
  final Animation<double> animation;
  final Animation<double> scaleAnimation;
  final List<NatureParticle> particles = [];
  final math.Random random = math.Random();

  CelebrationPainter({
    required this.animation,
    required this.scaleAnimation,
  }) {
    _initializeParticles();
  }

  void _initializeParticles() {
    // Create various natural particles - increased count for more impact
    for (int i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * math.pi;
      final speed = 150 + random.nextDouble() * 200;

      final types = ['leaf', 'drop', 'flower', 'petal', 'seed'];
      final type = types[random.nextInt(types.length)];

      Color color;
      switch (type) {
        case 'leaf':
          color = Color.lerp(
            const Color(0xFF4CAF50),
            const Color(0xFF66BB6A),
            random.nextDouble(),
          )!;
          break;
        case 'drop':
          color = Color.lerp(
            const Color(0xFF42A5F5),
            const Color(0xFF90CAF9),
            random.nextDouble(),
          )!;
          break;
        case 'flower':
          color = Color.lerp(
            const Color(0xFFEC407A),
            const Color(0xFFF48FB1),
            random.nextDouble(),
          )!;
          break;
        case 'petal':
          color = Color.lerp(
            const Color(0xFFFFA726),
            const Color(0xFFFFD54F),
            random.nextDouble(),
          )!;
          break;
        default:
          color = Color.lerp(
            const Color(0xFFA1887F),
            const Color(0xFFBCAAA4),
            random.nextDouble(),
          )!;
      }

      particles.add(NatureParticle(
        position: const Offset(0, 0),
        velocity: Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        ),
        rotation: random.nextDouble() * 2 * math.pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 5,
        size: 12 + random.nextDouble() * 16, // Larger particles
        color: color,
        type: type,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final progress = animation.value;
    final scaleProgress = scaleAnimation.value;

    // Draw expanding rings (Apple Watch style)
    _drawExpandingRings(canvas, center, scaleProgress);

    // Draw particles
    for (var particle in particles) {
      final t = progress;

      // Calculate particle position with gravity and deceleration
      final dx = particle.velocity.dx * t * (1 - t * 0.3);
      final dy =
          particle.velocity.dy * t * (1 - t * 0.3) + (t * t * 200); // gravity

      final particlePos = center + Offset(dx, dy);
      final rotation = particle.rotation + particle.rotationSpeed * t * math.pi;

      // Fade out particles
      final opacity = (1 - t).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(particlePos.dx, particlePos.dy);
      canvas.rotate(rotation);

      _drawParticle(
        canvas,
        particle.type,
        particle.size,
        particle.color.withOpacity(opacity),
      );

      canvas.restore();
    }

    // Draw center glow effect - much more prominent
    if (scaleProgress < 0.7) {
      final glowProgress = (scaleProgress / 0.7).clamp(0.0, 1.0);

      // Multiple glow layers for intensity
      for (int i = 0; i < 3; i++) {
        final glowPaint = Paint()
          ..color = const Color(0xFF4CAF50)
              .withOpacity((0.5 - i * 0.15) * (1 - glowProgress))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30.0 + i * 10);

        canvas.drawCircle(
          center,
          80 * glowProgress + i * 20,
          glowPaint,
        );
      }

      // Bright center point
      final centerPaint = Paint()
        ..color = Colors.white.withOpacity(0.9 * (1 - glowProgress))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(center, 25, centerPaint);
    }
  }

  void _drawExpandingRings(Canvas canvas, Offset center, double progress) {
    // Draw multiple expanding rings with different delays
    for (int i = 0; i < 4; i++) {
      final delay = i * 0.1;
      final ringProgress = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);

      if (ringProgress > 0) {
        final radius = 50 + (ringProgress * 250);
        final opacity = (1 - ringProgress) * 0.7;

        final paint = Paint()
          ..color = const Color(0xFF4CAF50).withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4 - (i * 0.5);

        canvas.drawCircle(center, radius, paint);

        // Add inner glow to rings
        final glowPaint = Paint()
          ..color = const Color(0xFF81C784).withOpacity(opacity * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0 - i
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        canvas.drawCircle(center, radius, glowPaint);

        // Add nature elements around the rings
        _drawRingNatureElements(
            canvas, center, radius, ringProgress, opacity, i);
      }
    }
  }

  void _drawParticle(Canvas canvas, String type, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (type) {
      case 'leaf':
        _drawLeaf(canvas, size, paint);
        break;
      case 'drop':
        _drawWaterDrop(canvas, size, paint);
        break;
      case 'flower':
        _drawFlower(canvas, size, paint);
        break;
      case 'petal':
        _drawPetal(canvas, size, paint);
        break;
      case 'seed':
        _drawSeed(canvas, size, paint);
        break;
    }
  }

  void _drawLeaf(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(0, -size / 2);
    path.quadraticBezierTo(size / 2, -size / 4, size / 3, size / 2);
    path.quadraticBezierTo(0, size / 3, 0, -size / 2);
    path.quadraticBezierTo(-size / 2, -size / 4, -size / 3, size / 2);
    path.quadraticBezierTo(0, size / 3, 0, -size / 2);
    canvas.drawPath(path, paint);

    // Leaf vein
    final veinPaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, -size / 2),
      Offset(0, size / 2),
      veinPaint,
    );
  }

  void _drawWaterDrop(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(0, -size / 2);
    path.quadraticBezierTo(size / 2, 0, 0, size / 2);
    path.quadraticBezierTo(-size / 2, 0, 0, -size / 2);
    canvas.drawPath(path, paint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(paint.color.opacity * 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(-size / 6, -size / 6),
      size / 6,
      highlightPaint,
    );
  }

  void _drawFlower(Canvas canvas, double size, Paint paint) {
    // Draw 5 petals
    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate((i * 2 * math.pi) / 5);

      final path = Path();
      path.moveTo(0, 0);
      path.quadraticBezierTo(size / 4, -size / 3, 0, -size / 2);
      path.quadraticBezierTo(-size / 4, -size / 3, 0, 0);
      canvas.drawPath(path, paint);

      canvas.restore();
    }

    // Center
    final centerPaint = Paint()
      ..color = Colors.amber.withOpacity(paint.color.opacity);
    canvas.drawCircle(Offset.zero, size / 5, centerPaint);
  }

  void _drawPetal(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size / 3, -size / 4, size / 2, -size / 3);
    path.quadraticBezierTo(size / 2, 0, 0, size / 4);
    path.quadraticBezierTo(-size / 2, 0, -size / 2, -size / 3);
    path.quadraticBezierTo(-size / 3, -size / 4, 0, 0);
    canvas.drawPath(path, paint);
  }

  void _drawSeed(Canvas canvas, double size, Paint paint) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: size / 2, height: size),
      Radius.circular(size / 4),
    );
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(CelebrationPainter oldDelegate) => true;
  void _drawRingNatureElements(Canvas canvas, Offset center, double radius,
      double progress, double opacity, int ringIndex) {
    // Number of elements per ring
    final elementCount = 12 + (ringIndex * 4);

    for (int j = 0; j < elementCount; j++) {
      final angle = (j / elementCount) * 2 * math.pi;
      final elementPos = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      // Rotate elements as they expand
      final rotation = angle + progress * math.pi;

      canvas.save();
      canvas.translate(elementPos.dx, elementPos.dy);
      canvas.rotate(rotation);

      // Choose element type based on position
      final elementTypes = ['mini_leaf', 'mini_drop', 'sparkle', 'dot'];
      final type = elementTypes[j % elementTypes.length];

      // Size varies based on ring
      final size = 4.0 + (ringIndex * 1.5) - (progress * 2);

      _drawMiniElement(canvas, type, size, opacity);

      canvas.restore();
    }
  }
}

void _drawMiniElement(Canvas canvas, String type, double size, double opacity) {
  switch (type) {
    case 'mini_leaf':
      final leafPaint = Paint()
        ..color = const Color(0xFF4CAF50).withOpacity(opacity * 0.8)
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(0, -size);
      path.quadraticBezierTo(size * 0.6, -size * 0.3, 0, size);
      path.quadraticBezierTo(-size * 0.6, -size * 0.3, 0, -size);
      canvas.drawPath(path, leafPaint);
      break;

    case 'mini_drop':
      final dropPaint = Paint()
        ..color = const Color(0xFF2196F3).withOpacity(opacity * 0.8)
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(0, -size);
      path.quadraticBezierTo(size * 0.5, 0, 0, size);
      path.quadraticBezierTo(-size * 0.5, 0, 0, -size);
      canvas.drawPath(path, dropPaint);

      // Highlight
      final highlight = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.5);
      canvas.drawCircle(
          Offset(-size * 0.3, -size * 0.3), size * 0.3, highlight);
      break;

    case 'sparkle':
      final sparklePaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      // Draw sparkle as four lines
      canvas.drawLine(Offset(0, -size), Offset(0, size), sparklePaint);
      canvas.drawLine(Offset(-size, 0), Offset(size, 0), sparklePaint);
      canvas.drawLine(Offset(-size * 0.7, -size * 0.7),
          Offset(size * 0.7, size * 0.7), sparklePaint);
      canvas.drawLine(Offset(size * 0.7, -size * 0.7),
          Offset(-size * 0.7, size * 0.7), sparklePaint);
      break;

    case 'dot':
      final dotPaint = Paint()
        ..color = const Color(0xFFFFB74D).withOpacity(opacity * 0.9)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset.zero, size, dotPaint);

      // Inner glow
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.6);
      canvas.drawCircle(Offset.zero, size * 0.5, glowPaint);
      break;
  }
}
