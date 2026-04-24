import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

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
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 120), // Bottom padding for nav
        child: Column(
          children: [
            // Hero Illustration
            SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: colorScheme.primary,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.background,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Title and Subtitle
            Text(
              'Order Placed!',
              style: textTheme.displaySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your selection from The MOOD is being prepared with artisanal care.',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: const Color(0xFF504441),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),

            // Confirmation Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'CONFIRMATION NUMBER',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '#ATL-8829-0142',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 48,
                    height: 1,
                    color: colorScheme.primary.withOpacity(0.1),
                  ),
                  const SizedBox(height: 24),

                  // Item Thumbnails (Stacked)
                  SizedBox(
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Item 1
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.25 - 42,
                          child: _buildThumbnail(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBIL1AAphMevMJzfStXpzxoyxKJWTQ1yk5R4O18_ItwtljIidvbnZk0VWEggvwLh6SFwvsMMFH4szB-SEf7fZDO4viFeYQ3wdiWiXGGt1UPVHHUzcU3XbjOrFIN8iVc70FYSaoSF0w4IXII1BTX2BkxJkRGi_UErl0Q_-9JReIYubkslrlgRmJiOWt0hJ80XAA42ZPRq9DtOz8LZLhQeJrxFR3HGllF_xbyUKpdQNO0LjM50btkeBFl38carp7ipz48q97HKW660uU',
                            theme,
                          ),
                        ),
                        // Item 2
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.25 - 10,
                          child: _buildThumbnail(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBlKhhOoB329QjjJyu9raaPQHMcXi7padY4kJ9WMx6JuukcGvXUgp529_G5dqw8EBxOBK4YEuImtnnm0oDA14qXYPWufbukb-CEnq5ems29o3811cw65bvn5UclPZ65H2WWMR5hZDeh6PzsoAtZ_0NvUz_h2mt081_gAlKSvv8ZAzY5zkmKalj_gc_f3HXjNWmqOqS2ooBDUmWNru1tvN4wL5S2szm9RGCKyIam5QHPKuB68EZ47oqZBWWNHnvBs9LeBUU5c1vy5fM',
                            theme,
                          ),
                        ),
                        // Count Badge
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.25 + 22,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colorScheme.surfaceContainerLow, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '+1',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      style: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF504441),
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(text: 'Estimated delivery: '),
                        TextSpan(
                          text: 'Oct 24 - Oct 26',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Action Buttons
            Container(
              width: double.infinity,
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
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'CONTINUE SHOPPING',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/order_details');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainer,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'VIEW ORDER DETAILS',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    fontSize: 14,
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.05),
              blurRadius: 30,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home, 'HOME', false, theme, context),
                    _buildNavItem(Icons.search, 'SEARCH', false, theme, context),
                    _buildNavItem(Icons.shopping_cart_outlined, 'CART', false, theme, context),
                    _buildNavItem(Icons.person, 'PROFILE', true, theme, context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String imageUrl, ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.surfaceContainerLow, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, ThemeData theme, BuildContext context) {
    final color = isSelected ? theme.colorScheme.secondary : theme.colorScheme.primary.withOpacity(0.4);
    
    return InkWell(
      onTap: () {
        if (label == 'HOME') {
          context.go('/home');
        } else if (label == 'SEARCH') {
          context.go('/products');
        } else if (label == 'CART') {
          context.go('/cart');
        } else if (label == 'PROFILE') {
          context.go('/profile');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
