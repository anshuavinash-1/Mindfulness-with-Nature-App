import 'dart:math';
import 'package:flutter/material.dart';

enum FeedbackType { leaf, bird, flower, sun, ripple, sparkle, random }

class PositiveFeedback extends StatefulWidget {
  final FeedbackType type;
  final VoidCallback? onComplete;
  final double size;

  const PositiveFeedback({
    Key? key,
    this.type = FeedbackType.random,
    this.onComplete,
    this.size = 150.0,
  }) : super(key: key);

  @override
  _PositiveFeedbackState createState() => _PositiveFeedbackState();
}

class _PositiveFeedbackState extends State<PositiveFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _floatAnimation;
  late Animation<double> _growthAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    // Growth animation: tracks the progression through stages
    _growthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Scale animation: 0 -> 1
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Opacity animation: 1 -> 0 (fade at the end)
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
    );

    // Floating animation: moves up
    _floatAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -100),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildGrowthStage(double growth, double size) {
    // Growth stages: 0-0.25: Seedling, 0.25-0.5: Sprout, 0.5-0.75: Leaf, 0.75-1.0: Flower

    if (growth < 0.25) {
      // Stage 1: Seedling (small green dot growing)
      return CustomPaint(
        painter: SeedlingPainter(
          progress: (growth / 0.25).clamp(0.0, 1.0),
          size: size,
        ),
      );
    } else if (growth < 0.5) {
      // Stage 2: Sprout (small leaves appearing)
      return CustomPaint(
        painter: SproutPainter(
          progress: ((growth - 0.25) / 0.25).clamp(0.0, 1.0),
          size: size,
        ),
      );
    } else if (growth < 0.75) {
      // Stage 3: Leaf (full leaf icon)
      return Icon(
        Icons.eco,
        color: Color.lerp(
          const Color(0xFF4CAF50),
          const Color(0xFF81C784),
          ((growth - 0.5) / 0.25),
        ),
        size: size,
      );
    } else {
      // Stage 4: Flower (transitions to flower)
      final flowerProgress = ((growth - 0.75) / 0.25).clamp(0.0, 1.0);
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.eco,
            color: Color.lerp(
              const Color(0xFF81C784),
              const Color(0xFFE91E63),
              flowerProgress,
            ),
            size: size * (1 - flowerProgress * 0.3),
          ),
          Icon(
            Icons.local_florist,
            color: Color.lerp(
              Colors.transparent,
              const Color(0xFFE91E63),
              flowerProgress,
            ),
            size: size * flowerProgress,
          ),
        ],
      );
    }
  }

  IconData _getIcon() {
    final type = widget.type == FeedbackType.random
        ? FeedbackType.values[Random().nextInt(FeedbackType.values.length - 1)]
        : widget.type;

    switch (type) {
      case FeedbackType.leaf:
        return Icons.eco;
      case FeedbackType.bird:
        return Icons.pets;
      case FeedbackType.flower:
        return Icons.local_florist;
      case FeedbackType.sun:
        return Icons.wb_sunny;
      case FeedbackType.ripple:
        return Icons.water_drop;
      case FeedbackType.sparkle:
        return Icons.star;
      case FeedbackType.random:
        return Icons.eco;
    }
  }

  Color _getColor() {
    final type = widget.type == FeedbackType.random
        ? FeedbackType.values[Random().nextInt(FeedbackType.values.length - 1)]
        : widget.type;

    switch (type) {
      case FeedbackType.leaf:
        return const Color(0xFF4CAF50);
      case FeedbackType.bird:
        return const Color(0xFF2196F3);
      case FeedbackType.flower:
        return const Color(0xFFE91E63);
      case FeedbackType.sun:
        return const Color(0xFFFFC107);
      case FeedbackType.ripple:
        return const Color(0xFF00BCD4);
      case FeedbackType.sparkle:
        return const Color(0xFFFF9800);
      case FeedbackType.random:
        return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _floatAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.type == FeedbackType.leaf
                  ? _buildGrowthStage(_growthAnimation.value, widget.size)
                  : Icon(
                      _getIcon(),
                      color: _getColor(),
                      size: widget.size,
                    ),
            ),
          ),
        );
      },
    );
  }
}

// Custom painter for seedling stage
class SeedlingPainter extends CustomPainter {
  final double progress;
  final double size;

  SeedlingPainter({required this.progress, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = Color.lerp(
        const Color(0xFF8B7355),
        const Color(0xFF4CAF50),
        progress,
      )!
      ..style = PaintingStyle.fill;

    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    // Draw soil (brown circle)
    canvas.drawCircle(center, size * 0.15, paint);

    // Draw sprout stem
    final stemPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF558B2F),
        const Color(0xFF4CAF50),
        progress,
      )!
      ..strokeWidth = size * 0.05
      ..style = PaintingStyle.stroke;

    final stemHeight = size * 0.3 * progress;
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - stemHeight),
      stemPaint,
    );
  }

  @override
  bool shouldRepaint(SeedlingPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

// Custom painter for sprout stage
class SproutPainter extends CustomPainter {
  final double progress;
  final double size;

  SproutPainter({required this.progress, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    // Draw stem
    final stemPaint = Paint()
      ..color = const Color(0xFF558B2F)
      ..strokeWidth = size * 0.06
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - size * 0.3),
      stemPaint,
    );

    // Draw left leaf
    final leafPaint = Paint()
      ..color = Color.lerp(
        Colors.transparent,
        const Color(0xFF7CB342),
        progress,
      )!
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    leafPath.moveTo(center.dx, center.dy - size * 0.15);
    leafPath.quadraticBezierTo(
      center.dx - size * 0.15 * progress,
      center.dy - size * 0.2 * progress,
      center.dx - size * 0.1 * progress,
      center.dy - size * 0.3 * progress,
    );
    leafPath.quadraticBezierTo(
      center.dx - size * 0.05 * progress,
      center.dy - size * 0.2 * progress,
      center.dx,
      center.dy - size * 0.15,
    );

    canvas.drawPath(leafPath, leafPaint);

    // Draw right leaf (mirrored)
    final rightLeafPath = Path();
    rightLeafPath.moveTo(center.dx, center.dy - size * 0.15);
    rightLeafPath.quadraticBezierTo(
      center.dx + size * 0.15 * progress,
      center.dy - size * 0.2 * progress,
      center.dx + size * 0.1 * progress,
      center.dy - size * 0.3 * progress,
    );
    rightLeafPath.quadraticBezierTo(
      center.dx + size * 0.05 * progress,
      center.dy - size * 0.2 * progress,
      center.dx,
      center.dy - size * 0.15,
    );

    canvas.drawPath(rightLeafPath, leafPaint);
  }

  @override
  bool shouldRepaint(SproutPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
