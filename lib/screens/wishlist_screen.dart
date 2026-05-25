import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:mood/services/firestore_service.dart';
import 'package:mood/widgets/firestore_image.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  String _formatCurrency(int amount) {
    return 'LKR ${amount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: false,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
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
      body: currentUser == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Please sign in to see your wishlist.',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestoreService.getWishlistStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading wishlist: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final wishlistItems = snapshot.data?.docs.map((doc) {
                  return WishlistItem.fromSnapshot(doc);
                }).toList() ?? [];

                return SingleChildScrollView(
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
                                color: colorScheme.primary.withValues(alpha: 0.6),
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
                                color: colorScheme.primary.withValues(alpha: 0.6),
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
                            if (wishlistItems.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Text('Your wishlist is empty', style: textTheme.bodyMedium),
                              )
                            else
                              ...wishlistItems.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 48),
                                  child: _buildWishlistItem(
                                    context: context,
                                    item: item,
                                    theme: theme,
                                    onRemove: () async {
                                      await _firestoreService.removeWishlistById(item.id);
                                    },
                                  ),
                                );
                              }),
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
                );
              },
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.04),
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
    required BuildContext context,
    required WishlistItem item,
    required ThemeData theme,
    required VoidCallback onRemove,
  }) {
    final label = item.subtitle?.split('•').first.trim() ?? '';
    return InkWell(
      onTap: () {
        context.push('/product_details', extra: {
          'id': item.productId,
          'title': item.title,
          'price': _formatCurrency(item.price),
          'label': label,
          'imageUrl': item.imageUrl,
        });
      },
      child: Column(
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
                  child: FirestoreImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: _FavoriteButton(
                    initialIsFavorite: true,
                    theme: theme,
                    onRemove: onRemove,
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
                  item.title,
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
                _formatCurrency(item.price),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.subtitle ?? 'Category • Color',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
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
                colors: <Color>[
                  theme.colorScheme.secondary,
                  const Color(0xFFFE8763),
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
                await _firestoreService.addOrUpdateCartItem(
                  productId: item.productId.isNotEmpty ? item.productId : item.title,
                  title: item.title,
                  imageUrl: item.imageUrl,
                  price: item.price,
                  subtitle: item.subtitle,
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added to cart successfully!',
                      style: TextStyle(color: theme.colorScheme.onSecondary),
                    ),
                    backgroundColor: theme.colorScheme.secondary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
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
  final VoidCallback onRemove;

  const _FavoriteButton({
    required this.initialIsFavorite,
    required this.theme,
    required this.onRemove,
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
    return Container(
      width: 48,
      height: 48,
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
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              if (!_isFavorite) {
                widget.onRemove();
              }
            },
          ),
        ),
      ),
    );
  }
}
