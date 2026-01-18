import 'package:flutter/material.dart';

class StoriesPage extends StatelessWidget {
  StoriesPage({super.key});

  final List<StoryCategory> categories = [
    StoryCategory(
      title: "Indigenous Nature Tales",
      subtitle: "Ancient wisdom from native cultures",
      color: Color(0xFF556B2F),
    ),
    StoryCategory(
      title: "Animal Fables",
      subtitle: "Moral stories with animal characters",
      color: Color(0xFF7A9F5A),
    ),
    StoryCategory(
      title: "Nordic Tales",
      subtitle: "Myths from the northern lands",
      color: Color(0xFF374834),
    ),
    StoryCategory(
      title: "Jungle Stories",
      subtitle: "Adventures in the rainforest",
      color: Color(0xFF94B447),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdde3c2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
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
                    "Nature Tales & Sleep Stories",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374834),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Relaxing stories to help you unwind and sleep better",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374834),
                    ),
                  ),
                ],
              ),
            ),

            // Stories Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return _buildStoryCard(categories[index]);
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Bottom Navigation Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xfff3f0d8),
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(icon: Icons.home, label: "Home", isActive: false),
                  _buildNavItem(icon: Icons.spa, label: "Activities", isActive: false),
                  _buildNavItem(icon: Icons.nature, label: "Set Your Mood", isActive: false),
                  _buildNavItem(icon: Icons.insights, label: "Transformation", isActive: false),
                  _buildNavItem(icon: Icons.people, label: "Community", isActive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build story card
  Widget _buildStoryCard(StoryCategory category) {
    return GestureDetector(
      onTap: () {
        // Navigate to stories list page for this category
      },
      child: Container(
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/pattern.jpg'), // Add your pattern image
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon based on category
                  Icon(
                    _getCategoryIcon(category.title),
                    color: Colors.white.withOpacity(0.9),
                    size: 40,
                  ),

                  const Spacer(),

                  // Title
                  Text(
                    category.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    category.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Play Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "Listen",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get appropriate icon for each category
  IconData _getCategoryIcon(String title) {
    if (title.contains("Indigenous")) {
      return Icons.landscape;
    } else if (title.contains("Animal")) {
      return Icons.pets;
    } else if (title.contains("Nordic")) {
      return Icons.ac_unit;
    } else if (title.contains("Jungle")) {
      return Icons.park;
    }
    return Icons.book;
  }

  // Helper method to build navigation item
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

class StoryCategory {
  final String title;
  final String subtitle;
  final Color color;

  StoryCategory({
    required this.title,
    required this.subtitle,
    required this.color,
  });
}