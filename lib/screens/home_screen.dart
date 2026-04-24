import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              backgroundColor: colorScheme.surface.withOpacity(0.8),
              elevation: 0,
              leading: const SizedBox(width: 48),
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
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3EE),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search products...',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary.withOpacity(0.5),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Icon(Icons.camera_alt_outlined, color: colorScheme.primary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Hero Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: () {
                  context.go('/products');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 500,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCtOnOOXGA2BDQydlnHCriYfQhXOuDXPi0asqNWUtsOsiqzq04udrkH3ks1A1LnMBCgNkcjN0LwOnDyMHeA4uVRbGMffd3N59C_ix6Gdp2nwjQHUYb03VoEX9AaR_Ci_ev0xmR2CsipxnX6I9PXOD0FNzXl6KyQkjeZCroPE6RDVI-1bZRLrhRupZx-u6feWiBpPJHrAHhDrUoaHYkXsYBufQae32TE-rg-hReKolFDH9xPRVcGh9IcYTGdC5ZUXyqk6k_8I3CLpeQ',
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                colorScheme.primary.withOpacity(0.6),
                                Colors.transparent,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 32,
                          left: 32,
                          right: 32,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Summer Archive',
                                style: textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 48,
                                  height: 1.1,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'A curated selection of timeless silhouettes for the digital modernist.',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.secondary,
                                      const Color(0xFFFE8763),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.secondary.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.go('/products');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: Text(
                                    'EXPLORE COLLECTION',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Category Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('Women', true, colorScheme, textTheme),
                    const SizedBox(width: 12),
                    _buildCategoryChip('Men', false, colorScheme, textTheme),
                    const SizedBox(width: 12),
                    _buildCategoryChip('Kids', false, colorScheme, textTheme),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Featured Selection Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'Featured Selection',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      context.go('/products');
                    },
                    child: Text(
                      'VIEW ALL',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Product Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Row 1: Coat + Silk Slip (staggered)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildProductCard(
                          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDNHN-xw2EVV9V-z1_pQatvYZqGsqw40CKM6zOVcE1rCKB5-hXd8_RkCGUl_0HVwDHFB1z5DXVyhuu0V0fG4_85Ml857EYH-i_P7an0mnxpU8FhbOYwR1NlmAb-l-vJLDnnpjZqVKG2Y-Hg5WPvKRYWDD8nEHWm9HwwS7tLfrzBB2KAGq2PhnbYJrt7PrTNSc2U-FrpnD73r88Iu-B3-JNeQ_0c89NuNqRc5R2z_FsX-tVSP94vL-BQwID6rZlH1A8OtV11LSjr6xo',
                          title: 'Structured Wool Coat',
                          subtitle: 'Heritage Camel',
                          price: 'LKR 9000',
                          isFavorite: true,
                          theme: theme,
                          context: context,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 48.0),
                          child: _buildProductCard(
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB3eFsuU50HyClxMBUzmgR62Lm-jHZG-z3xkj7yA7EyEFpJcSl90XikR03rpfyNdwScwUHIDLikHLUDRbqZFZwkzVujgupyDV_5DFUmYWkI005-5M7LeQFMtsxaDyeWCHCNfD1sMYwST1IiEeFoEWmo_Zl6-F--_QN7sogAcoddt80RgIGALgpGnLBpfWJUCE8OnRnD_jp8mPbDRZQAveMHhVBGgcyP3OrIksc73HCUpzGM8R8jzSpOpfqc99Pk_QtWaSic-lkdxB0',
                            title: 'Noir Silk Slip',
                            subtitle: 'Midnight Onyx',
                            price: 'LKR 7500',
                            isFavorite: false,
                            theme: theme,
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Row 2: Mini Bag + Trousers (staggered)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildProductCard(
                          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCSvPUh6-En9CMsWZFhpYp5yZA91x3tvC08WkNj28QBJPfSAUPnR3zz5kgGqYn3HpOlMsavlojLUySSV-nBtBqMKDroTMCmhj2HeeXgB9rUOKKF3A8o5FNVwOOEFG21W1JiwKqrgpEzpP7ixCnlTIgkNngzOX4HF7QoCVMXNUpJ-CJIjNSWOTk_4F-7_vt7TjMWtVujPtbzN4ppikNM70OYvXZcVUEYuLNTPwveVfkpRRzFGkvt1YSTr3Jj607frcXIu-P4m69GAMw',
                          title: 'Noir Mini Bag',
                          subtitle: 'Midnight Onyx',
                          price: 'LKR 12,500',
                          isFavorite: false,
                          theme: theme,
                          context: context,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 48.0),
                          child: _buildProductCard(
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDa7QWyyg1YDNcW2MypSJMRrw0zs-aTYyqicNeAPyj2gfLrCQNPZnQ_bZGznk75R3-pUsIORn9rYPp6-6YNAj-TE-9pcAlLIhOzQzMzcGuA9wE2tmb6el1ryXE4Az4mdokPBx7rjkTYTTmrYWFCPO6ZwbeB1vMwE4GsrXuNJGtzxo76sOgpH4xQ8qoIqMlYiFPExtu-4gkt5AhuI3IGdVZ5iYLg2ZftC0Z0_d03kALIRVrACFKmg0f_g94A8Bx1Skt0pdrrUov1aAY',
                            title: 'Silk Tapered Trousers',
                            subtitle: 'Desert Sand',
                            price: 'LKR 6,800',
                            isFavorite: false,
                            theme: theme,
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Curator Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3EE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: colorScheme.secondary,
                      size: 36,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'The Digital Curator',
                      style: GoogleFonts.notoSerif(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Experience a tailored journey where AI meets high fashion editorial standards.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF504441),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'MEET YOUR STYLIST',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: colorScheme.primary,
                            decoration: TextDecoration.underline,
                            decorationThickness: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 14, color: colorScheme.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.05),
              blurRadius: 30,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 32, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, 'HOME', true, () {}, colorScheme),
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
    );
  }

  Widget _buildCategoryChip(String label, bool isActive, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : const Color(0xFFEBE8E3),
        borderRadius: BorderRadius.circular(50),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: isActive ? Colors.white : colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String imageUrl,
    required String title,
    required String subtitle,
    required String price,
    required bool isFavorite,
    required ThemeData theme,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/product_details');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFF6F3EE),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                    // Favorite Button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF504441),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
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
