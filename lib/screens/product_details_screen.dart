import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:mood/screens/shopping_cart_screen.dart';
import 'package:mood/screens/wishlist_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? productData;

  const ProductDetailsScreen({super.key, this.productData});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 2; // Default to 'M'

  late List<Color> _colors;
  late List<String> _sizes;
  late String _description;

  @override
  void initState() {
    super.initState();
    final productData = widget.productData ?? {};
    _colors = productData['colors'] as List<Color>? ?? [
      const Color(0xFF0D1B2A),
      const Color(0xFF5D675B),
      const Color(0xFFE5E2DD),
      const Color(0xFF704225),
    ];
    _sizes = productData['sizes'] as List<String>? ?? ['XS', 'S', 'M', 'L', 'XL'];
    _description = productData['description'] as String? ?? 
      'A masterclass in minimalist design. This piece is crafted from ethically sourced premium materials. Featuring a clean, architectural silhouette that transcends seasonal trends.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final productData = widget.productData ?? {};
    final title = productData['title'] ?? 'Structured Wool Belted Coat';
    final price = productData['price'] ?? 'LKR 9,000';
    final label = productData['label'] ?? 'AUTUMN/WINTER 24';
    final imageUrl = productData['imageUrl'] ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuANAwip_SplPsYu1rJwkTzQhd_dzGfh7uwXF0FI3F-lHpKmm5fpStr79od52os4NJR4zKgA6YLcksH08K2xjqwFQ_t1UtmjWQ1dHnpN_mwWn62EzDGyfWzFZEtCXUH14YWQn1CZS7i3FWARs0HcMcn_lCmVj1ETrrheRRAmjb8BUn4ZMZdBRJWc645GfXKUxY_Pzln4Cwihl3FeCLSR7D_OIzUzKHgS4gZonctdAlCElek4Ccedqtuc8Yna01YsiQB3fB40mQN1EKs';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: colorScheme.surface.withValues(alpha: 0.7),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140), // space for bottom sticky button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                      
                      // Floating Product Header Overlay
                      Positioned(
                        bottom: 24,
                        left: 16,
                        right: 16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(alpha: 0.08),
                                    blurRadius: 80,
                                    offset: const Offset(0, 40),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label.toUpperCase(),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    title,
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              price,
                                              style: textTheme.labelLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: colorScheme.surfaceContainerLow,
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.star, size: 12, color: colorScheme.primary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '4.9 (128 Reviews)',
                                                  style: textTheme.labelSmall?.copyWith(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Floating Action Buttons (after overlay so they render on top)
                      Positioned(
                        right: 24,
                        bottom: 230,
                        child: Column(
                          children: [
                            _buildFloatingButton(Icons.favorite, true, colorScheme, onTap: () {
                              final existingIndex = globalWishlistItems.indexWhere((item) => item.title == title);
                              if (existingIndex < 0) {
                                globalWishlistItems.add(
                                  WishlistItemData(
                                    imageUrl: imageUrl,
                                    title: title,
                                    price: price,
                                    subtitle: 'Category â€¢ Color', // Could be made more dynamic if needed
                                  ),
                                );
                              }
                              context.push('/wishlist');
                            }),
                            const SizedBox(height: 12),
                            _buildFloatingButton(Icons.share_outlined, false, colorScheme),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Details Content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The Detail
                      Text(
                        'THE DETAIL',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _description,
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF504441),
                          height: 1.8,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Select Palette
                      Text(
                        'SELECT PALETTE',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: List.generate(_colors.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColorIndex = index;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedColorIndex == index
                                        ? colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _colors[index],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Select Size
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SELECT SIZE',
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            'SIZE GUIDE',
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: const Color(0xFF504441),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_sizes.length, (index) {
                          final isSelected = _selectedSizeIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSizeIndex = index;
                              });
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected ? colorScheme.onSurface : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _sizes[index],
                                style: textTheme.labelSmall?.copyWith(
                                  color: isSelected ? Colors.white : colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Expandable Sections
                      const Divider(height: 1),
                      _buildExpandableRow('Composition & Care', theme),
                      const Divider(height: 1),
                      _buildExpandableRow('Shipping & Sustainability', theme),
                      const Divider(height: 1),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // Complete The Look Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colorScheme.surfaceDim.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Complete the Look',
                        style: textTheme.headlineSmall?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Trousers Card
                      InkWell(
                        onTap: () {
                          context.push('/product_details', extra: {
                            'title': 'Premium Pleated Trousers',
                            'price': 'LKR 4500',
                            'label': 'Premium',
                            'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCW6NAFE9Gwty6Xcs4XZyOa4mIeb_jNiN__C94O1OjjjbJATRlpiV5SFL80Jf4aCQMpmI-GJyKwPEeeWLzEEkUQF3V1ajISaydZ_SskVyJocbaQ24klUXlwL-ED0piMrMX9GwbF0kgmRjkNorp9dQFtEPNMWO1x1xF52_xh3qbfsEBQamzSnFbCgSCkdf56ZukXh3wyWi4oI5ifk5HrTFcjxJVdSZXlu8dFriUE7NPoCtjPth2XjP9_EtNG4QIzy4mpkEmRpOMhwCM',
                          });
                        },
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCW6NAFE9Gwty6Xcs4XZyOa4mIeb_jNiN__C94O1OjjjbJATRlpiV5SFL80Jf4aCQMpmI-GJyKwPEeeWLzEEkUQF3V1ajISaydZ_SskVyJocbaQ24klUXlwL-ED0piMrMX9GwbF0kgmRjkNorp9dQFtEPNMWO1x1xF52_xh3qbfsEBQamzSnFbCgSCkdf56ZukXh3wyWi4oI5ifk5HrTFcjxJVdSZXlu8dFriUE7NPoCtjPth2XjP9_EtNG4QIzy4mpkEmRpOMhwCM',
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.6),
                                        Colors.transparent,
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 24,
                                  left: 24,
                                  right: 24,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Premium Pleated Trousers',
                                              style: textTheme.labelLarge?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'LKR 4500',
                                              style: textTheme.labelSmall?.copyWith(
                                                color: Colors.white.withValues(alpha: 0.8),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.add, color: colorScheme.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Silk Detail Card
                      AspectRatio(
                        aspectRatio: 2 / 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuDalJJRcFLKp8me8gCX4iZwv9MZbOr8c8djfIs7ucQtqRtzkWp7u2QIFuq2vmnw6qPkZfsUYPloKl3caYqisyw__lXUNmS41iD1NcoS8zHPcr4AIXpxUjE6dC5FrTZbGHrgSUX9plEgJejQxR1QZ1uxjxmZRTzxgaw5hDWv6tiMBsGwxB1P9WpKvJpoi4xP_AfE9Akq42xRlbqu1PRV6mC3RaVQR9VbMtipWNQ7KmFphHGG_SAA2kRsEoUE8KI3GeepBGFugirO42A',
                                fit: BoxFit.cover,
                              ),
                              Container(color: Colors.black.withValues(alpha: 0.2)),
                              Center(
                                child: Text(
                                  'EST. 1924',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4.0,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Sustainable Choice Card
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: colorScheme.outline.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.eco_outlined, color: colorScheme.primary, size: 32),
                            const SizedBox(height: 16),
                            Text(
                              'Sustainable Choice',
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Part of our 'Earth Conscious' collection, made with 100% recycled wool fibers.",
                              textAlign: TextAlign.center,
                              style: textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF504441),
                                height: 1.5,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky Add to Cart Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.secondary,
                          const Color(0xFFFE8763), // secondary container
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.secondary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        final priceStr = price.replaceAll(RegExp(r'[^0-9]'), '');
                        final unitPrice = int.tryParse(priceStr) ?? 0;
                        
                        final existingIndex = globalCartItems.indexWhere((item) => item.title == title);
                        if (existingIndex >= 0) {
                          globalCartItems[existingIndex].quantity++;
                        } else {
                          // Simple mapping to get color name from hex
                          String colorName = 'Selected Color';
                          if (_colors[_selectedColorIndex].value == const Color(0xFF0D1B2A).value) colorName = 'Midnight Blue';
                          if (_colors[_selectedColorIndex].value == const Color(0xFF5D675B).value) colorName = 'Olive Green';
                          if (_colors[_selectedColorIndex].value == const Color(0xFFE5E2DD).value) colorName = 'Cream White';
                          if (_colors[_selectedColorIndex].value == const Color(0xFF704225).value) colorName = 'Espresso Brown';

                          globalCartItems.add(
                            CartItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              imageUrl: imageUrl,
                              title: title,
                              subtitle: '$colorName / ${_sizes[_selectedSizeIndex]}',
                              unitPrice: unitPrice,
                            ),
                          );
                        }
                        context.push('/cart');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'ADD TO CART',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, bool filledIcon, ColorScheme colorScheme, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildExpandableRow(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: theme.colorScheme.primary,
            ),
          ),
          Icon(Icons.expand_more, color: theme.colorScheme.primary),
        ],
      ),
    );
  }
}
