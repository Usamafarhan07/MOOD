import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:async';
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
  late Future<List<Map<String, dynamic>>> _productsFuture;

  late final PageController _pageController;
  int _activePage = 0;
  Timer? _autoSlideTimer;

  late List<Map<String, String>> _bannerItems;

  @override
  void initState() {
    super.initState();
    _bannerItems = [];
    _productsFuture = _loadProducts(_selectedCategory);
    _pageController = PageController(initialPage: 0);
    _loadHomeBanners();
    _startAutoSlide();
  }

  Future<void> _loadHomeBanners() async {
    try {
      await _firestoreService.seedHomeBanners();
      await _firestoreService.seedAppConfigs();
      final snapshot = await _firestoreService
          .getHomeBanners()
          .first
          .timeout(const Duration(seconds: 8));

      final docs = snapshot.docs.toList()
        ..sort((a, b) {
          final aOrder = (a.data()['order'] as num?)?.toInt() ?? 999;
          final bOrder = (b.data()['order'] as num?)?.toInt() ?? 999;
          return aOrder.compareTo(bOrder);
        });

      final banners = docs
          .map((doc) {
            final data = doc.data();
            final isActive = data['isActive'];
            final imageUrl = data['imageUrl']?.toString().trim() ?? '';
            final title = data['title']?.toString().trim() ?? '';
            final subtitle = data['subtitle']?.toString().trim() ?? '';
            if (isActive == false || !imageUrl.startsWith('http')) {
              return null;
            }

            return <String, String>{
              'title': title.isNotEmpty ? title : 'MOOD Edit',
              'subtitle': subtitle.isNotEmpty
                  ? subtitle
                  : 'A curated selection for the modern wardrobe.',
              'imageUrl': imageUrl,
            };
          })
          .whereType<Map<String, String>>()
          .toList();

      if (!mounted || banners.isEmpty) return;

      setState(() {
        _bannerItems = banners;
        _activePage = 0;
      });
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    } catch (_) {
      // Keep fallback posters when Firestore banners are unavailable.
    }
  }

  void _selectCategory(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _productsFuture = _loadProducts(category);
    });
  }

  Future<List<Map<String, dynamic>>> _loadProducts(String category) async {
    try {
      final snapshot = await _firestoreService
          .getProducts(category: category)
          .first
          .timeout(const Duration(seconds: 8));
      final remoteProducts = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return _withUsableProductImage({'id': doc.id, ...data});
          })
          .where(_hasProductImage)
          .toList();

      final matchingRemote = remoteProducts
          .where((product) => _productMatchesCategory(product, category))
          .toList();

      return matchingRemote;
    } catch (_) {
      // Firestore is the source of truth for products.
    }

    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _withUsableProductImage(Map<String, dynamic> product) {
    return product;
  }

  bool _hasProductImage(Map<String, dynamic> product) {
    final imageUrl = product['imageUrl']?.toString().trim() ?? '';
    return imageUrl.startsWith('http');
  }

  bool _productMatchesCategory(Map<String, dynamic> product, String category) {
    if (category == 'All Items') return true;
    final productCategory = product['category']?.toString().toLowerCase() ?? '';
    final productLabel = product['label']?.toString().toLowerCase() ?? '';
    final selected = category.toLowerCase();
    if (selected == 'perfume / beauty') {
      return productCategory == selected ||
          productCategory == 'beauty' ||
          productCategory == 'perfume' ||
          productLabel == 'beauty' ||
          productLabel == 'perfume';
    }
    return productCategory == selected || productLabel == selected;
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && _bannerItems.isNotEmpty) {
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
                    if (_bannerItems.isEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        ),
                      )
                    else ...[
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
                                _PremiumNetworkImage(
                                  imageUrl: item['imageUrl']!,
                                  fit: BoxFit.cover,
                                  colorScheme: colorScheme,
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
                  children:
                      [
                        'All Items',
                        'Women',
                        'Men',
                        'Kids',
                        'Accessories',
                        'Perfume / Beauty',
                      ].map((cat) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: cat != 'Perfume / Beauty' ? 12 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _selectCategory(cat);
                            },
                            child: _buildCategoryChip(
                              cat,
                              _selectedCategory == cat,
                              colorScheme,
                              textTheme,
                            ),
                          ),
                        );
                      }).toList(),
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data ?? <Map<String, dynamic>>[];

                  final filteredProducts = products.where((product) {
                    final title = product['title']?.toString() ?? '';
                    final subtitle = product['subtitle']?.toString() ?? '';
                    final matchesCategory = _productMatchesCategory(
                      product,
                      _selectedCategory,
                    );
                    final matchesSearch =
                        title.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        subtitle.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        );
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
                              imageUrl:
                                  filteredProducts[i]['imageUrl']?.toString() ??
                                  '',
                              title:
                                  filteredProducts[i]['title']?.toString() ??
                                  'MOOD Piece',
                              subtitle:
                                  filteredProducts[i]['subtitle']?.toString() ??
                                  filteredProducts[i]['category']?.toString() ??
                                  'Luxury edit',
                              price:
                                  filteredProducts[i]['price']?.toString() ??
                                  'LKR 0',
                              productId:
                                  filteredProducts[i]['id']?.toString() ??
                                  filteredProducts[i]['title']?.toString() ??
                                  'mood-piece-$i',
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
                                          filteredProducts[i + 1]['imageUrl']
                                              ?.toString() ??
                                          '',
                                      title:
                                          filteredProducts[i + 1]['title']
                                              ?.toString() ??
                                          'MOOD Piece',
                                      subtitle:
                                          filteredProducts[i + 1]['subtitle']
                                              ?.toString() ??
                                          filteredProducts[i + 1]['category']
                                              ?.toString() ??
                                          'Luxury edit',
                                      price:
                                          filteredProducts[i + 1]['price']
                                              ?.toString() ??
                                          'LKR 0',
                                      productId:
                                          filteredProducts[i + 1]['id']
                                              ?.toString() ??
                                          filteredProducts[i + 1]['title']
                                              ?.toString() ??
                                          'mood-piece-${i + 1}',
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
                    _PremiumNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      colorScheme: theme.colorScheme,
                    ),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: theme.colorScheme.primary,
            ),
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

class _PremiumNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final ColorScheme colorScheme;

  const _PremiumNetworkImage({
    required this.imageUrl,
    required this.fit,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return _fallback();
    }

    return Image.network(
      imageUrl,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: colorScheme.surfaceContainerLow,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      color: colorScheme.surfaceContainerLow,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: colorScheme.primary.withValues(alpha: 0.38),
          size: 30,
        ),
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
          final priceValue = parsePriceValue(widget.price);
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
