import 'package:flutter/material.dart';

class TransformationPage extends StatefulWidget {
  const TransformationPage({super.key});

  @override
  State<TransformationPage> createState() => _TransformationPageState();
}

class _TransformationPageState extends State<TransformationPage> {
  // Values for progress bars
  double stressBefore = 5.0;
  double moodBefore = 5.0;
  double stressAfter = 5.0;
  double moodAfter = 5.0;

  // Chart data
  List<double> stressData = [8.0, 6.5, 5.0, 4.0, 3.5, 3.0];
  List<double> moodData = [3.0, 5.0, 6.0, 7.0, 7.5, 8.0];
  List<String> dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  // Chart interaction state
  int? selectedStressIndex;
  int? selectedMoodIndex;
  String selectedChartType = 'stress'; // 'stress' or 'mood'

  @override
  Widget build(BuildContext context) {
    List<double> activeData = selectedChartType == 'stress' ? stressData : moodData;
    int? selectedIndex = selectedChartType == 'stress' ? selectedStressIndex : selectedMoodIndex;

    return Scaffold(
      backgroundColor: const Color(0xffdde3c2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                "My Transformation",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374834),
                ),
              ),

              const SizedBox(height: 10),

              // -------------------------
              // Before Practice Section
              // -------------------------
              _buildSection(
                title: "How do you feel before your practice?",
                children: [
                  const SizedBox(height: 10),

                  // Stress Level - PROGRESS BAR
                  _buildProgressBarQuestion(
                    title: "How stressed do you feel?",
                    value: stressBefore,
                    minLabel: "Low",
                    maxLabel: "High",
                    onChanged: (value) {
                      setState(() {
                        stressBefore = value;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // Mood Level - PROGRESS BAR
                  _buildProgressBarQuestion(
                    title: "How is your mood?",
                    value: moodBefore,
                    minLabel: "Low",
                    maxLabel: "High",
                    onChanged: (value) {
                      setState(() {
                        moodBefore = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // -------------------------
              // After Practice Section
              // -------------------------
              _buildSection(
                title: "How do you feel after your practice?",
                children: [
                  const SizedBox(height: 10),

                  // Stress Level After - PROGRESS BAR
                  _buildProgressBarQuestion(
                    title: "How stressed do you feel now?",
                    value: stressAfter,
                    minLabel: "Low",
                    maxLabel: "High",
                    onChanged: (value) {
                      setState(() {
                        stressAfter = value;
                        // Add new data point when after rating is set
                        if (stressData.length < 10) {
                          double reduction = (stressBefore - stressAfter).clamp(1, 10).toDouble();
                          stressData.add(reduction);
                          moodData.add(moodAfter);
                          dayLabels.add('Today');
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // Mood Level After - PROGRESS BAR
                  _buildProgressBarQuestion(
                    title: "How is your mood now?",
                    value: moodAfter,
                    minLabel: "Low",
                    maxLabel: "High",
                    onChanged: (value) {
                      setState(() {
                        moodAfter = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // -------------------------
              // Charts Section
              // -------------------------
              _buildSection(
                title: "Progress Over Time",
                children: [
                  const SizedBox(height: 10),

                  // Chart Type Selector
                  Row(
                    children: [
                      Expanded(
                        child: _buildChartTypeCard(
                          title: "Stress Over Time",
                          isActive: selectedChartType == 'stress',
                          onTap: () {
                            setState(() {
                              selectedChartType = 'stress';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildChartTypeCard(
                          title: "Mood Over Time",
                          isActive: selectedChartType == 'mood',
                          onTap: () {
                            setState(() {
                              selectedChartType = 'mood';
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Dynamic Chart
                  _buildInteractiveChart(
                    data: activeData,
                    labels: dayLabels,
                    selectedIndex: selectedIndex,
                    chartType: selectedChartType,
                    onBarTap: (index) {
                      setState(() {
                        if (selectedChartType == 'stress') {
                          selectedStressIndex =
                          selectedStressIndex == index ? null : index;
                        } else {
                          selectedMoodIndex =
                          selectedMoodIndex == index ? null : index;
                        }
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build section container
  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xfff3f0d8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374834),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // Helper method to build PROGRESS BAR question
  Widget _buildProgressBarQuestion({
    required String title,
    required double value,
    required String minLabel,
    required String maxLabel,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374834),
          ),
        ),
        const SizedBox(height: 15),

        // Progress Bar Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              // Value indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF556B2F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Slider
              Slider(
                value: value,
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: const Color(0xFF556B2F),
                inactiveColor: Colors.grey[300],
                thumbColor: const Color(0xFF374834),
                onChanged: onChanged,
              ),

              const SizedBox(height: 8),

              // Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    minLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    maxLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to build chart type card
  Widget _buildChartTypeCard({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF556B2F) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF556B2F),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              color: isActive ? Colors.white : const Color(0xFF556B2F),
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF374834),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build interactive chart
  Widget _buildInteractiveChart({
    required List<double> data,
    required List<String> labels,
    required int? selectedIndex,
    required String chartType,
    required Function(int) onBarTap,
  }) {
    double maxValue = data.reduce((a, b) => a > b ? a : b);
    double maxBarHeight = 120;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Chart Title
          Text(
            selectedChartType == 'stress' ? "Stress Over Time" : "Mood Over Time",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374834),
            ),
          ),
          const SizedBox(height: 20),

          // Bars Container
          SizedBox(
            height: maxBarHeight + 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(data.length, (index) {
                double value = data[index];
                double barHeight = (value / maxValue) * maxBarHeight;
                bool isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () => onBarTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Value label (only show when selected)
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: chartType == 'stress' ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isSelected) const SizedBox(height: 8),

                      // Bar
                      Container(
                        width: 30,
                        height: barHeight,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (chartType == 'stress' ? Colors.red : Colors.green)
                              : (chartType == 'stress'
                              ? Colors.red.withOpacity(0.6)
                              : Colors.green.withOpacity(0.6)),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ),

                      // Day label
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? const Color(0xFF556B2F) : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: chartType == 'stress' ? Colors.red : Colors.green,
                label: chartType == 'stress' ? "Stress Level" : "Mood Level",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build legend item
  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}