import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood/services/firestore_service.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String _selectedFilter = 'All Items';
  String _searchQuery = '';
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: false,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
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
                      color: colorScheme.primary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
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
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getProducts(label: _selectedFilter),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {
                      'id': doc.id,
                      ...data,
                    };
                  }).toList();

                  final itemWidth = (MediaQuery.of(context).size.width - 16 - 48) / 2;
                  final filteredProducts = products.where((product) {
                    final matchesFilter = _selectedFilter == 'All Items' || product['label'] == _selectedFilter;
                    final matchesSearch = product['title']!.toLowerCase().contains(_searchQuery.toLowerCase());
                    return matchesFilter && matchesSearch;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'No products found.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 16,
                    runSpacing: 40,
                    children: filteredProducts.map((product) {
                      return SizedBox(
                        width: itemWidth,
                        child: _buildProductCard(
                          imageUrl: product['imageUrl']!,
                          label: product['label']!,
                          title: product['title']!,
                          price: product['price']!,
                          productId: product['id']!.toString(),
                          isFavorite: false,
                          theme: theme,
                          context: context,
                          productData: product,
                        ),
                      );
                    }).toList(),
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
                            colors: <Color>[
                              colorScheme.primary.withValues(alpha: 0.6),
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
                                color: Colors.white.withValues(alpha: 0.9),
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
                                  colors: <Color>[
                                    colorScheme.secondary,
                                    const Color(0xFFFE8763),
                                  ],
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: colorScheme.secondary.withValues(alpha: 0.2),
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
          color: colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.05),
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
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: isSelected ? theme.colorScheme.surface : theme.colorScheme.primary,
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
    required String productId,
    required bool isFavorite,
    required ThemeData theme,
    required BuildContext context,
    required Map<String, dynamic> productData,
  }) {
    return InkWell(
      onTap: () {
        context.push('/product_details', extra: productData);
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
                child: _FavoriteButton(
                  initialIsFavorite: isFavorite,
                  theme: theme,
                  title: title,
                  price: price,
                  imageUrl: imageUrl,
                  productId: productId,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
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
            color: theme.colorScheme.primary.withValues(alpha: 0.8),
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
            color: isActive ? colorScheme.secondary : colorScheme.primary.withValues(alpha: 0.4),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? colorScheme.secondary : colorScheme.primary.withValues(alpha: 0.4),
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

  const _FavoriteButton({
    required this.initialIsFavorite,
    required this.theme,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.productId,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  final FirestoreService _firestoreService = FirestoreService();
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
  }

  Future<void> _updateWishlist(bool isFavorite) async {
    final priceValue = int.tryParse(widget.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (isFavorite) {
      await _firestoreService.addWishlistItem(
        productId: widget.productId,
        title: widget.title,
        imageUrl: widget.imageUrl,
        price: priceValue,
        subtitle: 'Category • Color',
      );
    } else {
      await _firestoreService.removeWishlistItem(widget.productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.theme.colorScheme.primary,
              size: 18,
            ),
            onPressed: () async {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              await _updateWishlist(_isFavorite);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorite ? 'Saved to Wishlist' : 'Removed from Wishlist'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: _isFavorite ? widget.theme.colorScheme.primary : widget.theme.colorScheme.error,
                  duration: const Duration(seconds: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ),
    );
  }
}
