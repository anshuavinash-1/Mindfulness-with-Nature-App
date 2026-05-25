import 'package:flutter/material.dart';

import '../widgets/positive_feedback.dart';

class FeedbackUtils {
  static FeedbackType getFeedbackTypeForActivity(String? activity) {
    final normalized = activity?.toLowerCase() ?? '';

    if (normalized.contains('breath') || normalized.contains('meditat')) {
      return FeedbackType.ripple;
    }
    if (normalized.contains('walk') || normalized.contains('nature')) {
      return FeedbackType.leaf;
    }
    if (normalized.contains('sleep') || normalized.contains('rest')) {
      return FeedbackType.sun;
    }
    if (normalized.contains('gratitude') || normalized.contains('journal')) {
      return FeedbackType.flower;
    }

    return FeedbackType.sparkle;
  }

  static void showPositiveFeedback(
    BuildContext context, {
    FeedbackType type = FeedbackType.sparkle,
    double size = 88,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    final resolvedType = type == FeedbackType.random
        ? FeedbackType.values[DateTime.now().millisecond %
            (FeedbackType.values.length - 1)]
        : type;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      return;
    }

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 180),
              child: PositiveFeedback(
                type: resolvedType,
                size: size,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, entry.remove);
  }

  static Future<void> showFeedbackDialog(
    BuildContext context, {
    required FeedbackType type,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              PositiveFeedback(type: type, size: 36),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }
}