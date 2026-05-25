import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mood/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailUpdates = false;
  bool _biometricLogin = false;
  bool _locationServices = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.primary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.notoSerif(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Appearance', colorScheme),
            const SizedBox(height: 12),
            _buildToggleTile(
              title: 'Dark Mode',
              subtitle: 'Switch to a premium dark color theme',
              value: AppTheme.themeModeNotifier.value == ThemeMode.dark,
              onChanged: (val) {
                setState(() {
                  AppTheme.themeModeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                });
              },
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 32),
            
            _buildSectionHeader('Notifications', colorScheme),
            const SizedBox(height: 12),
            _buildToggleTile(
              title: 'Push Notifications',
              subtitle: 'Receive alerts for orders and sales',
              value: _pushNotifications,
              onChanged: (val) => setState(() => _pushNotifications = val),
              colorScheme: colorScheme,
            ),
            _buildDivider(),
            _buildToggleTile(
              title: 'Email Updates',
              subtitle: 'Receive weekly newsletters and promo codes',
              value: _emailUpdates,
              onChanged: (val) => setState(() => _emailUpdates = val),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 32),
            
            _buildSectionHeader('Security & Privacy', colorScheme),
            const SizedBox(height: 12),
            _buildToggleTile(
              title: 'Biometric Sign In',
              subtitle: 'Use Face ID / Touch ID to sign in',
              value: _biometricLogin,
              onChanged: (val) => setState(() => _biometricLogin = val),
              colorScheme: colorScheme,
            ),
            _buildDivider(),
            _buildToggleTile(
              title: 'Location Services',
              subtitle: 'Enable location for better address suggestions',
              value: _locationServices,
              onChanged: (val) => setState(() => _locationServices = val),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('App Settings', colorScheme),
            const SizedBox(height: 12),
            _buildActionTile(
              title: 'Clear Cache',
              subtitle: 'Remove temporary image and page caches',
              icon: Icons.cleaning_services_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App cache cleared successfully.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              colorScheme: colorScheme,
            ),
            _buildDivider(),
            _buildActionTile(
              title: 'Privacy Policy',
              subtitle: 'Read our customer data privacy terms',
              icon: Icons.privacy_tip_outlined,
              onTap: () {
                // Mock link click
              },
              colorScheme: colorScheme,
            ),
            _buildDivider(),
            _buildActionTile(
              title: 'Terms of Service',
              subtitle: 'View our legal terms and conditions',
              icon: Icons.description_outlined,
              onTap: () {
                // Mock link click
              },
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 48),

            Center(
              child: Column(
                children: [
                  Text(
                    'Mood App',
                    style: GoogleFonts.notoSerif(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v1.4.2 (Production Build)',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: colorScheme.secondary,
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary.withValues(alpha: 0.8), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: colorScheme.primary.withValues(alpha: 0.4), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 24,
      thickness: 0.5,
      color: const Color(0xFFD4C3BE).withValues(alpha: 0.5),
    );
  }
}
