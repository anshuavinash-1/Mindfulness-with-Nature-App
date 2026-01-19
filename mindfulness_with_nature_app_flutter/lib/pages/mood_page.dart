import 'package:flutter/material.dart';

class MoodSettingsPage extends StatefulWidget {
  const MoodSettingsPage({super.key});

  @override
  State<MoodSettingsPage> createState() => _MoodSettingsPageState();
}

class _MoodSettingsPageState extends State<MoodSettingsPage> {
  final List<String> backgrounds = ["Forest", "Ocean", "Meadow"];
  String? selectedBackground;

  final List<String> sounds = ["Birdsong", "Waves", "Breeze", "Silence"];
  String? selectedSound;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffeef3e6),
              Color(0xffdde3c2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new),
                  color: const Color(0xFF374834),
                ),

                const SizedBox(height: 16),

                // Title
                const Text(
                  "Set Your Mood",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F3E2F),
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Personalize your meditation environment",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7A63),
                  ),
                ),

                const SizedBox(height: 32),

                // Background Section
                _buildCard(
                  icon: Icons.landscape_outlined,
                  title: "Background",
                  subtitle: "Choose a calming visual",
                  child: _buildChips(
                    options: backgrounds,
                    selectedValue: selectedBackground,
                    onSelected: (val) =>
                        setState(() => selectedBackground = val),
                  ),
                ),

                const SizedBox(height: 24),

                // Sound Section
                _buildCard(
                  icon: Icons.music_note_outlined,
                  title: "Nature Sound",
                  subtitle: "Pick a sound that relaxes you",
                  child: _buildChips(
                    options: sounds,
                    selectedValue: selectedSound,
                    onSelected: (val) => setState(() => selectedSound = val),
                  ),
                ),

                const SizedBox(height: 40),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Mood settings saved 🌿"),
                          backgroundColor: Color(0xFF556B2F),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: const Color(0xFF556B2F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      "Apply Settings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // Reusable Card Widget
  // ----------------------------
  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF556B2F)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374834),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF6B7A63),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ----------------------------
  // Animated Choice Chips
  // ----------------------------
  Widget _buildChips({
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((label) {
        final isSelected = selectedValue == label;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onSelected(label),
            selectedColor: const Color(0xFF556B2F),
            backgroundColor: const Color(0xfff3f0d8),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }).toList(),
    );
  }
}
