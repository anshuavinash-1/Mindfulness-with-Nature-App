import 'package:flutter/material.dart';

<<<<<<< HEAD
class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  double moodLevel1 = 3;
  double moodLevel2 = 2;
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> recentActivities = [
    {
      'title': 'Morning Meditation',
      'duration': '10 minutes',
      'time': 'Today , 8:00 AM',
    },
    {
      'title': 'Focus Session',
      'duration': '20 minutes',
      'time': 'Yesterday, 10:00 AM',
    },
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6CBC0),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Title
              const Center(
                child: Text(
                  "Progress",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C1F14),
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Mood Card
              _buildMoodCard(),

              const SizedBox(height: 20),

              // Great Start Card
              _buildGreatStartCard(),

              const SizedBox(height: 28),

              // Recent Activity
              const Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C1F14),
                ),
              ),

              const SizedBox(height: 14),

              ...recentActivities
                  .map((activity) => _buildActivityCard(activity)),

              const SizedBox(height: 20),
            ],
          ),
=======
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdde3c2),
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar (Simulated)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      "Progress",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374834),
                      ),
                    ),

                    const SizedBox(height: 30),
                    // Recent Activity Title
                    const Text(
                      "Recent Activity",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374834),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Recent Activity List
                    _buildActivityItem(
                      activity: "Grounding in Nature",
                      duration: "20 min",
                      time: "Today, 9:00 AM",
                      icon: Icons.nature,
                    ),
                    const SizedBox(height: 15),
                    _buildActivityItem(
                      activity: "Feeling Lighter",
                      duration: "15 min",
                      time: "Yesterday, 8:30 PM",
                      icon: Icons.cloud,
                    ),
                    const SizedBox(height: 15),
                    _buildActivityItem(
                      activity: "Gratitude Practice",
                      duration: "10 min",
                      time: "Yesterday, 2:00 PM",
                      icon: Icons.favorite,
                    ),
                    const SizedBox(height: 20),

                    // Progress Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _buildStatCard(
                          value: "7",
                          label: "Days Practiced",
                          color: const Color(0xFF556B2F),
                        ),

                        _buildStatCard(
                          value: "15",
                          label: "Sessions Completed",
                          color: const Color(0xFF7A9F5A),
                        ),
                        _buildStatCard(
                          value: "150",
                          label: "Minutes Practiced",
                          color: const Color(0xFF374834),
                          span: 2,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    const SizedBox(height: 50), // Space for bottom nav
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            _buildBottomNavigationBar(activeIndex: 3),
          ],
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildMoodCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
=======
  // Build stat card
  Widget _buildStatCard({
    required String value,
    required String label,
    required Color color,
    int span = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
          ),
        ],
      ),
      child: Column(
<<<<<<< HEAD
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "How are you feeling?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C1F14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Two sliders + chart side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: sliders + notes
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mood Level: ${moodLevel1.toInt()}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C1F14),
                      ),
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: const Color(0xFF5B4FCF),
                        inactiveTrackColor: const Color(0xFFCCC0B0),
                        thumbColor: const Color(0xFF5B4FCF),
                        overlayColor: const Color(0xFF5B4FCF).withOpacity(0.15),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: moodLevel1,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        onChanged: (v) => setState(() => moodLevel1 = v),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Mood Level: ${moodLevel2.toInt()}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C1F14),
                      ),
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: const Color(0xFF5B4FCF),
                        inactiveTrackColor: const Color(0xFFCCC0B0),
                        thumbColor: const Color(0xFF5B4FCF),
                        overlayColor: const Color(0xFF5B4FCF).withOpacity(0.15),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: moodLevel2,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        onChanged: (v) => setState(() => moodLevel2 = v),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Notes field
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: "Notes\n(Optional)",
                          hintStyle: TextStyle(
                            color: Color(0xFFAA9E90),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2C1F14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right: mini chart
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildMiniChart(),
                    const SizedBox(height: 12),
                    // Save Entry button
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Entry saved! 🌿"),
                            backgroundColor: Color(0xFF556B2F),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B5C3E),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            "Save Entry",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
=======
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildMiniChart() {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: _MoodChartPainter(mood1: moodLevel1, mood2: moodLevel2),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildGreatStartCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
=======
  // Build activity item
  Widget _buildActivityItem({
    required String activity,
    required String duration,
    required String time,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
          ),
        ],
      ),
      child: Row(
        children: [
<<<<<<< HEAD
          // Trophy emoji
          const Text("🏆", style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Great Start!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C1F14),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Start your first meditation session to begin your journey!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B5C3E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Meditation silhouette icon
          const Icon(
            Icons.self_improvement,
            size: 44,
            color: Color(0xFF2C1F14),
          ),
          const SizedBox(width: 14),
=======
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xfff3f0d8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF556B2F), size: 28),
          ),
          const SizedBox(width: 16),
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
<<<<<<< HEAD
                  activity['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C1F14),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  activity['duration'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B5C3E),
                  ),
