import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'bottom_nav_page.dart';
import 'login_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          final authService = Provider.of<AuthService>(context, listen: false);
          final authServiceUser = authService.currentUser;

          fb_auth.User? firebaseUser;
          try {
            firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
          } catch (_) {
            firebaseUser = null;
          }

          if (authServiceUser != null || firebaseUser != null) {
            final displayName =
                authServiceUser?.displayName?.trim().isNotEmpty == true
                    ? authServiceUser!.displayName!.trim()
                    : (firebaseUser?.displayName?.trim().isNotEmpty == true
                        ? firebaseUser!.displayName!.trim()
                        : (authServiceUser?.email.isNotEmpty == true
                            ? authServiceUser!.email.split('@').first
                            : (firebaseUser?.email?.split('@').first ??
                                'User')));

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BottomNavPage(
                  userName: displayName,
                ),
              ),
            );
            return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset('assets/images/splash_bg.jpg', fit: BoxFit.cover),

            // Optional Dark Overlay (better text visibility)
            Container(color: Colors.black.withOpacity(0.3)),

            // Text Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Click anywhere to continue",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
