import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/notification_service.dart';
import '../services/app_experience_service.dart';
import 'notification_settings_page.dart';
import 'login_page.dart';
import 'my_profile_page.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _isGuest => widget.userName == 'Guest';

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "GOOD MORNING";
    } else if (hour >= 12 && hour < 17) {
      return "GOOD AFTERNOON";
    } else if (hour >= 17 && hour < 20) {
      return "GOOD EVENING";
    } else {
      return "GOOD NIGHT";
    }
  }

  Widget _buildBackgroundLayer(AppExperienceService appExperience) {
    Widget buildAsset(String path) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        filterQuality: FilterQuality.high,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Keep a visual baseline so loading/decoding hiccups never show a flat screen.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF7E846A), Color(0xFF6A735A)],
            ),
          ),
        ),
        Image.asset(
          appExperience.homeBackgroundAsset,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) {
            return Image.asset(
              'assets/images/splash_bg.jpg',
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            );
          },
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return child;
            }
            return buildAsset('assets/images/pattern.jpg');
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initInBackground();
    });
  }

  Future<void> _initInBackground() async {
    await _precacheImages();
  }

  Future<void> _precacheImages() async {
    await Future.wait([
      precacheImage(const AssetImage('assets/images/sunrise.jpg'), context),
      precacheImage(const AssetImage('assets/images/sunny.jpg'), context),
      precacheImage(const AssetImage('assets/images/sunset.jpg'), context),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _quickToggleReminder(NotificationService service) async {
    if (_isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to enable daily reminders.'),
        ),
      );
      return;
    }

    if (!service.isReminderEnabled && service.reminderTime == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NotificationSettingsPage(isGuest: _isGuest),
        ),
      );
      return;
    }
    if (!service.isReminderEnabled) {
      final granted = await service.requestPermissions();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notification permission is required to enable reminders.',
            ),
          ),
        );
        return;
      }
    }
    await service.setReminderEnabled(!service.isReminderEnabled);
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5F0E8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(
            color: Color(0xFF3D2B1F),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Color(0xFF7A6A5A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF7A6A5A)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _goToLogin();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D2B1F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = context.watch<NotificationService>();
    final appExperience = context.watch<AppExperienceService>();
    final ambientActive = appExperience.selectedSound != 'Silence';

    return Scaffold(
      key: _scaffoldKey,
      drawer: _AppDrawer(
        userName: widget.userName,
        isGuest: _isGuest,
        notificationService: notificationService,
        onNotificationSettings: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationSettingsPage(isGuest: _isGuest),
            ),
          );
        },
        onMyProfile: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyProfilePage(
                userName: widget.userName,
                email: '${widget.userName.toLowerCase()}@example.com',
              ),
            ),
          );
        },
        onLogin: () {
          Navigator.pop(context);
          _goToLogin();
        },
        onLogout: () {
          Navigator.pop(context);
          _showLogoutDialog();
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackgroundLayer(appExperience)),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Top row
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Mindfulness with Nature",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu,
                                color: Colors.white, size: 28),
                            onPressed: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                          ),
                          if (notificationService.isReminderEnabled)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Ambient audio indicator
                  AnimatedOpacity(
                    opacity: ambientActive ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.volume_up,
                              color: Colors.white38, size: 13),
                          const SizedBox(width: 4),
                          const Text("Ambient sound on",
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 12)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              if (appExperience.selectedSound == 'Silence') {
                                await appExperience
                                    .setSoundSelection('Bird Songs');
                              } else {
                                await appExperience
                                    .setSoundSelection('Silence');
                              }
                              await appExperience.persistSelections();
                            },
                            child: Icon(
                              ambientActive
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              color: Colors.white54,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  Text(
                    "${_getGreeting()} ${widget.userName}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _NotificationQuickCard(
                    isGuest: _isGuest,
                    service: notificationService,
                    onToggle: () => _quickToggleReminder(notificationService),
                    onOpenSettings: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationSettingsPage(
                            isGuest: _isGuest,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xff9BAFAF).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          "Today's Practice Feature",
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Grounding in Nature",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawer ────────────────────────────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  final String userName;
  final bool isGuest;
  final NotificationService notificationService;
  final VoidCallback onNotificationSettings;
  final VoidCallback onMyProfile;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  const _AppDrawer({
    required this.userName,
    required this.isGuest,
    required this.notificationService,
    required this.onNotificationSettings,
    required this.onMyProfile,
    required this.onLogin,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF5F0E8),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: const BoxDecoration(color: Color(0xFF3D2B1F)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B7355),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        isGuest ? Icons.person_outline : Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Show "Guest" badge OR reminder status
                  if (isGuest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Guest Mode',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: notificationService.isReminderEnabled
                                ? Colors.green
                                : Colors.white30,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          notificationService.isReminderEnabled
                              ? 'Reminders ON'
                              : 'Reminders OFF',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // My Profile — hide for guest
            if (!isGuest)
              _DrawerItem(
                icon: Icons.person_outline,
                label: 'My Profile',
                onTap: onMyProfile,
              ),

            // Notification Settings
            _DrawerItem(
              icon: Icons.notifications_outlined,
              label: 'Notification Settings',
              trailing: !isGuest && notificationService.isReminderEnabled
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B9080),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'ON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
              onTap: onNotificationSettings,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: Color(0xFFCCC0B0)),
            ),

            // Show Login if guest, Logout if logged in
            if (isGuest)
              _DrawerItem(
                icon: Icons.login,
                label: 'Login / Sign Up',
                iconColor: const Color(0xFF5E8C3B),
                labelColor: const Color(0xFF2E4E2E),
                onTap: onLogin,
              )
            else
              _DrawerItem(
                icon: Icons.logout,
                label: 'Log Out',
                iconColor: const Color(0xFF8B3A3A),
                labelColor: const Color(0xFF8B3A3A),
                onTap: onLogout,
              ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => launchUrl(
                      Uri.parse('https://www.flaticon.com/free-icons/leaf'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: const Text(
                      'flaticon.com/free-icons/leaf',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF5E8C3B),
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF5E8C3B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Leaf icons created by Pixel perfect - Flaticon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7A6A5A),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                'Mindfulness with Nature',
                style: TextStyle(
                  color: const Color(0xFF3D2B1F).withOpacity(0.35),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? const Color(0xFF3D2B1F);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor ?? const Color(0xFF3D2B1F),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ??
          Icon(Icons.chevron_right,
              color: const Color(0xFF3D2B1F).withOpacity(0.3), size: 20),
      onTap: onTap,
    );
  }
}

// ── Notification quick card ───────────────────────────────────────────────────

class _NotificationQuickCard extends StatelessWidget {
  final bool isGuest;
  final NotificationService service;
  final VoidCallback onToggle;
  final VoidCallback onOpenSettings;

  const _NotificationQuickCard({
    required this.isGuest,
    required this.service,
    required this.onToggle,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = !isGuest && service.isReminderEnabled;

    return GestureDetector(
      onTap: onOpenSettings,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isOn ? Icons.notifications_active : Icons.notifications_off,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGuest
                        ? "Daily Reminders (Sign in required)"
                        : (isOn ? "Daily Reminders ON" : "Daily Reminders OFF"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isGuest)
                    Text(
                      "Guests cannot enable reminders",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    )
                  else if (isOn) ...[
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (service.reminderTime != null)
                          service.reminderTime!.format(context),
                        service.reminderSound.label,
                      ].join(' · '),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ] else
                    Text(
                      "Tap to set up a daily reminder",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOn
                      ? Colors.white.withOpacity(0.25)
                      : Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  isGuest ? 'LOCKED' : (isOn ? 'ON' : 'OFF'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(isOn ? 1.0 : 0.65),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}
