import 'package:flutter/material.dart';

class StoriesPage extends StatelessWidget {
  const StoriesPage({super.key});

  final List<StoryCategory> categories = const [
    StoryCategory(
      title: 'Indigenous Nature Tales',
      subtitle: 'Ancient wisdom from native cultures',
      color: Color(0xFF556B2F),
    ),
    StoryCategory(
      title: 'Animal Fables',
      subtitle: 'Moral stories with animal characters',
      color: Color(0xFF7A9F5A),
    ),
    StoryCategory(
      title: 'Nordic Tales',
      subtitle: 'Myths from the northern lands',
      color: Color(0xFF374834),
    ),
    StoryCategory(
      title: 'Jungle Stories',
      subtitle: 'Adventures in the rainforest',
      color: Color(0xFF94B447),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdde3c2),
      appBar: AppBar(
        title: const Text('Nature Tales & Sleep Stories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _StoryCard(category: categories[index]);
          },
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.category});

  final StoryCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: category.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            category.icon,
            color: Colors.white,
            size: 36,
          ),
          const Spacer(),
          Text(
            category.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class StoryCategory {
  const StoryCategory({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  IconData get icon {
    if (title.contains('Animal')) return Icons.pets;
    if (title.contains('Nordic')) return Icons.nightlight_round;
    if (title.contains('Jungle')) return Icons.park;
    return Icons.auto_stories;
  }
}