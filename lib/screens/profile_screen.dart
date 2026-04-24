import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: colorScheme.surface.withOpacity(0.7),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
              title: Text(
                'MOOD',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                  color: colorScheme.primary,
                ),
              ),
              centerTitle: true,
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications_outlined, color: colorScheme.primary),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120, left: 24, right: 24, top: 24),
        child: Column(
          children: [
            // Profile Identity
            Column(
              children: [
                // Avatar
                Container(
                  width: 128,
                  height: 128,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD4C3BE).withOpacity(0.2),
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipOval(
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida/ADBb0uiAV6u-a08meWRJ0oXldb2-AfU6bzMuF-yXQ7sSdy0jQPx44zrfT0E7riZCSus92O-4uNEMZaDPuP3YRSX0Zjnu36E1QWXbOupuYw7T9PrQ88Qou-e5v7iZ7SuzSFPlcRUeCN1PPQbTQ1mwDB67UWQ0I1NFpi7qJx2NRHGI_1Vu6GaEvK1ZrAfJ13G1YZGGI17dPIS_A9DFlu9L-b-0iUlecx6aEwX9KLxTmI0Jxi8BdDHBXvs53zbKy4YS9erpETkshK1scA9Czg',
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Name & Email
                Text(
                  'Hiruni Dave',
                  style: GoogleFonts.notoSerif(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'hiruni07@gmail.com',
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF827470),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Summary Bento Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F3EE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD4C3BE).withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ORDERS',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            letterSpacing: 2.0,
                            color: const Color(0xFF827470),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '12',
                          style: GoogleFonts.notoSerif(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F3EE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD4C3BE).withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'POINTS',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            letterSpacing: 2.0,
                            color: const Color(0xFF827470),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '2.4k',
                          style: GoogleFonts.notoSerif(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Navigation Menu
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    label: 'Edit Profile',
                    onTap: () {},
                    theme: theme,
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.login,
                    label: 'Login',
                    onTap: () {
                      context.go('/login');
                    },
                    theme: theme,
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.favorite,
                    label: 'My Wishlist',
                    badge: '2',
                    onTap: () {
                      context.push('/wishlist');
                    },
                    theme: theme,
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.history,
                    label: 'Order History',
                    onTap: () {
                      context.push('/order_details');
                    },
                    theme: theme,
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {},
                    theme: theme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildMenuItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: () {
                  context.go('/');
                },
                theme: theme,
                isLogout: true,
              ),
            ),
            const SizedBox(height: 64),

            // MOOD Club Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'The MOOD Club',
                    style: GoogleFonts.notoSerif(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'EXCLUSIVE EARLY ACCESS & INVITATIONS',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      letterSpacing: 2.0,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'VIEW PRIVILEGES',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.06),
              blurRadius: 40,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 32, left: 32, right: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, 'HOME', false, () {
                    context.go('/home');
                  }, colorScheme),
                  _buildNavItem(Icons.search, 'SEARCH', false, () {
                    context.go('/products');
                  }, colorScheme),
                  _buildNavItem(Icons.shopping_cart_outlined, 'CART', false, () {
                    context.go('/cart');
                  }, colorScheme),
                  _buildNavItem(Icons.person, 'PROFILE', true, () {}, colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isLogout = false,
  }) {
    final color = isLogout
        ? theme.colorScheme.secondary.withOpacity(0.8)
        : theme.colorScheme.primary.withOpacity(0.7);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: isLogout
                    ? theme.colorScheme.secondary.withOpacity(0.8)
                    : theme.colorScheme.primary,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isLogout
                  ? theme.colorScheme.secondary.withOpacity(0.4)
                  : const Color(0xFF827470).withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Divider(
        height: 1,
        color: const Color(0xFFD4C3BE).withOpacity(0.2),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? colorScheme.primary : colorScheme.primary.withOpacity(0.4),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? colorScheme.primary : colorScheme.primary.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
