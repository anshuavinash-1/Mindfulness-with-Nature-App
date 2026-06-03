import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mood_settings_service.dart';

class AppExperienceService extends ChangeNotifier {
  static const String _guestWebBackgroundKey = 'guest_web_background';
  static const String _guestWebSoundKey = 'guest_web_sound';

  final AudioPlayer _ambientPlayer = AudioPlayer();

  bool _isInitialized = false;
  bool _isSignedIn = false;
  bool _isShellActive = false;
  bool _isActivitiesTabActive = false;
  bool _isApplyingAudio = false;

  static const String _defaultAmbientSound = 'Bird Songs';
  static const Duration _ambientReplayDelay = Duration(seconds: 2);
  static const Map<String, String> _ambientSoundAssets = {
    'Bird Songs': 'assets/audio/bird.mp3',
  };

  String? _activeUserId;
  String? _selectedBackground;
  String? _selectedSound;
  String? _loadedAmbientAsset;
  Timer? _ambientReplayTimer;
  StreamSubscription<ProcessingState>? _ambientProcessingSubscription;

  String? get selectedBackground => _selectedBackground;
  String? get selectedSound => _selectedSound;

  bool get canEditMoodPreferences => _isSignedIn || kIsWeb;

  Color get scaffoldBackgroundColor {
    switch (_selectedBackground) {
      case 'Ocean':
        return const Color(0xFFD4E7ED);
      case 'Meadow':
        return const Color(0xFFE5ECD3);
      case 'Forest':
      default:
        return const Color(0xFFDDE3C2);
    }
  }

  Color get navBackgroundColor {
    switch (_selectedBackground) {
      case 'Ocean':
        return const Color(0xFFE9F4F8);
      case 'Meadow':
        return const Color(0xFFF0F3E1);
      case 'Forest':
      default:
        return const Color(0xFFF0EEDC);
    }
  }

  String get homeBackgroundAsset {
    switch (_selectedBackground) {
      case 'Ocean':
        return 'assets/images/sunny.jpg';
      case 'Meadow':
        return 'assets/images/sunrise.jpg';
      case 'Forest':
      default:
        return 'assets/images/splash_bg.jpg';
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;

    try {
      await _ambientPlayer.setLoopMode(LoopMode.off);
      await _ambientPlayer.setVolume(0.35);
      _ambientProcessingSubscription =
          _ambientPlayer.processingStateStream.listen(
        _handleAmbientProcessingState,
      );
    } catch (_) {
      // Keep app usable if ambient audio cannot be initialized.
    }

    await _loadPreferencesForCurrentUser();
    await _applyAmbientPlayback();
  }

  Future<void> updateAuthState({
    required String? userId,
    required bool isSignedIn,
  }) async {
    final identityChanged =
        userId != _activeUserId || isSignedIn != _isSignedIn;

    _activeUserId = userId;
    _isSignedIn = isSignedIn;

    if (!identityChanged) {
      return;
    }

    await _loadPreferencesForCurrentUser();
    await _applyAmbientPlayback();
    notifyListeners();
  }

  void setActivitiesTabActive(bool isActive) {
    if (_isActivitiesTabActive == isActive) {
      return;
    }

    _isActivitiesTabActive = isActive;
    if (isActive) {
      _stopAmbientPlayback();
    }
    unawaited(_applyAmbientPlayback());
  }

  void setShellActive(bool isActive) {
    if (_isShellActive == isActive) {
      return;
    }

    _isShellActive = isActive;
    unawaited(_applyAmbientPlayback());
  }

  void setBackgroundSelection(String? background) {
    if (!canEditMoodPreferences) {
      return;
    }

    _selectedBackground = background;
    notifyListeners();
  }

  Future<void> setSoundSelection(String? sound) async {
    if (!canEditMoodPreferences) {
      return;
    }

    _selectedSound = _normalizeSoundSelection(sound);
    notifyListeners();
    await _applyAmbientPlayback();
  }

  Future<void> persistSelections() async {
    if (!canEditMoodPreferences) {
      return;
    }

    if (_isSignedIn) {
      try {
        await MoodSettingsService.saveSettings(
          background: _selectedBackground,
          sound: _selectedSound,
        );
      } catch (_) {
        // On web, transient auth timing can briefly report signed-out.
        // Fall back to local persistence so user changes are not lost.
        if (!kIsWeb) {
          rethrow;
        }
      }

      if (!kIsWeb) {
        return;
      }

      // Keep a web fallback copy even when signed in.
      final prefs = await SharedPreferences.getInstance();
      if (_selectedBackground == null) {
        await prefs.remove(_guestWebBackgroundKey);
      } else {
        await prefs.setString(_guestWebBackgroundKey, _selectedBackground!);
      }

      if (_selectedSound == null) {
        await prefs.remove(_guestWebSoundKey);
      } else {
        await prefs.setString(_guestWebSoundKey, _selectedSound!);
      }
      return;
    }

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      if (_selectedBackground == null) {
        await prefs.remove(_guestWebBackgroundKey);
      } else {
        await prefs.setString(_guestWebBackgroundKey, _selectedBackground!);
      }

      if (_selectedSound == null) {
        await prefs.remove(_guestWebSoundKey);
      } else {
        await prefs.setString(_guestWebSoundKey, _selectedSound!);
      }
    }
  }

