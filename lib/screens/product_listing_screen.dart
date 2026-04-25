import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String _selectedFilter = 'All Items';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      extendBodyBehindAppBar: false,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120), // space for bottom nav
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The New Standard',
                    style: textTheme.displayLarge?.copyWith(
                      color: colorScheme.primary,
                      fontSize: 44,
                      letterSpacing: -1.0,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Curated essentials for the modern minimalist. Sustainably sourced, meticulously crafted.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF827470),
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F3EE),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: const Color(0xFFD4C3BE).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: colorScheme.primary.withOpacity(0.45), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                hintStyle: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary.withOpacity(0.35),
                                  letterSpacing: 0.3,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F3EE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFD4C3BE).withOpacity(0.3),
                      ),
                    ),
                    child: Icon(Icons.tune_outlined, color: colorScheme.primary.withOpacity(0.6), size: 22),
                  ),
                ],
              ),
            ),

            // Category Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: ['All Items', 'Outerwear', 'Knitwear', 'Accessories', 'Footwear'].map((filter) {
                  return Padding(
                    padding: EdgeInsets.only(right: filter != 'Footwear' ? 12 : 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: _buildCategoryChip(filter, _selectedFilter == filter, theme),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),

            // Product Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 16) / 2;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 40,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _buildProductCard(
                          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDymoKsAIvfdQ7KBLyLjqEaQepNjxtekA0M1wkEML8FcEeKpVqGkpxpuDGpw1dcwQ_n-1PQxdPPjGSwqnEMOUJDIXyK9WBgy9453nH4XXtw54vEM821IgkacaJ7Zmj0NIX-acZPl561lZQanQWLmm26kI43927VjM1fAIMuA7DA5GtvdlGoPfHnFTXYE67upgPLlybmXTCip4ktZhWpYrhk1tsrLJp86XWda4pkdbp5wjiEuPItGUmbD2SaVnJehFDYI-eJT6AyXd4',
                          label: 'Essentials',
                          title: 'Sculpted Wool Coat',
                          price: 'LKR 9000',
                          isFavorite: false,
                          theme: theme,
                          context: context,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _buildProductCard(
                          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuALvSkFfwTFYIKZ5Z5Nt4NNz-9nKGDEZ_gNjMlE4284bwR19QiJ-bLpwwB-vYMvXGmJdkqjO1fYlAwGbEwFU2rr2JQgHXEpF3SWkVIhsp41mSr6vzfPg3H5P7xtbgtzjfqZdr7VGFBBKJSn2-hTD0ef2YBvR3NNq8pGAe62EYNzxEv-m7JxE6qYMjGPH0H4NIqa0Fz2DJkKSOIkRkAVTbjm9ggaHN-6FpOSabg0KROZCKTxpFEXF0w61ufEhryJyIN3fGYYGhdUINA',
                          label: 'New Arrival',
                          title: 'Silk Drape Top',
                          price: 'LKR 6990',
                          isFavorite: false,
                          theme: theme,
                          context: context,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _buildProductCard(
                          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuANi3-qQOrGpGZpeLcS6CQ9c7GMLX8eIZ3nTheqoi831NEfpT5i5yAMEShgZNYqVhUm7yZbVtbLAY8LP9PAW4FtOSOGdLIYVtfi8Alt0YkPxhh8VXDWF7Mq9DFyrxPvWxJcOx44FnFd7uiyd0gvH4N-tqzNzqhqz9WBRK0vESkAcMVsGLRGEE5rtuECZdu45zUdoRShhcGcdQ5sZEg8Fwbw-FoniULYqpQN_v8_vsNAZO3iuS804ZJ12avik22-U7RJNTakZDI6Jrw',
                          label: 'Premium Collection',
                          title: 'Pleated Wide-Leg Trousers',
                          price: 'LKR 7590',
                          isFavorite: false,
                          theme: theme,
                          context: context,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _buildProductCard(
                          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDrXPQMd0cWdf_VeA4FlGE9ITGmurdStBOWg1lx5PgxWQQX8kYjrUAY7fH-D2sQhyIM-mvA1LGS7XYe7b-TPu8-ZsSrd63TxVabHWilJ2nLHke7e65x7I3NygeVLopjRK-tcBcRSGlBai7IM3a4xi7NMw1zqyOwc0fGDT9_B5hui4kI9saP8h9x0WevK0u4u_HyGVKhZuxvGq-F5ez_sWiZqLcPtsgJ6oko5UFxik27BuEKP4b3blRTo9Zeg8bC2lajE-MxFnx1_YA',
                          label: 'Knitwear',
                          title: 'Toscana Leather Boot',
                          price: 'LKR 15,000',
                          isFavorite: true,
                          theme: theme,
                          context: context,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 48),

            // Featured Series Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 256,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDmARXl_xj3ePXQapUG07ZDS75Y4eJoXZlQ3IS3bCLzBpgSTLMwUdhLPAzBvJv6_OPgl_PpPmYR78WPuk33Bx8wSzFanfsc6kE3zgkrQqy-WriyN4pBsVMEuyybk6lT4iTakt6bWMYY_Usn6uGN8ukopQTIK6rd-BswB-8qKnUJleUWKk-_lEm6NR0zg-1j-7C44pULX3msduzlOZBu7rjI_5GPvskCFAXC3eP4Wk_-DUOtLK4CdjWTJKV-cuCat2pJUgc0PigIVYY',
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
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Featured Series',
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Raw Denim Collection',
                              style: textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
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
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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
          ],
        ),
      ),
      
      // Bottom Navigation Bar (reusing style from Home)
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
                    _buildNavItem(Icons.home, 'HOME', false, () {
                      context.go('/home');
                    }, colorScheme),
                    _buildNavItem(Icons.search, 'SEARCH', true, () {}, colorScheme),
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

  Widget _buildCategoryChip(String label, bool isSelected, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(50),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: isSelected ? Colors.white : theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String imageUrl,
    required String label,
    required String title,
    required String price,
    required bool isFavorite,
    required ThemeData theme,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () {
        context.push('/product_details');
      },
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? theme.colorScheme.primary : theme.colorScheme.primary,
                          size: 18,
                        ),
                        onPressed: () {
                          context.push('/wishlist');
                        },
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: const Color(0xFF827470),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.primary.withOpacity(0.8),
          ),
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
