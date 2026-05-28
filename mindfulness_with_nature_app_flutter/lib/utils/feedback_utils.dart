// lib/utils/feedback_utils.dart
import 'package:flutter/material.dart';
import '../widgets/positive_feedback.dart';

class FeedbackUtils {
  /// Shows a micro-interaction as an overlay
  static void showPositiveFeedback(
    BuildContext context, {
    FeedbackType type = FeedbackType.random,
    double size = 180.0, // Add size parameter
    Duration duration = const Duration(seconds: 2), // Add duration parameter
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: PositiveFeedback(type: type, size: size),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-remove after duration
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  static void getFeedbackTypeForActivity(String? currentActivity) {}

  static void showFeedbackDialog(
    BuildContext context, {
    required void type,
    required String title,
    required String message,
    required String buttonText,
  }) {}
}
