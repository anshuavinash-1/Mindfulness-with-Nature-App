import 'dart:async';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioTrack {
  const AudioTrack({
    required this.name,
    required this.downloadUrl,
    required this.fullPath,
    required this.tagIds,
  });

  final String name;
  final String downloadUrl;
  final String fullPath;
  final List<int> tagIds;
}

class AudioTag {
  const AudioTag({
    required this.id,
    required this.label,
    required this.color,
  });

  final int id;
  final String label;
  final Color color;
}

class ActivitiesAudioService extends ChangeNotifier {
  static const String audioLibraryUrl =
      'gs://mindfulness-with-nature-2025.firebasestorage.app/audios';

  static const Map<String, String> _trackTitleOverrides = {
    'audios/skow_down_your_body_to_slow_down_you_mind_1_min':
        'Slow Down Your Body to Slow Down Your Mind',
    'skow_down_your_body_to_slow_down_you_mind_1_min':
        'Slow Down Your Body to Slow Down Your Mind',
  };

  static const List<AudioTag> audioTags = [
    AudioTag(id: 1, label: 'Being Present', color: Color(0xFF6B9080)),
    AudioTag(id: 2, label: 'Feeling Lighter', color: Color(0xFFA4C3B2)),
    AudioTag(id: 3, label: 'Connecting with Nature', color: Color(0xFF88AB8E)),
    AudioTag(id: 4, label: 'Gratitude', color: Color(0xFFEAB8A3)),
    AudioTag(id: 5, label: 'Feeling Awe', color: Color(0xFFD9A273)),
    AudioTag(id: 6, label: 'Feeling Grounded', color: Color(0xFF8D9B6A)),
    AudioTag(id: 7, label: 'Joyfulness', color: Color(0xFFFFD89C)),
    AudioTag(id: 8, label: 'Playfulness', color: Color(0xFFB5C99A)),
    AudioTag(id: 9, label: 'Indoor Practice', color: Color(0xFF9DB4AB)),
    AudioTag(id: 10, label: 'Surprise Me', color: Color(0xFFB8A99A)),
  ];

  static const int _surpriseMeTagId = 10;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();
  StreamSubscription<PlayerState>? _audioStateSubscription;
  StreamSubscription<int?>? _audioIndexSubscription;

  List<AudioTrack>? _audioTracks = <AudioTrack>[];
  bool _audioLoading = true;
  bool _audioReady = false;
  bool _isAudioPlaying = false;
  String? _audioError;
  List<AudioTrack>? _compiledPlaylist = <AudioTrack>[];
  int? _currentPlaylistIndex;
  int _loadedTrackIndex = -1;
  Set<int>? _selectedTagIds = <int>{};

  List<AudioTrack> get _safeAudioTracks => _audioTracks ??= <AudioTrack>[];
  List<AudioTrack> get _safeCompiledPlaylist =>
      _compiledPlaylist ??= <AudioTrack>[];
  Set<int> get _safeSelectedTagIds => _selectedTagIds ??= <int>{};
  bool get _isSurpriseSelected => _safeSelectedTagIds.contains(_surpriseMeTagId);

  List<AudioTrack> get audioTracks => _safeAudioTracks;
  bool get audioLoading => _audioLoading;
  bool get audioReady => _audioReady;
  bool get isAudioPlaying => _isAudioPlaying;
  String? get audioError => _audioError;
  Set<int> get selectedTagIds => _safeSelectedTagIds;
  List<AudioTrack> get compiledPlaylist => _safeCompiledPlaylist;
  bool get hasSelectedTags => _safeSelectedTagIds.isNotEmpty;
  bool get hasPlaylistCandidates => playlistCandidates.isNotEmpty;
  List<AudioTrack> get playlistPreview {
    if (_isSurpriseSelected && _safeCompiledPlaylist.isNotEmpty) {
      return _safeCompiledPlaylist;
    }

    return _buildPlaylistOrder(shuffle: _isSurpriseSelected);
  }

