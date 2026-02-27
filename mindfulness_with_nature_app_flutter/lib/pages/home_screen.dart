import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';



class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AudioPlayer _audioPlayer;
  bool _audioReady = false;

  /// Returns greeting text
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "GOOD MORNING";
    if (hour < 17) return "GOOD AFTERNOON";
    return "GOOD EVENING";
  }

  /// Returns background image based on time
  String _getBackgroundImage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "assets/images/sunrise.jpg";
    if (hour < 17) return "assets/images/sunny.jpg";
    return "assets/images/sunset.jpg";
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // UI renders first, THEN we do background work
    // This is what guarantees the screen appears instantly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initInBackground();
    });
  }

  Future<void> _initInBackground() async {
    // Audio init + image pre-caching run IN PARALLEL
    await Future.wait([
      _initAudio(),
      _precacheImages(),
    ]);
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAsset(
        'assets/audio/ambient.mp3',
        preload: true,
      );
      await _audioPlayer.setVolume(0.4);

      await Future.delayed(const Duration(milliseconds: 150));
      await _audioPlayer.play();

      if (mounted) setState(() => _audioReady = true);

      // Play for exactly 5 seconds then stop
      await Future.delayed(const Duration(seconds: 5));
      await _audioPlayer.stop();

      if (mounted) setState(() => _audioReady = false);
    } catch (e) {
      debugPrint('Audio init skipped: $e');
    }
  }

  Future<void> _precacheImages() async {
    // Load all 3 background images into Flutter's image cache now
    // so they appear instantly when the time of day changes
    await Future.wait([
      precacheImage(const AssetImage('assets/images/sunrise.jpg'), context),
      precacheImage(const AssetImage('assets/images/sunny.jpg'), context),
      precacheImage(const AssetImage('assets/images/sunset.jpg'), context),
    ]);
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // always clean up
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// Dynamic Background Image
          /// gaplessPlayback stops any white flash when image rebuilds
          Positioned.fill(
            child: Image.asset(
              _getBackgroundImage(),
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),

          /// Dark overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          /// Main Content — identical to your original
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [

                  const SizedBox(height: 30),

                  /// Top App Title
                  const Text(
                    "Mindfulness with Nature",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  /// Subtle audio indicator — fades in once audio is ready
                  /// Doesn't affect layout when hidden
                  AnimatedOpacity(
                    opacity: _audioReady ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.volume_up,
                              color: Colors.white38, size: 13),
                          const SizedBox(width: 4),
                          const Text(
                            "Ambient sound on",
                            style: TextStyle(
                                color: Colors.white38, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              if (_audioPlayer.playing) {
                                await _audioPlayer.pause();
                              } else {
                                await _audioPlayer.play();
                              }
                              setState(() {});
                            },
                            child: Icon(
                              _audioPlayer.playing
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              color: Colors.white54,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// Greeting Text
                  Text(
                    "${_getGreeting()} ${widget.userName}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Practice Feature Card — unchanged from your original
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 25,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff9BAFAF).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          "Today's Practice Feature",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Grounding in Nature",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),



    );
  }
}