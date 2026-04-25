import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      extendBodyBehindAppBar: false,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: colorScheme.background.withOpacity(0.8),
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
                  letterSpacing: 6.0,
                  color: colorScheme.primary,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: colorScheme.primary),
                  onPressed: () {
                    context.push('/notifications');
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 140), // Bottom padding for nav
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Editorial Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURATED SELECTION',
                    style: textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF827470),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'My Wishlist',
                    style: textTheme.displaySmall?.copyWith(
                      color: colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A private gallery of your most-coveted pieces, awaiting their place in your nocturnal ensemble.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF504441),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Product Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildWishlistItem(
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB1eRjK87wIw8owdmzrfPmMB5OrzhD37IYZrrRZDoWztwrGMnlSA17BWjF9B-JG29zy6jBlwyqajnyRB3z-BkeNfqI8hiiTPYkSC2n3A7qukU5Nka78EQedIqN3CcL0-X0u6MzHxmyvQi6DtVC_vHIhwnMxN5DM6vPxkUFcdhQWWcIa5h0-M4-On-4_O-mMKrzQYuei7FBQXiMd0Lx545agSRNTPx6qpLD2Ies8qaeHhnsx-OPWDv4Abo_PN1x7ziYEQ67fvumfjjw',
                    title: 'Sculpted Wool Overcoat',
                    price: 'LKR 42,500',
                    subtitle: 'Outerwear • Midnight Brown',
                    theme: theme,
                  ),
                  const SizedBox(height: 48),
                  _buildWishlistItem(
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCX-m9pXkGXmwf9fXK6pC-spwgp5auuE5NC6hrpZxcrAD4rkvTnhFS3YYZFdoqQUCabvn7XVttIoVEFBlBdF5lZl73UYWN9x8K1ZfCawIx5lTC8MGjcGK8-YA3knpRnjXElTZ9svTfcGNHqjS7V_XgJojroxR1Mew4E0uVkUB-5V3jq35NOGbqnBCUcY6Fg5Zx-CCWCbDCGNeHpRNY_HhNootg2_YCBzKvUSv5UA8T8_CtyfK5Z3MFE9CbbpE0QgRCIMgoahCt9HDw',
                    title: 'Toscana Leather Boot',
                    price: 'LKR 28,900',
                    subtitle: 'Footwear • Raw Umber',
                    theme: theme,
                  ),
                  const SizedBox(height: 48),
                  _buildWishlistItem(
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC7JVXDqvUSsdQ-ayhfnCQhybXMqmRjFmX7ogU9F23xW1pqcGObX_mNM9Q8ukyDjlRI0KbcNOL_BicuBaYpdnA0Gjq4M4rS8BUY7Mi6Uh2OtICk_6GSe2DbyX_FHf9j9i17pptgCz1CbLKAwVJFloUHgs8JXZcUuijsBkLZfxSX94K8XGjqQEK5-hL3sbj8U0r-T7uUhJDhQ9qso5QPXkOcn7eiAPwUX_oXF8ooRu2hA0NybZNeo3PjuqAYCZhmiBhPy0ucFgBX1HQ',
                    title: 'Silk Ribbed Mockneck',
                    price: 'LKR 14,200',
                    subtitle: 'Essentials • Espresso',
                    theme: theme,
                  ),
                  const SizedBox(height: 48),
                  _buildWishlistItem(
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC4QMetCyzf1S2lBep7W8vCCFVUOdcAyp5ebqqO30BIrfYwqDs15o7xie5S8qgmY2avVDYE695XUeIYdWu5q2fGSN28qOgG0EmnlJta0XF8Wlu3uVuieDm1B4butPV6Vr62WBIfAuv1BVmbVaay7anoBfvHS2k3VHzya6kOciAkdkT4Ky2yvu4b2S4XKzk3apfhSpi5xoyYakiqbbg2tDD5MgSIW5x1ulBJiMWuI3FsETLfzqISkP9UFQ5iqzGeXuo_cY_pYQMyCiE',
                    title: 'Sculptural Tote Bag',
                    price: 'LKR 56,000',
                    subtitle: 'Accessories • Obsidian Brown',
                    theme: theme,
                  ),
                ],
              ),
            ),

            // Continue Shopping Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Center(
                child: InkWell(
                  onTap: () {
                    context.go('/home');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: colorScheme.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'Continue Shopping',
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.primary,
                            fontStyle: FontStyle.italic,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_right_alt, color: colorScheme.primary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.background.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home, 'HOME', false, () {
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
        ),
      ),
    );
  }

  Widget _buildWishlistItem({
    required String imageUrl,
    required String title,
    required String price,
    required String subtitle,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image & Favorite Icon
        AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                  fontSize: 22,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              price,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.labelSmall?.copyWith(
            color: const Color(0xFF504441),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 24),

        // Add to Cart Button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.secondary,
                const Color(0xFFFE8763),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.secondary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Text(
              'ADD TO CART',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
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
            color: isActive ? colorScheme.secondary : colorScheme.primary.withOpacity(0.4),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? colorScheme.secondary : colorScheme.primary.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
