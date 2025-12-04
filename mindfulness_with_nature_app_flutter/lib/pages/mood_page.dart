import 'package:flutter/material.dart';

class MoodSettingsPage extends StatefulWidget {
  const MoodSettingsPage({super.key});

  @override
  State<MoodSettingsPage> createState() => _MoodSettingsPageState();
}

class _MoodSettingsPageState extends State<MoodSettingsPage> {
  // Background image selection
  final List<String> backgrounds = ["Forest", "Ocean", "Meadow"];
  String? selectedBackground;

  // Nature sound selection
  final List<String> sounds = ["Birdsong", "Waves", "Breeze", "Silence"];
  String? selectedSound;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdde3c2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF374834),
                  size: 28,
                ),
              ),

              const SizedBox(height: 10),

              // Title
              const Text(
                "Set Your Mood",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374834),
                ),
              ),

              const SizedBox(height: 30),

              // -------------------------
              // Background Image Section
              // -------------------------
              const Text(
                "Background Image",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374834),
                ),
              ),

              const SizedBox(height: 15),

              // Background selection chips
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: backgrounds.map((label) {
                  bool isSelected = selectedBackground == label;

                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                    selectedColor: const Color(0xFF556B2F),
                    backgroundColor: const Color(0xfff3f0d8),
                    onSelected: (_) {
                      setState(() => selectedBackground = label);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // -------------------------
              // Nature Sound Section
              // -------------------------
              const Text(
                "Nature Sound",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374834),
                ),
              ),

              const SizedBox(height: 15),

              // Sound selection chips
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: sounds.map((label) {
                  bool isSelected = selectedSound == label;

                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                    selectedColor: const Color(0xFF556B2F),
                    backgroundColor: const Color(0xfff3f0d8),
                    onSelected: (_) {
                      setState(() => selectedSound = label);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 50),

              // -------------------------
              // Apply Button
              // -------------------------
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Handle apply settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings saved successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF556B2F),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Text(
                        "Apply Settings",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}