  List<AudioTrack> get playlistCandidates {
    final selectedTagIds = _safeSelectedTagIds;
    if (selectedTagIds.isEmpty) {
      return const <AudioTrack>[];
    }

    return _safeAudioTracks
        .where(
          (track) =>
              track.tagIds.any((tagId) => selectedTagIds.contains(tagId)),
        )
        .toList();
  }

  AudioTrack? get currentPlaylistTrack {
    final playlist = _safeCompiledPlaylist;
    if (playlist.isEmpty || _currentPlaylistIndex == null) {
      return null;
    }

    final index = _currentPlaylistIndex!;
    if (index < 0 || index >= playlist.length) {
      return null;
    }

    return playlist[index];
  }

  Future<void> initialize() async {
    _audioStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      final isPlaying =
          state.playing && state.processingState == ProcessingState.ready;
      if (_isAudioPlaying != isPlaying) {
        _isAudioPlaying = isPlaying;
        notifyListeners();
      }
    });

    _audioIndexSubscription = _audioPlayer.currentIndexStream.listen((index) {
      if (_currentPlaylistIndex != index) {
        _currentPlaylistIndex = index;
        notifyListeners();
      }
    });

    await loadAudioLibrary();
  }

  Future<void> loadAudioLibrary() async {
    try {
      final snapshot =
          await FirebaseStorage.instance.refFromURL(audioLibraryUrl).listAll();

      final tracks = <AudioTrack>[];
      for (final item in snapshot.items) {
        try {
          final downloadUrl = await item.getDownloadURL();
          tracks.add(
            AudioTrack(
              name: _resolveTrackTitle(item),
              downloadUrl: downloadUrl,
              fullPath: item.fullPath,
              tagIds: _tagsForTrack(item.name),
            ),
          );
        } catch (_) {
          continue;
        }
      }

      _audioTracks = tracks;
      _audioLoading = false;
      _audioReady = tracks.isNotEmpty;
      _audioError = tracks.isEmpty
          ? 'No audio files were found in the Firebase Storage folder.'
          : null;
      _compiledPlaylist = <AudioTrack>[];
      _currentPlaylistIndex = null;
      _loadedTrackIndex = -1;
      notifyListeners();
    } catch (error) {
      _audioLoading = false;
      _audioReady = false;
      _audioError = 'Unable to load audio tracks: $error';
      notifyListeners();
    }
  }

  void toggleTag(int tagId) {
    final selectedTagIds = _safeSelectedTagIds;
    if (selectedTagIds.contains(tagId)) {
      selectedTagIds.remove(tagId);
    } else {
      selectedTagIds.add(tagId);
    }
    _compiledPlaylist = _buildPlaylistOrder(shuffle: _isSurpriseSelected);
    _currentPlaylistIndex = null;

    notifyListeners();
  }

  Future<bool> startSessionPlaylist() async {
    final candidates = playlistCandidates;
    if (candidates.isEmpty) {
      _audioError = _safeSelectedTagIds.isEmpty
          ? 'Select one or more tags first to build a playlist.'
          : 'No tracks match your selected tags.';
      notifyListeners();
      return false;
    }

    try {
      final ordered = _isSurpriseSelected && _safeCompiledPlaylist.isNotEmpty
          ? List<AudioTrack>.from(_safeCompiledPlaylist)
          : _buildPlaylistOrder(shuffle: _isSurpriseSelected);

      _compiledPlaylist = ordered;
      _currentPlaylistIndex = 0;
      _audioError = null;
      notifyListeners();

      final sources = ordered
          .map((track) => AudioSource.uri(Uri.parse(track.downloadUrl)))
          .toList();

      await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: sources),
        preload: true,
      );
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.seek(Duration.zero, index: 0);
      _isAudioPlaying = true;
      notifyListeners();

      unawaited(
        _audioPlayer.play().catchError((error) {
          _audioError = 'Could not start playlist: $error';
          _isAudioPlaying = false;
          notifyListeners();
        }),
      );
      return true;
    } catch (error) {
      _audioError = 'Could not start playlist: $error';
      _isAudioPlaying = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> nextTrack() async {
    if (_safeCompiledPlaylist.isEmpty) {
      return;
    }

    await _audioPlayer.seekToNext();
  }

  Future<void> previousTrack() async {
    if (_safeCompiledPlaylist.isEmpty) {
      return;
    }

    await _audioPlayer.seekToPrevious();
  }

  Future<void> resumePlaylist() async {
    if (_safeCompiledPlaylist.isEmpty) {
      return;
    }

    _isAudioPlaying = true;
    notifyListeners();

    unawaited(
      _audioPlayer.play().catchError((error) {
        _audioError = 'Could not start playback: $error';
        _isAudioPlaying = false;
        notifyListeners();
      }),
    );
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.setLoopMode(LoopMode.off);
    await _audioPlayer.stop();
    _isAudioPlaying = false;
    _currentPlaylistIndex = null;
    notifyListeners();
  }

  String tagLabel(int id) {
    return audioTags.firstWhere((tag) => tag.id == id).label;
  }

  Color tagColor(int id) {
    return audioTags.firstWhere((tag) => tag.id == id).color;
  }

  String _resolveTrackTitle(Reference item) {
    final candidateKeys = <String>[
      item.fullPath,
      item.name,
      _stripExtension(item.name),
      _stripExtension(item.fullPath),
      _normalizeName(item.name),
      _normalizeName(item.fullPath),
    ];

    for (final candidate in candidateKeys) {
      final normalized = _normalizeLookupKey(candidate);
      final override = _trackTitleOverrides[normalized];
      if (override != null && override.isNotEmpty) {
        return override;
      }
    }

    return _formatTrackName(item.name);
  }

  String _stripExtension(String value) {
    return value.contains('.')
        ? value.substring(0, value.lastIndexOf('.'))
        : value;
  }

  String _normalizeLookupKey(String value) {
    final normalizedPath = _stripExtension(value)
        .trim()
        .replaceAll(RegExp(r'^[\\/]+'), '')
        .replaceAll(RegExp(r'[\\/]+'), ' ');
    return _normalizeName(normalizedPath);
  }

  String _formatTrackName(String fileName) {
    final withoutExtension = _stripExtension(fileName);
    final cleaned = withoutExtension.replaceAll(RegExp(r'[_-]+'), ' ').trim();
    if (cleaned.isEmpty) {
      return 'Untitled track';
    }

    return cleaned
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  List<int> _tagsForTrack(String fileName) {
    final normalized = _normalizeName(fileName);

    if (normalized.contains('rooted like a tree')) {
      return [1, 2, 3, 4, 5, 6, 7, 10];
    }
    if (normalized.contains('sensory scan')) {
      return [1, 3, 4, 5, 6, 7, 10];
    }
    if (normalized.contains('symbiotic breathing')) {
      return [1, 2, 3, 4, 5, 6, 7, 10];
    }
    if (normalized.contains('hang your worries on a tree')) {
      return [1, 2, 3, 4, 5, 6, 7, 10];
    }
    if (normalized.contains('nature art gallery')) {
      return [1, 2, 3, 4, 5, 7, 8, 10];
    }
    if (normalized.contains('alien on earth')) {
      return [2, 3, 4, 5, 7, 8, 10];
    }
    if (normalized.contains('grateful nature art')) {
      return [1, 2, 3, 4, 5, 7, 8, 10];
    }
    if (normalized.contains('walking meditation')) {
      return [1, 2, 3, 6, 8, 10];
    }
    if (normalized.contains('slow down your body to slow down your mind')) {
      return [1, 2, 3, 4, 10];
    }

    return [10];
  }

  List<AudioTrack> _buildPlaylistOrder({bool shuffle = false}) {
    final candidates = playlistCandidates;
    if (candidates.isEmpty) {
      return <AudioTrack>[];
    }

    final ordered = List<AudioTrack>.from(candidates);
    if (shuffle) {
      ordered.shuffle(_random);
    } else {
      ordered.sort((a, b) => a.name.compareTo(b.name));
    }

    return ordered;
  }

  String _normalizeName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void dispose() {
    _audioStateSubscription?.cancel();
    _audioIndexSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
