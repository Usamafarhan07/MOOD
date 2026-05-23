import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
          if (!hasText) _obscurePassword = true; // reset to hidden when cleared
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showSnackBar(String message) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

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

    if (password.length < 8) {
      return _showSnackBar('Password must be at least 8 characters.');
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      context.go('/home');
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'invalid-email' => 'That email address is invalid.',
        'user-disabled' => 'This user account has been disabled.',
        'user-not-found' => 'No account found with that email.',
        'wrong-password' => 'Incorrect password. Please try again.',
        'invalid-credential' => 'Incorrect email or password.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        _ => 'Login failed. Please check your credentials and try again.',
      };
      await _showSnackBar(message);
    } catch (_) {
      await _showSnackBar('Login failed. Please try again later.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  final String _googleSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
    <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"></path>
    <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"></path>
    <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"></path>
    <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"></path>
</svg>
''';

  final String _appleSvg = '''
<svg viewBox="0 0 384 512" xmlns="http://www.w3.org/2000/svg">
    <path fill="white" d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"></path>
</svg>
''';

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 48.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand Identity
                    Text(
                      'MOOD',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6.0,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 64),

                    // Hero Text
                    Text(
                      'Welcome Back',
                      style: textTheme.headlineSmall?.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please enter your details to sign in.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF504441),
                        letterSpacing: 0.25,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Login Form
                    _buildTextField(
                      controller: _emailController,
                      label: 'EMAIL ADDRESS',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      theme: theme,
                    ),
                    const SizedBox(height: 24),
                    _buildPasswordField(theme: theme),
                    const SizedBox(height: 32),

                    // Login Action
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D4037),
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
                                'LOGIN',
                                style: textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.4,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: const Color(
                                0xFF504441,
                              ).withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Social Logins
                    _buildSocialButton(
                      label: 'CONTINUE WITH GOOGLE',
                      svgString: _googleSvg,
                      backgroundColor: Colors.white,
                      textColor: colorScheme.onSurface,
                      borderColor: Colors.grey.shade200,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _buildSocialButton(
                      label: 'CONTINUE WITH APPLE',
                      svgString: _appleSvg,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      borderColor: Colors.black,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeData theme,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: const Color(0xFF504441),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF504441).withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: const Color(0xFFEBE8E3), // surface-container-high
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({required ThemeData theme}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0, right: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PASSWORD',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: const Color(0xFF504441),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  'FORGOT?',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF504441).withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: const Color(0xFFEBE8E3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            suffixIcon: _hasPasswordText
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF504441).withValues(alpha: 0.5),
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

  Widget _buildSocialButton({
    required String label,
    required String svgString,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(svgString, width: 20, height: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink('PRIVACY', theme),
              const SizedBox(width: 24),
              _buildFooterLink('TERMS', theme),
              const SizedBox(width: 24),
              _buildFooterLink('CONTACT', theme),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'NEW TO MOOD? ',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
              InkWell(
                onTap: () {
                  context.go('/register');
                },
                child: Text(
                  'CREATE ACCOUNT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: theme.colorScheme.secondary.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© 2024 THE NOCTURNAL ATELIER. ALL RIGHTS RESERVED.',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              letterSpacing: 1.5,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, ThemeData theme) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 12,
          letterSpacing: 1.5,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
