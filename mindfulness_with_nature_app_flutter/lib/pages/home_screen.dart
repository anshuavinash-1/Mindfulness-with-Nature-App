import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../service/auth_service.dart';
import 'my_account_page.dart';
import 'stories.dart';
import 'progress_page.dart';

/// HomeScreen - Main landing page for the mindfulness app
///
/// Displays personalized greeting, featured practice, and navigation
/// to key features like progress tracking and nature stories.
/// Responsive design adapts to mobile, tablet, and web layouts.
class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Slide up animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Particle animation (continuous)
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  // Design constants
  static const double _cardElevation = 15.0;
  static const double _borderRadius = 20.0;
  static const double _buttonBorderRadius = 50.0;
  static const double _mobilePaddingPercent = 0.05;
  static const double _mobileWidthPercent = 0.8;
  static const double _desktopWidthPercent = 0.4;
  static const int _responsiveBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= _responsiveBreakpoint;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildOverlay(),
          _buildFloatingParticles(size),
          _buildContent(context, size, isDesktop),
          _buildTopBar(),
        ],
      ),
    );
  }

  /// Top bar with menu button
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Menu button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),

              // Notification button (optional)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () {
                    debugPrint("Notifications clicked");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Drawer menu with account options
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1A2F1A),
      child: Column(
        children: [
          // Header with user profile
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF7A9F5A),
                  const Color(0xFF556B2F),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile picture
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),

                // User name
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),

                // User email or subtitle
                Text(
                  'Mindfulness Journey',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'My Account',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToMyAccount();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToEditProfile();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToChangePassword();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToNotifications();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.analytics_outlined,
                  title: 'My Progress',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToProgress(context);
                  },
                ),
                const Divider(color: Colors.white24, thickness: 1),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToSettings();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToHelp();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAbout();
                  },
                ),
                const Divider(color: Colors.white24, thickness: 1),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  textColor: const Color(0xFFE57373),
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog();
                  },
                ),
              ],
            ),
          ),

          // App version
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Drawer menu item
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Colors.white,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      dense: true,
    );
  }

  /// Background image layer with blur effect
  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Image.asset(
          "assets/images/forest_bg.jpg",
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2D4A2B),
                    Color(0xFF1A2F1A),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(Icons.image_not_supported, color: Colors.white54),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Semi-transparent overlay for better text readability
  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.1),
            Colors.black.withOpacity(0.3),
          ],
        ),
      ),
    );
  }

  /// Floating particles animation (leaves, flowers, sparkles)
  Widget _buildFloatingParticles(Size size) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final random = math.Random(index);
            final offsetX = random.nextDouble() * size.width;
            final offsetY = ((_particleController.value + random.nextDouble()) % 1.0) * size.height;
            final particleSize = 20.0 + random.nextDouble() * 30;
            final opacity = 0.3 + random.nextDouble() * 0.4;

            return Positioned(
              left: offsetX,
              top: offsetY,
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: _particleController.value * 2 * math.pi + index,
                  child: Icon(
                    _getRandomParticleIcon(index),
                    size: particleSize,
                    color: _getRandomParticleColor(index),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  IconData _getRandomParticleIcon(int seed) {
    final icons = [
      Icons.local_florist,
      Icons.eco,
      Icons.spa,
      Icons.filter_vintage,
      Icons.stars,
    ];
    return icons[seed % icons.length];
  }

  Color _getRandomParticleColor(int seed) {
    final colors = [
      Colors.white.withOpacity(0.6),
      const Color(0xFFB89C63).withOpacity(0.6),
      const Color(0xFF94B447).withOpacity(0.6),
      const Color(0xFF7A9F5A).withOpacity(0.6),
    ];
    return colors[seed % colors.length];
  }

  /// Main content area
  Widget _buildContent(BuildContext context, Size size, bool isDesktop) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * _mobilePaddingPercent,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 70), // Space for top bar
                    _buildAppTitle(),
                    const SizedBox(height: 10),
                    _buildGreeting(size, isDesktop),
                    const SizedBox(height: 10),
                    _buildFeaturedPracticeCard(size, isDesktop),
                    const SizedBox(height: 10),
                    _buildProgressButton(context, size, isDesktop),
                    const SizedBox(height: 20),
                    _buildStoriesButton(context, size, isDesktop),
                    const SizedBox(height: 20),
                    _buildQuickAccessGrid(context, size, isDesktop),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// App title text with glow effect
  Widget _buildAppTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.nature,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 10),
          Text(
            "Mindfulness with Nature",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Personalized greeting message with shimmer effect
  Widget _buildGreeting(Size size, bool isDesktop) {
    return Column(
      children: [
        Text(
          _getGreeting(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: isDesktop ? 20 : 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 10),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFFFD700),
              Colors.white,
            ],
          ).createShader(bounds),
          child: Text(
            widget.userName.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 52 : 38,
              fontWeight: FontWeight.bold,
              height: 1.2,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  /// Featured practice card with animated border
  Widget _buildFeaturedPracticeCard(Size size, bool isDesktop) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Container(
            width: isDesktop ? size.width * 0.5 : size.width * 0.85,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.6),
                  const Color(0xFFB89C63).withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFB89C63),
                borderRadius: BorderRadius.circular(_borderRadius - 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wb_sunny,
                        color: Colors.white.withOpacity(0.9),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Today's Featured Practice",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    "Grounding in Nature",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "15 min • Beginner Friendly",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Progress tracking button with hover effect
  Widget _buildProgressButton(BuildContext context, Size size, bool isDesktop) {
    return _AnimatedButton(
      onTap: () => _navigateToProgress(context),
      child: Container(
        width: isDesktop
            ? size.width * _desktopWidthPercent
            : size.width * _mobileWidthPercent,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 24,
        ),
        decoration: _buildGradientDecoration(
          colors: const [Color(0xFF7A9F5A), Color(0xFF556B2F)],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProgressPage(),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconCircle(Icons.spa, size: 50),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Track Your",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Progress",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatsPreview(),
            ],
          ),
        ),

      ),
    );
  }

  /// Stories navigation button
  Widget _buildStoriesButton(BuildContext context, Size size, bool isDesktop) {
    return _AnimatedButton(
      onTap: () => _navigateToStories(context),
      child: Container(
        width: isDesktop
            ? size.width * _desktopWidthPercent
            : size.width * _mobileWidthPercent,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 24,
        ),
        decoration: _buildGradientDecoration(
          colors: const [Color(0xFF556B2F), Color(0xFF374834)],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoriesPage(),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_stories,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nature Tales &",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Sleep Stories",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildIconCircle(Icons.arrow_forward, size: 40, iconSize: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Quick access grid for additional features
  Widget _buildQuickAccessGrid(BuildContext context, Size size, bool isDesktop) {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      alignment: WrapAlignment.center,
      children: [
        _buildQuickAccessCard(
          icon: Icons.favorite,
          title: "Wellness",
          color: const Color(0xFFE57373),
          onTap: () {},
        ),
        _buildQuickAccessCard(
          icon: Icons.self_improvement,
          title: "Meditate",
          color: const Color(0xFF81C784),
          onTap: () {},
        ),
        _buildQuickAccessCard(
          icon: Icons.music_note,
          title: "Sounds",
          color: const Color(0xFF64B5F6),
          onTap: () {},
        ),
        _buildQuickAccessCard(
          icon: Icons.calendar_today,
          title: "Daily",
          color: const Color(0xFFFFB74D),
          onTap: () {},
        ),
        _buildQuickAccessCard(
          icon: Icons.play_circle_outline,
          title: "Videos",
          color: const Color(0xFFE57373),
          onTap: () {
            debugPrint("Navigate to Videos");
          },
        ),
        _buildQuickAccessCard(
          icon: Icons.event_available,
          title: "Book Session",
          color: const Color(0xFF64B5F6),
          onTap: () {
            debugPrint("Navigate to Book Session");
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _AnimatedButton(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable gradient button decoration
  BoxDecoration _buildGradientDecoration({required List<Color> colors}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(_buttonBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: _cardElevation,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: colors.first.withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
      border: Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1.5,
      ),
    );
  }

  /// Circular icon container
  Widget _buildIconCircle(IconData icon, {
    required double size,
    double? iconSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize ?? 28,
      ),
    );
  }

  /// Progress stats preview badge
  Widget _buildStatsPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Column(
        children: [
          Text(
            "7",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "days",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToProgress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressPage(),
      ),
    );
  }

  void _navigateToStories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoriesPage(),
      ),
    );
  }

  void _navigateToMyAccount() {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyAccountPage(
          userName: user?.displayName ?? widget.userName,
          email: user?.email ?? "user@email.com", // use real data if available
        ),
      ),
    );
  }


  void _navigateToEditProfile() {
    debugPrint("Navigate to Edit Profile");
    // TODO: Navigate to Edit Profile page
  }

  void _navigateToChangePassword() {
    debugPrint("Navigate to Change Password");
    // TODO: Navigate to Change Password page
  }

  void _navigateToNotifications() {
    debugPrint("Navigate to Notifications");
    // TODO: Navigate to Notifications page
  }

  void _navigateToSettings() {
    debugPrint("Navigate to Settings");
    // TODO: Navigate to Settings page
  }

  void _navigateToHelp() {
    debugPrint("Navigate to Help & Support");
    // TODO: Navigate to Help page
  }

  void _navigateToAbout() {
    debugPrint("Navigate to About");
    // TODO: Navigate to About page
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2F1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              debugPrint("User logged out");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

/// Animated button widget with scale effect
class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedButton({
  required this.child,
    required this.onTap,
  });
  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}
class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}