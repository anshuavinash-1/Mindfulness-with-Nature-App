import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_page.dart';
import 'dashboard_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // REQ-008: Use theme's scaffold background (Sand/Beige)
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Back button and title
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      // REQ-008: Use theme's primary color (Sage Green) for navigation icon
                      icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary), 
                    ),
                    const Spacer(),
                    Text(
                      'Create Account',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        // REQ-008: Use theme's onBackground color (Charcoal)
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // For balance
                  ],
                ),
                const SizedBox(height: 40),

                // Signup Form Container
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface, // REQ-008: Off-White Surface
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        // REQ-008: Soft, subtle shadow using primary color tint
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration(
                          context,
                          'Email',
                          Icons.email,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final email = value.trim();
                          final emailRe = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRe.hasMatch(email)) {
                            return 'Please enter a valid email address (e.g., name@example.com)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        decoration: _buildInputDecoration(
                          context,
                          'Password',
                          Icons.lock,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                          bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
                          bool hasDigits = value.contains(RegExp(r'[0-9]'));
                          bool hasSpecialCharacters =
                              value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

                          if (!hasUppercase ||
                              !hasDigits ||
                              !hasSpecialCharacters) {
                            return 'Password must contain at least:\n• One uppercase letter\n• One number\n• One special character';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password field
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: _buildInputDecoration(
                          context,
                          'Confirm Password',
                          Icons.lock_outline,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Signup Button
                      Consumer<AuthService>(
                        builder: (context, authService, child) {
                          return authService.isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: () async {
                                    final navigator = Navigator.of(context);
                                    final messenger =
                                        ScaffoldMessenger.of(context);

                                    if (_formKey.currentState!.validate()) {
                                      final success = await authService.signup(
                                        _emailController.text,
                                        _passwordController.text,
                                        _confirmPasswordController.text,
                                      );

                                      if (!mounted) return;

                                      if (success) {
                                        navigator.pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const DashboardPage(),
                                          ),
                                        );
                                      } else {
                                        // REQ-008: Use a themed failure color
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                'Signup failed. Please try again.'),
                                            backgroundColor: Colors.red.shade400,
                                          ),
                                        );
                                      }
                                    } else {
                                      // REQ-008: Use a themed warning color
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              'Please fix the errors in the form.'),
                                          backgroundColor: Colors.orange.shade400,
                                        ),
                                      );
                                    }
                                  },
                                  // REQ-008: Button inherits primary theme style
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 55),
                                    elevation: 2, // Muted elevation
                                  ),
                                  child: Text(
                                    'Create Account',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.inter(
                        // REQ-008: Muted color for static text
                        color: theme.colorScheme.onBackground.withOpacity(0.7)
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Login',
                        style: GoogleFonts.inter(
                          // REQ-008: Use primary color (Sage Green) for the link
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for consistent input decoration styling (REQ-008)
  InputDecoration _buildInputDecoration(
      BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: theme.colorScheme.primary), // Sage Green icon
      labelStyle: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.8)),
      // Default border (Muted/faint)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3)),
      ),
      // Focused border (Sage Green accent)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}