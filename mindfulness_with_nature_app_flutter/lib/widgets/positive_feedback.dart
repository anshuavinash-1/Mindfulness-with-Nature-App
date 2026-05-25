import 'package:flutter/material.dart';

enum FeedbackType {
  leaf,
  sun,
  flower,
  bird,
  ripple,
  sparkle,
  random,
}

class PositiveFeedback extends StatelessWidget {
  const PositiveFeedback({
    super.key,
    required this.type,
    this.size = 88,
  });

  final FeedbackType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _backgroundColor(type),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _backgroundColor(type).withValues(alpha: 0.35),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        _icon(type),
        color: Colors.white,
        size: size * 0.48,
      ),
    );
  }

  static IconData _icon(FeedbackType type) {
    switch (type) {
      case FeedbackType.leaf:
        return Icons.eco;
      case FeedbackType.sun:
        return Icons.wb_sunny;
      case FeedbackType.flower:
        return Icons.local_florist;
      case FeedbackType.bird:
        return Icons.flight;
      case FeedbackType.ripple:
        return Icons.water_drop;
      case FeedbackType.sparkle:
      case FeedbackType.random:
        return Icons.auto_awesome;
    }
  }

  static Color _backgroundColor(FeedbackType type) {
    switch (type) {
      case FeedbackType.leaf:
        return const Color(0xFF4CAF50);
      case FeedbackType.sun:
        return const Color(0xFFFFB300);
      case FeedbackType.flower:
        return const Color(0xFFE91E63);
      case FeedbackType.bird:
        return const Color(0xFF03A9F4);
      case FeedbackType.ripple:
        return const Color(0xFF00ACC1);
      case FeedbackType.sparkle:
      case FeedbackType.random:
        return const Color(0xFF7A9F5A);
    }
  }
}