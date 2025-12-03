import 'package:flutter/material.dart';

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
        ),
      ),
    );
  }

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
          ),
        ],
      ),
      child: Column(
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
          ),
        ],
      ),
    );
  }

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
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xfff3f0d8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF556B2F),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
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
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
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
          _buildNavItem(icon: Icons.home, label: "Home", isActive: activeIndex == 0),
          _buildNavItem(icon: Icons.spa, label: "Activities", isActive: activeIndex == 1),
          _buildNavItem(icon: Icons.nature, label: "Set Your Mood", isActive: activeIndex == 2),
          _buildNavItem(icon: Icons.insights, label: "Transformation", isActive: activeIndex == 3),
          _buildNavItem(icon: Icons.people, label: "Community", isActive: activeIndex == 4),
        ],
      ),
    );
  }

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
}