  Future<void> _loadPreferencesForCurrentUser() async {
    if (_isSignedIn) {
      try {
        final saved = await MoodSettingsService.loadSettings();
        _selectedBackground = saved['background'];
        _selectedSound = _normalizeSoundSelection(saved['sound']);
      } catch (_) {
        // Keep app functional even if cloud settings are temporarily unavailable.
        _selectedSound ??= _defaultAmbientSound;
      }
      return;
    }

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      _selectedBackground = prefs.getString(_guestWebBackgroundKey);
      _selectedSound = _normalizeSoundSelection(
        prefs.getString(_guestWebSoundKey),
      );
      return;
    }

    _selectedBackground = null;
    _selectedSound = _defaultAmbientSound;
  }

  Future<void> _applyAmbientPlayback() async {
    if (_isApplyingAudio) {
      return;
    }
    _isApplyingAudio = true;

    try {
      final assetToPlay = _resolveAmbientAsset(_selectedSound);
      final shouldPlay = _shouldPlayAmbient(assetToPlay);

      if (shouldPlay) {
        final targetAsset = assetToPlay!;
        if (_loadedAmbientAsset != targetAsset) {
          _stopAmbientPlayback();
          await _ambientPlayer.setAsset(targetAsset, preload: true);
          _loadedAmbientAsset = targetAsset;
        }

        if (_ambientPlayer.processingState == ProcessingState.completed) {
          _scheduleAmbientReplay();
        } else if (!_ambientPlayer.playing) {
          _ambientReplayTimer?.cancel();
          await _ambientPlayer.play();
        }
      } else {
        await _stopAmbientPlayback();
      }
    } catch (_) {
      // Ignore audio runtime failures so UX remains functional.
    } finally {
      _isApplyingAudio = false;
    }
  }

  @override
  void dispose() {
    _ambientReplayTimer?.cancel();
    _ambientProcessingSubscription?.cancel();
    _ambientPlayer.dispose();
    super.dispose();
  }

  String? _resolveAmbientAsset(String? sound) {
    if (sound == null || sound == 'Silence') {
      return null;
    }

    return _ambientSoundAssets[sound];
  }

  String _normalizeSoundSelection(String? sound) {
    if (sound == 'Silence' || sound == _defaultAmbientSound) {
      return sound ?? _defaultAmbientSound;
    }

    return _defaultAmbientSound;
  }

  bool _shouldPlayAmbient(String? assetToPlay) {
    return _isShellActive && !_isActivitiesTabActive && assetToPlay != null;
  }

  Future<void> _stopAmbientPlayback() async {
    _ambientReplayTimer?.cancel();
    if (_ambientPlayer.playing ||
        _ambientPlayer.processingState != ProcessingState.idle) {
      await _ambientPlayer.stop();
    }
  }

  void _handleAmbientProcessingState(ProcessingState state) {
    if (state != ProcessingState.completed) {
      return;
    }

    _scheduleAmbientReplay();
  }

  void _scheduleAmbientReplay() {
    _ambientReplayTimer?.cancel();
    _ambientReplayTimer = Timer(_ambientReplayDelay, () {
      _ambientReplayTimer = null;
      unawaited(_replayAmbientIfEligible());
    });
  }

  Future<void> _replayAmbientIfEligible() async {
    try {
      final assetToPlay = _resolveAmbientAsset(_selectedSound);
      if (!_shouldPlayAmbient(assetToPlay)) {
        return;
      }

      final targetAsset = assetToPlay!;

      // Always stop and re-set the asset before playing. Calling seek+play
      // after ProcessingState.completed is unreliable on web and some mobile
      // audio backends — a full stop+setAsset resets the player to a known
      // idle state and guarantees the track restarts cleanly.
      await _ambientPlayer.stop();
      await _ambientPlayer.setAsset(targetAsset, preload: true);
      _loadedAmbientAsset = targetAsset;
      await _ambientPlayer.play();
    } catch (_) {
      // Ignore audio runtime failures so UX remains functional.
    }
  }
}
