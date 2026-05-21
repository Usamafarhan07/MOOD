import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mood/services/firestore_service.dart';

class RegistrationScreen extends StatefulWidget {
  
  const RegistrationScreen({super.key});
  

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _obscurePassword = true;
  bool _agreeTerms = false;
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hasPasswordText = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      final hasText = _passwordController.text.isNotEmpty;
      if (hasText != _hasPasswordText) {
        setState(() {
          _hasPasswordText = hasText;
          if (!hasText) _obscurePassword = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _showSnackBar(String message) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty) {
      return _showSnackBar('Full name cannot be empty.');
    }

    if (email.isEmpty) {
      return _showSnackBar('Email cannot be empty.');
    }

    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,}");
    if (!emailRegex.hasMatch(email)) {
      return _showSnackBar('Please enter a valid email address.');
    }

    if (password.isEmpty) {
      return _showSnackBar('Password cannot be empty.');
    }

    if (password.length < 6) {
      return _showSnackBar('Password must be at least 6 characters.');
    }

    if (confirmPassword != password) {
      return _showSnackBar('Passwords do not match.');
    }

    if (!_agreeTerms) {
      return _showSnackBar('Please agree to the terms and privacy policy.');
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(fullName);

      if (credential.user != null) {
        await FirestoreService().createUserProfile(
          uid: credential.user!.uid,
          fullName: fullName,
          email: email,
        );
      }

      if (!mounted) return;
      context.go('/home');
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'email-already-in-use' => 'This email is already registered.',
        'invalid-email' => 'That email address is invalid.',
        'operation-not-allowed' => 'Email/password registration is not enabled.',
        'weak-password' => 'Password is too weak. Use at least 6 characters.',
        'too-many-requests' => 'Too many requests. Please try again later.',
        _ => 'Registration failed. Please try again.',
      };
      await _showSnackBar(message);
    } catch (_) {
      await _showSnackBar('Registration failed. Please try again later.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // MOOD Logo
                    Text(
                      'MOOD',
                      style: GoogleFonts.notoSerif(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6.0,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Welcome Section
                    Text(
                      'WELCOME TO MOOD',
                      style: GoogleFonts.notoSerif(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.6,
                        color: colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Create Account',
                      style: GoogleFonts.notoSerif(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please enter your details to register.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF504441).withValues(alpha: 0.8),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Full Name Field
                    _buildInputField(
                      controller: _fullNameController,
                      theme: theme,
                      label: 'FULL NAME',
                      hint: 'e.g. Julianne Moore',
                    ),
                    const SizedBox(height: 24),

                    // Email Field
                    _buildInputField(
                      controller: _emailController,
                      theme: theme,
                      label: 'EMAIL ADDRESS',
                      hint: 'hello@atelier-mood.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    // Password Field
                    _buildPasswordField(theme),
                    const SizedBox(height: 24),

                    // Confirm Password Field
                    _buildInputField(
                      controller: _confirmPasswordController,
                      theme: theme,
                      label: 'CONFIRM PASSWORD',
                      hint: '••••••••••••',
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    // Terms Checkbox
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeTerms = !_agreeTerms;
                              });
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: _agreeTerms
                                    ? colorScheme.primary
                                    : const Color(0xFFEBE8E3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: _agreeTerms
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreeTerms = !_agreeTerms;
                                });
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF504441).withValues(alpha: 0.7),
                                    height: 1.5,
                                  ),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: const Color(0xFFD4C3BE).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: const Color(0xFFD4C3BE).withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'REGISTER',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.4,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Back to Login link
                    GestureDetector(
                      onTap: () {
                        context.go('/login');
                      },
                      child: RichText(
                        text: TextSpan(
                          style: textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF504441).withValues(alpha: 0.6),
                            letterSpacing: 0.5,
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Back to Login',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: colorScheme.primary.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Column(
                children: [
                  Container(
                    width: 1,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          const Color(0xFFD4C3BE).withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '© 2026 MOOD GLOBAL FASHION SPREADS',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      letterSpacing: 2.5,
                      color: colorScheme.primary.withValues(alpha: 0.4),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required ThemeData theme,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF504441).withValues(alpha: 0.3),
            ),
            filled: true,
            fillColor: const Color(0xFFEBE8E3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'PASSWORD',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
          decoration: InputDecoration(
            hintText: '••••••••••••',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF504441).withValues(alpha: 0.3),
            ),
            filled: true,
            fillColor: const Color(0xFFEBE8E3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            suffixIcon: _hasPasswordText
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF504441).withValues(alpha: 0.4),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
