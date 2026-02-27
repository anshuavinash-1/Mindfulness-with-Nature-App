import 'package:flutter/material.dart';
import 'package:mindfullness/pages/login_page.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Navigate to next screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage() ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [

            // Background Image
            Image.asset(
              'assets/images/splash_bg.jpg',
              fit: BoxFit.cover,
            ),

            // Optional Dark Overlay (better text visibility)
            Container(
              color: Colors.black.withOpacity(0.3),
            ),

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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
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
}

