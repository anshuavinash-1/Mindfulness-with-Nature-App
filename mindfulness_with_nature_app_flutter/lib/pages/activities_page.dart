import 'dart:async';

import 'package:flutter/material.dart';

import '../services/activities_audio_service.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage>
    with TickerProviderStateMixin {
  late final ActivitiesAudioService _audioService;

  static const Map<String, String> _hardCodedTitleByKeyword = {
    'rooted like a tree': 'Rooted Like a Tree',
    'sensory scan': 'Sensory Scan',
    'symbiotic breathing': 'Symbiotic Breathing',
    'hang your worries on a': 'Hang Your Worries on a Tree',
    'nature art gallery': 'Nature Art Gallery',
    'alien on earth': 'Alien on Earth',
    'grateful nature art': 'Grateful Nature Art',
    'walking meditation': 'Walking Meditation',
    'slow down your body to slow down your mind':
        'Slow Down Your Body to Slow Down Your Mind',
    'skow down your body to slow down you mind':
        'Slow Down Your Body to Slow Down Your Mind',
  };

  // Slider state - 5 to 60 minutes
  double duration = 5;
  Timer? timer;
  int remainingSeconds = 300;
  bool isSessionActive = false;
  bool isSessionPaused = false;
  bool showCompletionFeedback = false;

  late AnimationController _breatheController;
  late AnimationController _pulseController;
  late Animation<double> _breatheAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _audioService = ActivitiesAudioService();
    unawaited(_audioService.initialize());

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
    _audioService.dispose();
    _breatheController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void startSession() {
    unawaited(_startSessionAsync());
  }

  Future<void> _startSessionAsync() async {
    final started = await _audioService.startSessionPlaylist();
    if (!mounted) {
      return;
    }

    if (!started) {
      final message = _audioService.audioError ??
          'Select tags to compile a playlist first.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    setState(() {
      isSessionActive = true;
      isSessionPaused = false;
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

  void pauseSession() {
    timer?.cancel();
    _breatheController.stop();
    setState(() {
      isSessionPaused = true;
    });
  }

  void resumeSession() {
    setState(() {
      isSessionPaused = false;
    });
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
    unawaited(_audioService.stopAudio());
    setState(() {
      isSessionActive = false;
      isSessionPaused = false;
    });
  }

  void _onSessionComplete() {
    unawaited(_audioService.stopAudio());
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
    final selectedTrack = _audioService.currentPlaylistTrack;
    final completionTitle =
        selectedTrack == null ? null : _hardCodedTitleForTrack(selectedTrack);

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
              'Session Complete! \uD83C\uDF3F',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (completionTitle != null)
              Text(
                completionTitle,
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
    return '$min:$s';
  }

  String _hardCodedTitleForTrack(
    AudioTrack track,
  ) {
    final normalizedName = track.name
        .toLowerCase()
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final normalizedPath = track.fullPath
        .toLowerCase()
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    for (final entry in _hardCodedTitleByKeyword.entries) {
      if (normalizedName.contains(entry.key) ||
          normalizedPath.contains(entry.key)) {
        return entry.value;
      }
    }

    return track.name;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _audioService,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Activities',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B3D2F),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'What brings you peace today?',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF1B3D2F).withOpacity(0.85),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildActivityPills(),
                  const SizedBox(height: 28),
                  _buildDurationSection(),
                  const SizedBox(height: 28),
                  _buildSlider(),
                  const SizedBox(height: 36),
                  _buildAudioSection(),
                  const SizedBox(height: 28),
                  _buildTimerDisplay(),
                  const SizedBox(height: 32),
                  _buildStartButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityPills() {
    final canEditTags = !isSessionActive;

    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: List.generate(ActivitiesAudioService.audioTags.length, (index) {
        final tag = ActivitiesAudioService.audioTags[index];
        final isSelected = _audioService.selectedTagIds.contains(tag.id);

        return GestureDetector(
          onTap: canEditTags ? () => _audioService.toggleTag(tag.id) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? tag.color.withOpacity(0.22)
                  : const Color(0xFFEBE3D8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? tag.color : const Color(0xFFCCC0B0),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: tag.color.withOpacity(0.18),
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
              tag.label,
              style: TextStyle(
                color: isSelected
                    ? tag.color
                    : canEditTags
                        ? const Color(0xFF3D2B1F)
                        : const Color(0xFF3D2B1F).withOpacity(0.45),
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3D2F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${duration.toInt()} Minutes',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1B3D2F),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioSection() {
    final playlistCandidates = _audioService.playlistPreview;
    final currentTrack = _audioService.currentPlaylistTrack;
    final currentTrackTitle =
        currentTrack == null ? null : _hardCodedTitleForTrack(currentTrack);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Playlist',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3D2F),
          ),
        ),
        const SizedBox(height: 4),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_audioService.audioLoading) ...[
                const LinearProgressIndicator(
                  minHeight: 3,
                  color: Color(0xFF3D2B1F),
                  backgroundColor: Color(0xFFE1D7C8),
                ),
                const SizedBox(height: 12),
                Text(
                  'Loading audio library...',
                  style: TextStyle(
                    color: const Color(0xFF3D2B1F).withOpacity(0.72),
                  ),
                ),
              ] else if (_audioService.audioTracks.isEmpty) ...[
                Text(
                  _audioService.audioError ??
                      'No audio tracks are available right now.',
                  style: const TextStyle(
                    color: Color(0xFF7A5B4A),
                    fontSize: 14,
                  ),
                ),
              ] else if (!_audioService.hasSelectedTags) ...[
                const Text(
                  'Select one or more tags to build your playlist.',
                  style: TextStyle(
                    color: Color(0xFF7A5B4A),
                    fontSize: 14,
                  ),
                ),
              ] else if (playlistCandidates.isEmpty) ...[
                const Text(
                  'No tracks match the current tag combination.',
                  style: TextStyle(
                    color: Color(0xFF7A5B4A),
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                Text(
                  'Playlist ready: ${playlistCandidates.length} track(s)',
                  style: const TextStyle(
                    color: Color(0xFF3D2B1F),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                if (currentTrack != null) ...[
                  Text(
                    'Now Playing: $currentTrackTitle',
                    style: const TextStyle(
                      color: Color(0xFF3D2B1F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    itemCount: playlistCandidates.length,
                    itemBuilder: (context, index) {
                      final track = playlistCandidates[index];
                      final isCurrent = currentTrack != null &&
                          track.fullPath == currentTrack.fullPath;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${index + 1}. ${_hardCodedTitleForTrack(track)}',
                          style: TextStyle(
                            color: isCurrent
                                ? const Color(0xFF3D2B1F)
                                : const Color(0xFF6C5A4A),
                            fontWeight:
                                isCurrent ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: _audioService.compiledPlaylist.length > 1
                          ? () => unawaited(_audioService.previousTrack())
                          : null,
                      icon: const Icon(Icons.skip_previous),
                      color: const Color(0xFF3D2B1F),
                      tooltip: 'Previous track',
                    ),
                    IconButton(
                      onPressed: _audioService.isAudioPlaying
                          ? () {
                              pauseSession();
                              unawaited(_audioService.pauseAudio());
                            }
                          : isSessionActive
                              ? () {
                                  resumeSession();
                                  unawaited(_audioService.resumePlaylist());
                                }
                              : playlistCandidates.isNotEmpty
                                  ? startSession
                                  : null,
                      icon: Icon(
                        _audioService.isAudioPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        size: 34,
                      ),
                      color: const Color(0xFF3D2B1F),
                      tooltip: _audioService.isAudioPlaying
                          ? 'Pause'
                          : isSessionActive
                              ? 'Resume'
                              : 'Start session',
                    ),
                    IconButton(
                      onPressed: _audioService.compiledPlaylist.length > 1
                          ? () => unawaited(_audioService.nextTrack())
                          : null,
                      icon: const Icon(Icons.skip_next),
                      color: const Color(0xFF3D2B1F),
                      tooltip: 'Next track',
                    ),
                    const Spacer(),
                    Text(
                      _audioService.isAudioPlaying
                          ? 'Playing'
                          : isSessionPaused
                              ? 'Paused'
                              : 'Ready',
                      style: const TextStyle(
                        color: Color(0xFF3D2B1F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (_audioService.audioError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _audioService.audioError!,
                    style: const TextStyle(
                      color: Color(0xFF8B3A3A),
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
              ],
            ],
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5 MINS',
                style: TextStyle(
                  color: Color(0xFF3D2B1F),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                '60 MINS',
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
              'End Session',
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
              'Start New Session',
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

    final hasTrack = _audioService.hasPlaylistCandidates;

    return GestureDetector(
      onTap: hasTrack ? startSession : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: hasTrack
              ? const Color(0xFF3D2B1F)
              : const Color(0xFF3D2B1F).withOpacity(0.45),
          borderRadius: BorderRadius.circular(40),
          boxShadow: hasTrack
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
            hasTrack ? 'Start Session' : 'Select tags first',
            style: TextStyle(
              color: Colors.white.withOpacity(hasTrack ? 1.0 : 0.7),
              fontSize: hasTrack ? 20 : 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
