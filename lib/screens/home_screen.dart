import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood/services/firestore_service.dart';
import 'package:mood/widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedCategory = 'All Items';

  late final PageController _pageController;
  int _activePage = 0;
  Timer? _autoSlideTimer;

  final List<Map<String, String>> _bannerItems = [
    {
      'title': 'Summer Archive',
      'subtitle':
          'A curated selection of timeless silhouettes for the digital modernist.',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCtOnOOXGA2BDQydlnHCriYfQhXOuDXPi0asqNWUtsOsiqzq04udrkH3ks1A1LnMBCgNkcjN0LwOnDyMHeA4uVRbGMffd3N59C_ix6Gdp2nwjQHUYb03VoEX9AaR_Ci_ev0xmR2CsipxnX6I9PXOD0FNzXl6KyQkjeZCroPE6RDVI-1bZRLrhRupZx-u6feWiBpPJHrAHhDrUoaHYkXsYBufQae32TE-rg-hReKolFDH9xPRVcGh9IcYTGdC5ZUXyqk6k_8I3CLpeQ',
    },
    {
      'title': 'Nocturnal Atelier',
      'subtitle':
          'Explore avant-garde designs crafted with meticulous artisan precision.',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBSUm2Hob01-g_tKLPiTrydXSO7rX2c0FsCN9VsSHZ047yrWt269tz-nN1CtyhBmKtExK6U5F8JEqh672EAnOjsQtx6gMohfsCUmukjJeVQsHxHQvv8_3zgcUXQijzp9BrR6oRsR2r41Vpc6CS1cp8WH-WVxbb7RSEIEfTmBkMMYxtyH2bmAvlGSC04uq7iDWIEwuvpe_fQLGUihWNPK3g8ZhogSXUZOvH0BVTsFU74mXok6Yn5o6Wg8QPubkK5qH4kV9XtFg3Qw80',
    },
    {
      'title': 'Modern Simplicity',
      'subtitle':
          'Elevated essentials that balance everyday comfort and classic elegance.',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuANAwip_SplPsYu1rJwkTzQhd_dzGfh7uwXF0FI3F-lHpKmm5fpStr79od52os4NJR4zKgA6YLcksH08K2xjqwFQ_t1UtmjWQ1dHnpN_mwWn62EzDGyfWzFZEtCXUH14YWQn1CZS7i3FWARs0HcMcn_lCmVj1ETrrheRRAmjb8BUn4ZMZdBRJWc645GfXKUxY_Pzln4Cwihl3FeCLSR7D_OIzUzKHgS4gZonctdAlCElek4Ccedqtuc8Yna01YsiQB3fB40mQN1EKs',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_activePage + 1) % _bannerItems.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBody: true,
      drawer: const CustomDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu_rounded, color: colorScheme.primary),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
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
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: colorScheme.primary,
                  ),
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
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: colorScheme.primary.withValues(alpha: 0.5),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary.withValues(alpha: 0.35),
                            letterSpacing: 0.3,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
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
            const SizedBox(height: 32),

            // Sliding Hero Banner Carousel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                height: 500,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _activePage = index;
                          });
                        },
                        itemCount: _bannerItems.length,
                        itemBuilder: (context, index) {
                          final item = _bannerItems[index];
                          return GestureDetector(
                            onTap: () {
                              context.go('/products');
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  item['imageUrl']!,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: <Color>[
                                        colorScheme.primary.withValues(
                                          alpha: 0.75,
                                        ),
                                        colorScheme.primary.withValues(
                                          alpha: 0.15,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 40,
                                  left: 24,
                                  right: 24,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title']!,
                                        style: textTheme.displayLarge?.copyWith(
                                          color: Colors.white,
                                          fontSize: 42,
                                          height: 1.1,
                                          letterSpacing: -1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        item['subtitle']!,
                                        style: textTheme.bodyLarge?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                          fontSize: 16,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          gradient: LinearGradient(
                                            colors: <Color>[
                                              colorScheme.secondary,
                                              const Color(0xFFFE8763),
                                            ],
                                          ),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                              color: colorScheme.secondary
                                                  .withValues(alpha: 0.25),
                                              blurRadius: 15,
                                              offset: const Offset(0, 6),
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
                                              horizontal: 32,
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                          ),
                                          child: Text(
                                            'EXPLORE COLLECTION',
                                            style: textTheme.labelSmall
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 2.0,
                                                  fontSize: 11,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Indicator Dots
                    Positioned(
                      top: 24,
                      right: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _bannerItems.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: _activePage == index ? 20 : 6,
                            decoration: BoxDecoration(
                              color: _activePage == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                  children: ['All Items', 'Women', 'Men', 'Kids', 'Accessories']
                      .map((cat) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: cat != 'Accessories' ? 12 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                            child: _buildCategoryChip(
                              cat,
                              _selectedCategory == cat,
                              colorScheme,
                              textTheme,
                            ),
                          ),
                        );
                      })
                      .toList(),
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
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getProducts(
                  category: _selectedCategory,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {'id': doc.id, ...data};
                  }).toList();

                  final filteredProducts = products.where((product) {
                    final productCat =
                        (product['category'] as String?)?.toLowerCase() ?? '';
                    final productLabel =
                        (product['label'] as String?)?.toLowerCase() ?? '';
                    final matchesCategory =
                        _selectedCategory == 'All Items' ||
                        productCat == _selectedCategory.toLowerCase() ||
                        (_selectedCategory == 'Accessories' &&
                            productLabel == 'accessories');
                    final matchesSearch = product['title']!
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
                    return matchesCategory && matchesSearch;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'No products found.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF827470),
                          ),
                        ),
                      ),
                    );
                  }

                  final List<Widget> rows = [];
                  for (int i = 0; i < filteredProducts.length; i += 2) {
                    rows.add(
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildProductCard(
                              imageUrl: filteredProducts[i]['imageUrl']!,
                              title: filteredProducts[i]['title']!,
                              subtitle: filteredProducts[i]['subtitle']!,
                              price: filteredProducts[i]['price']!,
                              productId: filteredProducts[i]['id']!.toString(),
                              isFavorite: false,
                              theme: theme,
                              context: context,
                              productData: filteredProducts[i],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: (i + 1 < filteredProducts.length)
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 48.0),
                                    child: _buildProductCard(
                                      imageUrl:
                                          filteredProducts[i + 1]['imageUrl']!,
                                      title: filteredProducts[i + 1]['title']!,
                                      subtitle:
                                          filteredProducts[i + 1]['subtitle']!,
                                      price: filteredProducts[i + 1]['price']!,
                                      productId: filteredProducts[i + 1]['id']!
                                          .toString(),
                                      isFavorite: false,
                                      theme: theme,
                                      context: context,
                                      productData: filteredProducts[i + 1],
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    );
                    if (i + 2 < filteredProducts.length) {
                      rows.add(const SizedBox(height: 40));
                    }
                  }

                  return Column(children: rows);
                },
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
                  color: colorScheme.surfaceContainerLow,
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
                        color: colorScheme.primary.withValues(alpha: 0.7),
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
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: colorScheme.primary,
                        ),
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
          color: colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.05),
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
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 32,
                left: 16,
                right: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, 'HOME', true, () {}, colorScheme),
                  _buildNavItem(Icons.search, 'SEARCH', false, () {
                    context.go('/products');
                  }, colorScheme),
                  _buildNavItem(
                    Icons.shopping_cart_outlined,
                    'CART',
                    false,
                    () {
                      context.go('/cart');
                    },
                    colorScheme,
                  ),
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

  Widget _buildCategoryChip(
    String label,
    bool isActive,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(50),
        boxShadow: isActive
            ? <BoxShadow>[
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
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
          color: isActive ? colorScheme.surface : colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String imageUrl,
    required String title,
    required String subtitle,
    required String price,
    required String productId,
    required bool isFavorite,
    required ThemeData theme,
    required BuildContext context,
    required Map<String, dynamic> productData,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/product_details', extra: productData);
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
                color: theme.colorScheme.surfaceContainerLow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(imageUrl, fit: BoxFit.cover),
                    // Favorite Button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _FavoriteButton(
                        initialIsFavorite: isFavorite,
                        theme: theme,
                        title: title,
                        price: price,
                        imageUrl: imageUrl,
                        productId: productId,
                        subtitle: subtitle,
                        firestoreService: _firestoreService,
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
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
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

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? colorScheme.secondary
                : colorScheme.primary.withValues(alpha: 0.4),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? colorScheme.secondary
                  : colorScheme.primary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final bool initialIsFavorite;
  final ThemeData theme;
  final String title;
  final String price;
  final String imageUrl;
  final String productId;
  final String subtitle;
  final FirestoreService firestoreService;

  const _FavoriteButton({
    required this.initialIsFavorite,
    required this.theme,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.productId,
    required this.subtitle,
    required this.firestoreService,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFavorite = !_isFavorite;
        });

        if (_isFavorite) {
          final priceValue =
              int.tryParse(widget.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          widget.firestoreService.addWishlistItem(
            productId: widget.productId,
            title: widget.title,
            subtitle: widget.subtitle,
            price: priceValue,
            imageUrl: widget.imageUrl,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Saved to Wishlist'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: widget.theme.colorScheme.primary,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        } else {
          widget.firestoreService.removeWishlistItem(widget.productId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Removed from Wishlist'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: widget.theme.colorScheme.error,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.surfaceContainerLow.withValues(
            alpha: 0.8,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: widget.theme.colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }
}
