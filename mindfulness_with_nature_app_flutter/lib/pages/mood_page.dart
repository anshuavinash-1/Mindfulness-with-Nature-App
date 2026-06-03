import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_experience_service.dart';

class MoodSettingsPage extends StatefulWidget {
  const MoodSettingsPage({super.key});

  @override
  State<MoodSettingsPage> createState() => _MoodSettingsPageState();
}

class _MoodSettingsPageState extends State<MoodSettingsPage> {
  final List<String> backgrounds = ["Forest", "Ocean", "Meadow"];

  final Map<String, String> backgroundImages = {
    "Forest":
        "https://images.unsplash.com/photo-1448375240586-882707db888b?w=300&q=80",
    "Ocean":
        "https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=300&q=80",
    "Meadow":
        "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=300&q=80",
  };

  String? selectedBackground;

  final List<_SoundOption> sounds = [
    const _SoundOption(label: "Bird Songs"),
    const _SoundOption(label: "Ocean Waves", unavailable: true),
    const _SoundOption(label: "Rain", unavailable: true),
    const _SoundOption(label: "Silence"),
  ];
  String? selectedSound;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final appExperience =
          Provider.of<AppExperienceService>(context, listen: false);

      if (!mounted) return;

      setState(() {
        final bg = appExperience.selectedBackground;
        final snd = appExperience.selectedSound;
        selectedBackground =
            (bg != null && backgrounds.contains(bg)) ? bg : null;
        selectedSound =
            sounds.any((sound) => sound.label == snd) ? snd : 'Bird Songs';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load saved settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    final appExperience =
        Provider.of<AppExperienceService>(context, listen: false);

    if (!appExperience.canEditMoodPreferences) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Guest theme changes are only available on the web app.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      appExperience.setBackgroundSelection(selectedBackground);
      await appExperience.setSoundSelection(selectedSound);
      await appExperience.persistSelections();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mood settings saved 🌿'),
          backgroundColor: Color(0xFF556B2F),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appExperience = context.watch<AppExperienceService>();
    final canEdit = appExperience.canEditMoodPreferences;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Set Your Mood",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1F14),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (!canEdit)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFB74D)),
                        ),
                        child: const Text(
                          'Guest theme changes are available on web only. Sign in on mobile to save theme and sound.',
                          style: TextStyle(
                            color: Color(0xFF7A4A00),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EAE0),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: const Color(0xFF6FA8DC), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Background ──────────────────────────────────
                          Row(
                            children: const [
                              Icon(Icons.image_outlined,
                                  color: Color(0xFF2C1F14), size: 28),
                              SizedBox(width: 10),
                              Text(
                                "Background",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C1F14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: backgrounds.map((name) {
                              final isSelected = selectedBackground == name;
                              final imageUrl = backgroundImages[name]!;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: canEdit
                                      ? () => setState(
                                          () => selectedBackground = name)
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Column(
                                      children: [
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: isSelected
                                                ? Border.all(
                                                    color:
                                                        const Color(0xFF6FA8DC),
                                                    width: 3)
                                                : null,
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                              0xFF6FA8DC)
                                                          .withOpacity(0.4),
                                                      blurRadius: 8,
                                                      spreadRadius: 1,
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              imageUrl,
                                              height: 110,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                height: 110,
                                                color: const Color(0xFFCCC0B0),
                                                child: const Icon(
                                                    Icons.landscape,
                                                    color: Colors.white54,
                                                    size: 40),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: const Color(0xFF2C1F14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 28),

                          // ── Nature Sounds ───────────────────────────────
                          Row(
                            children: const [
                              Icon(Icons.music_note,
                                  color: Color(0xFF2C1F14), size: 26),
                              SizedBox(width: 10),
                              Text(
                                "Nature Sounds",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C1F14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: sounds.map((sound) {
                              final isSelected = selectedSound == sound.label;
                              final isWide = sound.label == "Silence";
                              return GestureDetector(
                                onTap: (canEdit && !sound.unavailable)
                                    ? () => setState(
                                          () => selectedSound = sound.label,
                                        )
                                    : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: isWide ? double.infinity : null,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF7A8C6E)
                                        : const Color(0xFFE8E0D5),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF7A8C6E)
                                          : const Color(0xFFBDB0A0),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          sound.label,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF2C1F14),
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                          ),
                                        ),
                                        if (sound.unavailable) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Unavailable',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white70
                                                  : const Color(0xFF8B3A3A),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Apply button ──────────────────────────────────────
                    GestureDetector(
                      key: const Key('mood-apply-settings-button'),
                      onTap: (_isSaving || !canEdit) ? null : _saveSettings,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: _isSaving
                              ? const Color(0xFF9E8E72)
                              : const Color(0xFF6B5C3E),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6B5C3E).withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Apply settings",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SoundOption {
  final String label;
  final bool unavailable;

  const _SoundOption({required this.label, this.unavailable = false});
}
