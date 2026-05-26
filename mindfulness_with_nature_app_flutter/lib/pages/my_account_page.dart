import 'package:flutter/material.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({
    super.key,
    required this.userName,
    required this.email,
  });

  final String userName;
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF7A9F5A),
            child: Text(
              userName.isEmpty ? '?' : userName[0].toUpperCase(),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            userName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'This page gives you a simple account view so the home screen drawer can navigate without breaking the build.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}