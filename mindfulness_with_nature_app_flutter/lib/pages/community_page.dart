import 'package:flutter/material.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

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
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
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
      ),
    );
  }

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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              // User avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: userColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name[0], // First letter of name
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
          Icon(
            icon,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
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
}
