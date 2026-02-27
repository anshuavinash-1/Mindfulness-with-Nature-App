import 'package:flutter/material.dart';

class MoodSettingsPage extends StatefulWidget {
  const MoodSettingsPage({super.key});

  @override
  State<MoodSettingsPage> createState() => _MoodSettingsPageState();
}

class _MoodSettingsPageState extends State<MoodSettingsPage> {
  // Keep as List<String> to match bottom_nav_page expectations
  final List<String> backgrounds = ["Forest", "Ocean", "Meadow"];

  // Internal image URL mapping
  final Map<String, String> backgroundImages = {
    "Forest": "https://images.unsplash.com/photo-1448375240586-882707db888b?w=300&q=80",
    "Ocean": "https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=300&q=80",
    "Meadow": "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=300&q=80",
  };

  String? selectedBackground;

  final List<String> sounds = ["Ocean Waves", "Breeze", "Bird Songs", "Silence"];
  String? selectedSound;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6CBC0),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Title
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

              // Main Card with blue border
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EAE0),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF6FA8DC),
                    width: 2,
                  ),
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
                    // Background section header
                    Row(
                      children: const [
                        Icon(
                          Icons.image_outlined,
                          color: Color(0xFF2C1F14),
                          size: 28,
                        ),
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

                    // Background Image Thumbnails
                    Row(
                      children: backgrounds.map((name) {
                        final isSelected = selectedBackground == name;
                        final imageUrl = backgroundImages[name]!;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedBackground = name;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected
                                          ? Border.all(
                                        color: const Color(0xFF6FA8DC),
                                        width: 3,
                                      )
                                          : null,
                                      boxShadow: isSelected
                                          ? [
                                        BoxShadow(
                                          color: const Color(0xFF6FA8DC)
                                              .withOpacity(0.4),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                          : [],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        imageUrl,
                                        height: 110,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 110,
                                          color: const Color(0xFFCCC0B0),
                                          child: const Icon(Icons.landscape,
                                              color: Colors.white54, size: 40),
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

                    // Nature Sounds header
                    Row(
                      children: const [
                        Icon(
                          Icons.music_note,
                          color: Color(0xFF2C1F14),
                          size: 26,
                        ),
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

                    // Sound Pills - first row (3 pills)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: sounds.map((sound) {
                        final isSelected = selectedSound == sound;
                        final isWide = sound == "Silence";

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSound = sound;
                            });
                          },
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
                              child: Text(
                                sound,
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
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Apply Settings Button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mood settings saved 🌿"),
                      backgroundColor: Color(0xFF556B2F),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B5C3E),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B5C3E).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
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