=======
                  activity,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374834),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$duration • $time",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
                ),
              ],
            ),
          ),
<<<<<<< HEAD
          Text(
            activity['time'],
            style: const TextStyle(fontSize: 13, color: Color(0xFF9B8E7E)),
=======
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  // Build bottom navigation bar
  Widget _buildBottomNavigationBar({required int activeIndex}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff3f0d8),
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: "Home",
            isActive: activeIndex == 0,
          ),
          _buildNavItem(
            icon: Icons.spa,
            label: "Activities",
            isActive: activeIndex == 1,
          ),
          _buildNavItem(
            icon: Icons.nature,
            label: "Set Your Mood",
            isActive: activeIndex == 2,
          ),
          _buildNavItem(
            icon: Icons.insights,
            label: "Transformation",
            isActive: activeIndex == 3,
          ),
          _buildNavItem(
            icon: Icons.people,
            label: "Community",
            isActive: activeIndex == 4,
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD
}

class _MoodChartPainter extends CustomPainter {
  final double mood1;
  final double mood2;

  _MoodChartPainter({required this.mood1, required this.mood2});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 20.0;
    const rightPad = 8.0;
    const topPad = 16.0;
    const bottomPad = 20.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    // Title
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: "Your Mood History",
        style: TextStyle(fontSize: 9, color: Color(0xFF6B5C3E)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    titlePainter.paint(canvas, Offset(leftPad, 2));

    // Y-axis labels (1-5)
    final labelStyle = const TextStyle(fontSize: 8, color: Color(0xFF9B8E7E));
    for (int i = 1; i <= 5; i++) {
      final y = topPad + chartH - ((i - 1) / 4) * chartH;
      final lp = TextPainter(
        text: TextSpan(text: '$i', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      lp.paint(canvas, Offset(0, y - 5));
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE0D8CC)
      ..strokeWidth = 0.5;
    for (int i = 1; i <= 5; i++) {
      final y = topPad + chartH - ((i - 1) / 4) * chartH;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        gridPaint,
      );
    }

    // Sample data points for 5 dates
    final redData = [2.0, 3.5, 5.0, 4.5, 3.0];
    final greenData = [1.5, 2.0, 2.5, 2.0, 2.0];

    // Override last point with current slider values
    final red = List<double>.from(redData);
    final green = List<double>.from(greenData);
    red[4] = mood1.clamp(1.0, 5.0);
    green[4] = mood2.clamp(1.0, 5.0);

    final xStep = chartW / (red.length - 1);

    double yPos(double val) => topPad + chartH - ((val - 1) / 4) * chartH;

    // Draw red line
    final redPaint = Paint()
      ..color = const Color(0xFFE57373)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final redPath = Path();
    for (int i = 0; i < red.length; i++) {
      final x = leftPad + i * xStep;
      final y = yPos(red[i]);
      if (i == 0) {
        redPath.moveTo(x, y);
      } else {
        redPath.lineTo(x, y);
      }
    }
    canvas.drawPath(redPath, redPaint);

    // Draw green line
    final greenPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final greenPath = Path();
    for (int i = 0; i < green.length; i++) {
      final x = leftPad + i * xStep;
      final y = yPos(green[i]);
      if (i == 0) {
        greenPath.moveTo(x, y);
      } else {
        greenPath.lineTo(x, y);
      }
    }
    canvas.drawPath(greenPath, greenPaint);

    // Dots
    final dotPaintRed = Paint()..color = const Color(0xFFE57373);
    final dotPaintGreen = Paint()..color = const Color(0xFF66BB6A);
    for (int i = 0; i < red.length; i++) {
      final x = leftPad + i * xStep;
      canvas.drawCircle(Offset(x, yPos(red[i])), 3, dotPaintRed);
      canvas.drawCircle(Offset(x, yPos(green[i])), 3, dotPaintGreen);
    }

    // X-axis date labels
    final dates = ['11/08', '11/08', '11/08', '11/08', '11/09'];
    for (int i = 0; i < dates.length; i++) {
      final x = leftPad + i * xStep;
      final dp = TextPainter(
        text: TextSpan(text: dates[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      dp.paint(canvas, Offset(x - dp.width / 2, size.height - bottomPad + 3));
    }
  }

  @override
  bool shouldRepaint(_MoodChartPainter old) =>
      old.mood1 != mood1 || old.mood2 != mood2;
=======

  // Build navigation item
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF556B2F) : Colors.grey[600],
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF556B2F) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
}
