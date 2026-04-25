import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.background.withOpacity(0.7),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
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
              'Notifications',
              style: GoogleFonts.notoSerif(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
                color: colorScheme.primary,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert, color: colorScheme.primary),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Recent Activity Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'RECENT ACTIVITY',
                style: GoogleFonts.notoSerif(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2.0,
                  color: const Color(0xFF827470),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notification 1: Order with Image
            _buildOrderNotification(
              context: context,
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAIn5WZW2ZDB4zjyxPNbGauGMQV6b6n02Qq9FcFCDNzo1Scyan92LXmaEin6R9HRVc4pxfy0RQNtnNRKFCP1V5AnWLBloZe7XXj2JLStM4N873D6Kh4nEG_vmuBstdQWQ_4XguzhcStP47IyZxlqsdTud45WPWsW0m-RQRIioOL457ip_xSRRrUHhVj4F1garOElFHdmRW_h7Kl7M7xOTzHra-nIWs3Z2QN2oPxebOXRLE5Du1iiUkzMvSIVKKxRsygM-3ErwqV8zE',
              title: 'Order #ATL-8829-0142 is being prepared with artisanal care',
              status: 'In Production',
              time: '2h ago',
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Notification 2: New Arrival with Icon
            _buildIconNotification(
              context: context,
              icon: Icons.auto_awesome,
              iconBgColor: colorScheme.primary,
              iconColor: Colors.white,
              title: 'New Arrival: The Winter Silk Collection is now available',
              subtitle: 'Discover fluidity in structure with our latest artisanal drop.',
              time: '5h ago',
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Notification 3: Style Alert with Icon
            _buildIconNotification(
              context: context,
              icon: Icons.favorite,
              iconBgColor: const Color(0xFFFE8763).withOpacity(0.2),
              iconColor: const Color(0xFFA04022),
              title: 'Style Alert: Pieces you loved are back in stock',
              subtitle: 'The L\'Artiste Trousers in Midnight Sand have returned to our atelier.',
              time: 'Yesterday',
              theme: theme,
            ),

            const SizedBox(height: 40),

            // Earlier Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'EARLIER',
                style: GoogleFonts.notoSerif(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2.0,
                  color: const Color(0xFF827470),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Earlier Notification (faded)
            Opacity(
              opacity: 0.6,
              child: _buildIconNotification(
                context: context,
                icon: Icons.mail_outlined,
                iconBgColor: const Color(0xFFE5E2DD),
                iconColor: colorScheme.primary,
                title: 'Your monthly style digest is here',
                subtitle: null,
                time: '3 days ago',
                theme: theme,
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.background.withOpacity(0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(48),
            topRight: Radius.circular(48),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(48),
            topRight: Radius.circular(48),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 40, left: 32, right: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                _buildNavItem(Icons.person_outline, 'PROFILE', false, () {
                  context.go('/profile');
                }, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderNotification({
    required BuildContext context,
    required String imageUrl,
    required String title,
    required String status,
    required String time,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F3EE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 80,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.saturation,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFF0EDE9),
                    child: Icon(Icons.image, color: colorScheme.primary.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSerif(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: const Color(0xFFA04022),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4C3BE),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.0,
                          color: const Color(0xFF827470),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconNotification({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? subtitle,
    required String time,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F3EE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSerif(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.3,
                        height: 1.6,
                        color: const Color(0xFF504441),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    time.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                      color: const Color(0xFF827470),
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
