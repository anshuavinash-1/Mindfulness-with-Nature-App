import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/positive_feedback.dart';
import '../utils/feedback_utils.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final Random _random = Random();
  Timer? _sessionTimer;
  int _remainingSeconds = 0;
  String? _currentActivity;
  double _sessionDuration = 0;
  VoidCallback? _onSessionComplete;

  /// Start a new meditation session
  void startSession({
    required String activity,
    required double durationMinutes,
    required BuildContext context,
    VoidCallback? onComplete,
  }) {
    _currentActivity = activity;
    _sessionDuration = durationMinutes;
    _onSessionComplete = onComplete;
    _remainingSeconds = (durationMinutes * 60).toInt();

    // Start the timer
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        _completeSession(context);
        timer.cancel();
      }
    });
  }

  /// Stop the current session
  void stopSession() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _remainingSeconds = 0;
  }

  /// Complete the session and show feedback
  void _completeSession(BuildContext context) {
    // Determine feedback type based on activity
    final feedbackType =
        FeedbackUtils.getFeedbackTypeForActivity(_currentActivity);

    // Show the micro-interaction
    // FeedbackUtils.showPositiveFeedback(
    //   context,
    //   type: feedbackType,
    //   duration: const Duration(seconds: 2),
    // );

    // Show completion dialog after a delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      FeedbackUtils.showFeedbackDialog(
        context,
        type: feedbackType,
        title: 'Session Complete!',
        message:
            'You completed "$_currentActivity" for $_sessionDuration minutes',
        buttonText: 'Continue',
      );
    });

    // Call the completion callback
    _onSessionComplete?.call();

    // Save session data (you can integrate with your database here)
    _saveSessionData();
  }

  void _saveSessionData() {
    // Save to local storage or database
    final sessionData = {
      'activity': _currentActivity,
      'duration': _sessionDuration,
      'timestamp': DateTime.now().toIso8601String(),
    };
    print('Session saved: $sessionData');
    // Implement your actual save logic here
  }

  /// Get current session info
  Map<String, dynamic> getSessionInfo() {
    return {
      'activity': _currentActivity,
      'remainingSeconds': _remainingSeconds,
      'isActive': _sessionTimer != null && _sessionTimer!.isActive,
    };
  }

  /// Format seconds to MM:SS
  static String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }
}
