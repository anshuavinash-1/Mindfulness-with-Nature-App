import 'package:flutter/material.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

<<<<<<< HEAD
  final List<Map<String, dynamic>> posts = const [
    {
      'name': 'Emma',
      'time': '2h ago',
      'content': 'A peaceful spot found today while hiking',
      'color': Color(0xFF7A9F5A),
      'images': [
        'https://images.unsplash.com/photo-1448375240586-882707db888b?w=300&q=80',
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=300&q=80',
      ],
    },
    {
      'name': 'Alex',
      'time': '5 minutes ago',
      'content': 'Kayaking Day!!',
      'color': Color(0xFF94B447),
      'images': [
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300&q=80',
        'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=300&q=80',
      ],
    },
    {
      'name': 'Sophia',
      'time': '1d ago',
      'content': 'Morning sunrise meditation spot',
      'color': Color(0xFFB89C63),
      'images': [
        'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=300&q=80',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6CBC0),
      body: Column(
        children: [
          // MAP at top - takes ~40% of screen
          Expanded(flex: 4, child: _buildMapWidget()),

          // Scrollable content below
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Where do you find peace?",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1F14),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Add Favorite Place Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B5C3E),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6B5C3E).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Add favorite place",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Community Posts
                  ...posts.map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: _buildPost(post),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
=======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdde3c2),
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      "Where do you find peace?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374834),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Add Favorite Place Card
                    GestureDetector(
                      onTap: () {
                        // Navigate to add place screen
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF556B2F),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF556B2F).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add a favorite place",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Share your peaceful spot with the community",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Community Posts Title
                    const Text(
                      "Community Shares",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374834),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Community Posts List
                    _buildCommunityPost(
                      name: "Emma",
                      content: "A peaceful spot i found while hiking today",
                      time: "2h ago",
                      likes: 12,
                      comments: 3,
                      userColor: const Color(0xFF7A9F5A),
                    ),
                    const SizedBox(height: 20),
                    _buildCommunityPost(
                      name: "Caleb",
                      content: "Still water and still mind",
                      time: "6h ago",
                      likes: 24,
                      comments: 5,
                      userColor: const Color(0xFF374834),
                    ),
                    const SizedBox(height: 20),
                    _buildCommunityPost(
                      name: "Sophia",
                      content: "Morning sunrise meditation spot",
                      time: "1d ago",
                      likes: 42,
                      comments: 8,
                      userColor: const Color(0xFFB89C63),
                    ),
                    const SizedBox(height: 20),
                    _buildCommunityPost(
                      name: "Noah",
                      content: "My secret garden retreat",
                      time: "2d ago",
                      likes: 31,
                      comments: 4,
                      userColor: const Color(0xFF94B447),
                    ),

                    const SizedBox(height: 50), // Space for bottom nav
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
          ],
        ),
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildMapWidget() {
    // Simulate a map with a light green background + location pins
    return Stack(
      children: [
        // Map background - light greenish like OpenStreetMap
        Container(
          color: const Color(0xFFE8F0D8),
          child: CustomPaint(painter: _MapPainter(), size: Size.infinite),
        ),

        // Location pins overlay
        ..._mapPins(),
      ],
    );
  }

  List<Widget> _mapPins() {
    // Approximate pin positions as fractions of the map area
    final pins = [
      const Offset(0.22, 0.28),
      const Offset(0.33, 0.26),
      const Offset(0.42, 0.42),
      const Offset(0.46, 0.50),
      const Offset(0.44, 0.58),
      const Offset(0.74, 0.52),
      const Offset(0.31, 0.68),
    ];

    return pins.map((pos) {
      return Positioned(
        left: MediaQueryData.fromView(
              WidgetsBinding.instance.platformDispatcher.views.first,
            ).size.width *
            pos.dx,
        top: MediaQueryData.fromView(
              WidgetsBinding.instance.platformDispatcher.views.first,
            ).size.height *
            0.4 *
            pos.dy,
        child: const Icon(
          Icons.location_on,
          color: Color(0xFF4A6741),
          size: 28,
          shadows: [
            Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 2)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildPost(Map<String, dynamic> post) {
    final List<String> images = List<String>.from(post['images']);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
=======
  // Build community post
  Widget _buildCommunityPost({
    required String name,
    required String content,
    required String time,
    required int likes,
    required int comments,
    required Color userColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          // Header row
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: post['color'] as Color,
=======
          // User info row
          Row(
            children: [
              // User avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: userColor,
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
<<<<<<< HEAD
                    (post['name'] as String)[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
=======
                    name[0], // First letter of name
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
<<<<<<< HEAD
                      post['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C1F14),
                      ),
                    ),
                    Text(
                      post['time'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9B8E7E),
                      ),
=======
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374834),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
                    ),
                  ],
                ),
              ),
<<<<<<< HEAD
              const Icon(Icons.more_vert, color: Color(0xFF9B8E7E), size: 22),
            ],
          ),

          const SizedBox(height: 12),

          // Post caption
          Text(
            post['content'] as String,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF2C1F14),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Two side-by-side images
          Row(
            children: images.map((url) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: url == images.first ? 6 : 0,
                    left: url == images.last ? 6 : 0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      height: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 130,
                        color: const Color(0xFFCCC0B0),
                        child: const Icon(
                          Icons.landscape,
                          color: Colors.white54,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
=======
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Post content
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF374834),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // Image placeholder (optional)
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xfff3f0d8),
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                image: AssetImage('assets/images/forest_bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.8,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Peaceful Spot",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Actions row
          Row(
            children: [
              // Like button
              _buildActionButton(
                icon: Icons.favorite_outline,
                count: likes,
                onTap: () {},
              ),
              const SizedBox(width: 20),
              // Comment button
              _buildActionButton(
                icon: Icons.comment_outlined,
                count: comments,
                onTap: () {},
              ),
              const Spacer(),
              // Share button
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined, color: Colors.grey),
              ),
            ],
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD
}

// Draws simple map-like road lines
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final minorRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Major roads
    canvas.drawLine(Offset(0, h * 0.45), Offset(w, h * 0.48), roadPaint);
    canvas.drawLine(Offset(w * 0.35, 0), Offset(w * 0.42, h), roadPaint);
    canvas.drawLine(Offset(0, h * 0.65), Offset(w, h * 0.60), roadPaint);
    canvas.drawLine(Offset(w * 0.6, 0), Offset(w * 0.55, h), roadPaint);

    // Minor roads
    canvas.drawLine(Offset(0, h * 0.25), Offset(w, h * 0.28), minorRoadPaint);
    canvas.drawLine(Offset(0, h * 0.75), Offset(w, h * 0.78), minorRoadPaint);
    canvas.drawLine(Offset(w * 0.15, 0), Offset(w * 0.18, h), minorRoadPaint);
    canvas.drawLine(Offset(w * 0.75, 0), Offset(w * 0.72, h), minorRoadPaint);
    canvas.drawLine(
      Offset(0, h * 0.55),
      Offset(w * 0.35, h * 0.50),
      minorRoadPaint,
    );
    canvas.drawLine(
      Offset(w * 0.42, h * 0.48),
      Offset(w, h * 0.55),
      minorRoadPaint,
    );

    // Diagonal connector
    canvas.drawLine(
      Offset(w * 0.15, h * 0.25),
      Offset(w * 0.35, h * 0.45),
      minorRoadPaint,
    );
    canvas.drawLine(
      Offset(w * 0.42, h * 0.50),
      Offset(w * 0.60, h * 0.62),
      minorRoadPaint,
    );
  }

  @override
  bool shouldRepaint(_MapPainter old) => false;
=======

  // Build action button
  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
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
>>>>>>> 00bfcfa0476953464afcd2ade303665076339ac7
}
