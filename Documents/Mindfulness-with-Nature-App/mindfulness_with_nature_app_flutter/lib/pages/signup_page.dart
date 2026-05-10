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
  bool _isLoading = false;

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
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      // REQ-008: Use theme's primary color (Sage Green) for navigation icon
                      icon: Icon(Icons.arrow_back,
                          color: theme.colorScheme.primary),
                    ),
                    const Spacer(),
                    Text(
                      'Create Account',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        // REQ-008: Use theme's onBackground color (Charcoal)
                        color: theme.colorScheme.onSurface,
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
                    color:
                        theme.colorScheme.surface, // REQ-008: Off-White Surface
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        // REQ-008: Soft, subtle shadow using primary color tint
                        color: theme.colorScheme.primary
                            .withAlpha((0.1 * 255).round()),
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
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
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
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.onPrimary),
                                  ),
                                )
                              : Text(
                                  'Create Account',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
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
                          color: theme.colorScheme.onSurface
                              .withAlpha((0.7 * 255).round())),
                    ),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
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
                          color: _isLoading
                              ? theme.colorScheme.onSurface
                                  .withAlpha((0.3 * 255).round())
                              : theme.colorScheme.primary,
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

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);

      try {
        // Use the new signUpWithEmail method
        final user = await authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (user != null) {
            // Navigate to dashboard with user data
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardPage(user: user),
              ),
            );
          } else {
            _showErrorSnackBar('Signup failed. Please try again.');
          }
        }
      } on AuthException catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar(e.message);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar('An unexpected error occurred. Please try again.');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade400,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
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
      prefixIcon:
          Icon(icon, color: theme.colorScheme.primary), // Sage Green icon
      labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withAlpha((0.8 * 255).round())),
      // Default border (Muted/faint)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: theme.colorScheme.onSurface.withAlpha((0.3 * 255).round())),
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
