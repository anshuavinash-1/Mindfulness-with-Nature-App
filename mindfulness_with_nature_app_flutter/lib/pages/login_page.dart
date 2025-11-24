import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'dashboard_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);

      try {
        // Use the new signInWithEmail method
        final user = await authService.signInWithEmail(
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
            _showErrorSnackBar('Login failed. Please try again.');
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Welcome text
                Text(
                  'Welcome to\nMindfulness with Nature',
                  style: GoogleFonts.lora(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    // REQ-008: Use theme's primary text color (Charcoal)
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find your inner peace',
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    // REQ-008: Muted color for secondary text
                    color: theme.colorScheme.onSurface
                        .withAlpha((0.7 * 255).round()),
                  ),
                ),
                const SizedBox(height: 60),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email,
                        color: theme.colorScheme.onSurface
                            .withAlpha((0.5 * 255).round())),
                    // REQ-008: Minimalistic input border with theme primary color on focus
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: theme.colorScheme.onSurface
                              .withAlpha((0.3 * 255).round())),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2), // Sage Green focus border
                    ),
                    labelStyle: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withAlpha((0.8 * 255).round())),
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
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock,
                        color: theme.colorScheme.onSurface
                            .withAlpha((0.5 * 255).round())),
                    // REQ-008: Minimalistic input border with theme primary color on focus
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: theme.colorScheme.onSurface
                              .withAlpha((0.3 * 255).round())),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2), // Sage Green focus border
                    ),
                    labelStyle: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withAlpha((0.8 * 255).round())),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  // REQ-008: Use theme's default Elevated Button style (Sage Green)
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              // REQ-008: Use theme's color for the loader
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary),
                            ),
                          )
                        : Text(
                            'Login',
                            style: GoogleFonts.lora(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Forgot password link
                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            _showForgotPasswordDialog();
                          },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        // REQ-008: Use primary color (Sage Green) for the link
                        color: theme.colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                // Sign up link
                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            // Navigate to signup page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupPage()),
                            );
                          },
                    child: Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(
                        // REQ-008: Use primary color (Sage Green) for the link
                        color: theme.colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    final stateContext = context;
    final theme = Theme.of(stateContext);

    // The dialog returns an email string; we immediately check `mounted` after the await
    // to ensure State is still valid. The analyzer can be conservative about
    // dialogs and contexts; suppress the specific lint here.
    // ignore: use_build_context_synchronously
    final result = await showDialog<String?>(
      context: stateContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Reset Password',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Enter your email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(stateContext, rootNavigator: true).pop(null),
            child: Text('Cancel',
                style: TextStyle(color: theme.colorScheme.onSurface)),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              Navigator.of(stateContext, rootNavigator: true).pop(email);
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (result == null || result.isEmpty) return;

    // ignore: use_build_context_synchronously
    final authService = Provider.of<AuthService>(stateContext, listen: false);
    try {
      await authService.resetPassword(result);
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(stateContext).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $result'),
          backgroundColor: Colors.green.shade400,
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(stateContext).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }
}
