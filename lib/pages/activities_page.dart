import 'dart:async';
import 'package:flutter/material.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  // Activities list
  final List<String> activities = [
    "Being Present",
    "Feeling Lighter",
    "Connecting with Nature",
    "Gratitude",
    "Gentle Movements",
    "Feeling Grounded",
    "Joyfulness",
    "Playfulness",
    "Practice Indoors",
  ];

  String? selectedActivity;

  // Slider state
  double duration = 20; // default
  Timer? timer;
  int remainingSeconds = 1200;

  @override
  void initState() {
    super.initState();
    remainingSeconds = (duration * 60).toInt();
  }

  void startSession() {
    timer?.cancel();
    remainingSeconds = (duration * 60).toInt();

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (remainingSeconds <= 0) {
        timer?.cancel();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });

    setState(() {});
  }

  String formatTime(int sec) {
    final min = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return "$min:$s";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xffdde3c2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Activities",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374834),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "What do you need today?",
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF374834),
                ),
              ),

              const SizedBox(height: 20),

              // -------------------------
              // Activity Chips
              // -------------------------
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: activities.map((label) {
                  bool isSelected = selectedActivity == label;

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
                      setState(() => selectedActivity = label);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Duration label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Duration",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF374834),
                  ),
                ),
              ),

              // Slider
              Slider(
                value: duration,
                min: 5,
                max: 45,
                activeColor: const Color(0xFF374834),
                onChanged: (value) {
                  setState(() {
                    duration = value;
                    remainingSeconds = (duration * 60).toInt();
                  });
                },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("5 MIN"),
                  Text("45 MIN"),
                ],
              ),

              const SizedBox(height: 20),

              // -------------------------
              // Timer Box
              // -------------------------
              Container(
                width: size.width,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: const Color(0xfff3f0d8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(Icons.hourglass_bottom,
                        size: 80, color: const Color(0xFF374834)),
                    const SizedBox(height: 10),
                    Text(
                      formatTime(remainingSeconds),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374834),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // -------------------------
              // Start Button
              // -------------------------
              GestureDetector(
                onTap: startSession,
                child: Container(
                  width: size.width * 0.8,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF556B2F),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "Start Session",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
