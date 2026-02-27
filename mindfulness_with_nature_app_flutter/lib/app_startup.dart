import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles all heavy initialization BEFORE runApp()
/// Uses Future.wait to run tasks IN PARALLEL, not sequentially
class AppStartup {
  // Global audio player — initialized once, reused everywhere
  static late AudioPlayer audioPlayer;
  static late SharedPreferences prefs;

  // Home screen image URLs to pre-cache
  static const List<String> _imagesToPreCache = [
    'https://images.unsplash.com/photo-1448375240586-882707db888b?w=300&q=80',
    'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=300&q=80',
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=300&q=80',
  ];

  static Future<void> initialize() async {
    // Run ALL tasks in parallel with Future.wait
    await Future.wait([
      _initAudio(),
      _initPrefs(),
      _warmUpImageCache(),
    ]);
  }

  /// Pre-initialize audio player and buffer the default ambient sound
  static Future<void> _initAudio() async {
    audioPlayer = AudioPlayer();
    try {
      // Set audio source but DON'T play yet — just buffer it
      // Use a short, compressed ambient sound asset
      await audioPlayer.setAsset(
        'assets/audio/ambient.mp3',
        preload: true, // buffers into memory immediately
      );
      await audioPlayer.setLoopMode(LoopMode.all);
      await audioPlayer.setVolume(0.5);
    } catch (e) {
      // Audio file missing or error — fail silently, don't crash app
      debugPrint('Audio init skipped: $e');
    }
  }

  /// Load SharedPreferences so it's ready instantly when needed
  static Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// Pre-cache key images so they appear instantly on screen
  static Future<void> _warmUpImageCache() async {
    // We need a temporary binding to pre-cache before runApp
    // This warms the image cache without a BuildContext
    final binding = WidgetsBinding.instance;
    // Image pre-caching happens after runApp via HomeScreen.initState
    // Just resolve the future immediately here
    await Future.delayed(Duration.zero);
  }

  /// Call this from HomeScreen.initState to cache images with context
  static Future<void> preCacheImages(BuildContext context) async {
    await Future.wait(
      _imagesToPreCache.map(
            (url) => precacheImage(CachedNetworkImageProvider(url), context),
      ),
    );
  }

  /// Start audio playback — call this after home screen is rendered
  static Future<void> startAudio() async {
    try {
      if (audioPlayer.processingState == ProcessingState.ready ||
          audioPlayer.processingState == ProcessingState.completed) {
        await audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Audio play error: $e');
    }
  }

  static Future<void> stopAudio() async {
    try {
      await audioPlayer.pause();
    } catch (e) {
      debugPrint('Audio stop error: $e');
    }
  }

  static Future<void> dispose() async {
    await audioPlayer.dispose();
  }
}