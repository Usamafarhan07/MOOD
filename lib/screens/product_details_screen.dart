import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mood/services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? productData;
  final String? productId;

  const ProductDetailsScreen({super.key, this.productData, this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  static const _shareChannel = MethodChannel('com.example.mood/share');
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 2; // Default to 'M'

  late List<Color> _colors;
  late List<String> _sizes;
  late String _description;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isCompositionExpanded = false;
  bool _isShippingExpanded = false;

  bool _isLoading = false;
  Map<String, dynamic>? _currentProductData;
  String? _errorMessage;
  String? _trousersImageUrl;
  String? _silkImageUrl;

  @override
  void initState() {
    super.initState();
    _loadLookImages();
    if (widget.productData != null && widget.productData!.isNotEmpty) {
      _currentProductData = widget.productData!;
      _initializeProductDetails(_currentProductData!);
    } else if (widget.productId != null && widget.productId!.isNotEmpty) {
      _loadProductFromFirestore(widget.productId!);
    } else {
      _currentProductData = {};
      _initializeProductDetails({});
    }
  }

  Future<void> _loadLookImages() async {
    final trousers = await _firestoreService.getAppConfigUrl('look_trousers');
    final silk = await _firestoreService.getAppConfigUrl('look_silk');
    if (mounted) {
      setState(() {
        _trousersImageUrl = trousers;
        _silkImageUrl = silk;
      });
    }
  }

  void _initializeProductDetails(Map<String, dynamic> data) {
    final dynamic rawColors = data['colors'];
    if (rawColors is List) {
      _colors = rawColors.map((c) {
        if (c is int) return Color(c);
        if (c is String) {
          final hexString = c.startsWith('#')
              ? c.replaceFirst('#', '0xFF')
              : '0xFF$c';
          return Color(int.tryParse(hexString) ?? 0xFF000000);
        }
        return const Color(0xFF0D1B2A);
      }).toList();
    } else {
      _colors = <Color>[
        const Color(0xFF0D1B2A),
        const Color(0xFF5D675B),
        const Color(0xFFE5E2DD),
        const Color(0xFF704225),
      ];
    }

    final dynamic rawSizes = data['sizes'];
    if (rawSizes is List) {
      _sizes = rawSizes.map((s) => s.toString()).toList();
    } else {
      _sizes = <String>['XS', 'S', 'M', 'L', 'XL'];
    }
    _description =
        data['description'] as String? ??
        'A masterclass in minimalist design. This piece is crafted from ethically sourced premium materials. Featuring a clean, architectural silhouette that transcends seasonal trends.';
  }

  Future<void> _loadProductFromFirestore(String id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final doc = await _firestoreService.getProductById(id);
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        setState(() {
          _currentProductData = data;
          _initializeProductDetails(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Product not found';
          _isLoading = false;
          _initializeProductDetails({});
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load product: $e';
        _isLoading = false;
        _initializeProductDetails({});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Fetching piece details...',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.error,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => context.go('/home'),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final productData = _currentProductData ?? widget.productData ?? {};
    final title = productData['title'] ?? 'Structured Wool Belted Coat';
    final price = productData['price'] ?? 'LKR 9,000';
    final label = productData['label'] ?? 'AUTUMN/WINTER 24';
    final imageUrl = productData['imageUrl'] ?? '';

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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 140,
            ), // space for bottom sticky button
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
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF1E1A18),
                          );
                        },
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
                                color: colorScheme.surface.withValues(
                                  alpha: 0.7,
                                ),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.08,
                                    ),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              price,
                                              style: textTheme.labelLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 20,
                                                    letterSpacing: -0.5,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: colorScheme
                                                    .surfaceContainerLow,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 12,
                                                    color: colorScheme.primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '4.9 (128 Reviews)',
                                                    style: textTheme.labelSmall
                                                        ?.copyWith(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                            _buildFloatingButton(
                              Icons.favorite,
                              true,
                              colorScheme,
                              onTap: () async {
                                final productId =
                                    productData['id']?.toString() ?? title;
                                final priceValue = parsePriceValue(price);
                                await _firestoreService.addWishlistItem(
                                  productId: productId,
                                  title: title,
                                  imageUrl: imageUrl,
                                  price: priceValue,
                                  subtitle: label?.toString(),
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Saved to Wishlist'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: colorScheme.primary,
                                    duration: const Duration(seconds: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                                context.push('/wishlist');
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildFloatingButton(
                              Icons.share_outlined,
                              false,
                              colorScheme,
                              onTap: () {
                                _showShareSheet(
                                  context,
                                  title,
                                  label?.toString() ?? 'PIECE',
                                  imageUrl,
                                  productData['id']?.toString() ?? title,
                                );
                              },
                            ),
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
                          color: colorScheme.primary.withValues(alpha: 0.7),
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
                              color: colorScheme.primary.withValues(alpha: 0.6),
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
                                color: isSelected
                                    ? colorScheme.onSurface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : colorScheme.outlineVariant,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _sizes[index],
                                style: textTheme.labelSmall?.copyWith(
                                  color: isSelected
                                      ? theme.colorScheme.surface
                                      : theme.colorScheme.onSurface,
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
                      _buildExpandableRow(
                        title: 'Composition & Care',
                        theme: theme,
                        isExpanded: _isCompositionExpanded,
                        onTap: () {
                          setState(() {
                            _isCompositionExpanded = !_isCompositionExpanded;
                          });
                        },
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBulletPoints(
                              productData['composition'],
                              colorScheme,
                              textTheme,
                              const ['80% Organic Wool, 20% Recycled Cashmere'],
                            ),
                            const SizedBox(height: 6),
                            _buildBulletPoints(
                              productData['careInstructions'] ??
                                  productData['care'],
                              colorScheme,
                              textTheme,
                              const [
                                'Dry clean only. Do not wash. Do not bleach. Cool iron if needed.',
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      _buildExpandableRow(
                        title: 'Shipping & Sustainability',
                        theme: theme,
                        isExpanded: _isShippingExpanded,
                        onTap: () {
                          setState(() {
                            _isShippingExpanded = !_isShippingExpanded;
                          });
                        },
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBulletPoints(
                              productData['shippingDetails'] ??
                                  productData['shipping'],
                              colorScheme,
                              textTheme,
                              const [
                                'Standard Delivery: 3-5 business days. Free on all orders.',
                              ],
                            ),
                            const SizedBox(height: 6),
                            _buildBulletPoints(
                              productData['sustainability'],
                              colorScheme,
                              textTheme,
                              const [
                                'Ethically crafted in our certified carbon-neutral facility.',
                                'Shipped in 100% biodegradable and zero-plastic packaging.',
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // Complete The Look Section
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 48.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
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
                          context.push(
                            '/product_details',
                            extra: {
                              'title': 'Premium Pleated Trousers',
                              'price': 'LKR 4500',
                              'label': 'Premium',
                              'imageUrl': _trousersImageUrl ?? '',
                            },
                          );
                        },
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (_trousersImageUrl == null)
                                  Container(
                                    color: colorScheme.surfaceContainerLow,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  )
                                else
                                  Image.network(
                                    _trousersImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: const Color(0xFF1E1A18),
                                    ),
                                  ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: <Color>[
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Premium Pleated Trousers',
                                              style: textTheme.labelLarge
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'LKR 4500',
                                              style: textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.8),
                                                    fontSize: 14,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: colorScheme.onPrimary,
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
                      const SizedBox(height: 32),

                      // Silk Detail Card
                      AspectRatio(
                        aspectRatio: 2 / 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (_silkImageUrl == null)
                                Container(
                                  color: colorScheme.surfaceContainerLow,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                )
                              else
                                Image.network(
                                  _silkImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFF1E1A18),
                                  ),
                                ),
                              Container(
                                color: Colors.black.withValues(alpha: 0.2),
                              ),
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
                            Icon(
                              Icons.eco_outlined,
                              color: colorScheme.primary,
                              size: 32,
                            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: <Color>[
                          colorScheme.secondary,
                          const Color(0xFFFE8763), // secondary container
                        ],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: colorScheme.secondary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final unitPrice = parsePriceValue(price);
                        String colorName = 'Selected Color';
                        if (_colors[_selectedColorIndex] ==
                            const Color(0xFF0D1B2A)) {
                          colorName = 'Midnight Blue';
                        }
                        if (_colors[_selectedColorIndex] ==
                            const Color(0xFF5D675B)) {
                          colorName = 'Olive Green';
                        }
                        if (_colors[_selectedColorIndex] ==
                            const Color(0xFFE5E2DD)) {
                          colorName = 'Cream White';
                        }
                        if (_colors[_selectedColorIndex] ==
                            const Color(0xFF704225)) {
                          colorName = 'Espresso Brown';
                        }

                        final productId =
                            productData['id']?.toString() ?? title;
                        await _firestoreService.addOrUpdateCartItem(
                          productId: productId,
                          title: title,
                          imageUrl: imageUrl,
                          price: unitPrice,
                          subtitle:
                              '$colorName / ${_sizes[_selectedSizeIndex]}',
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added to cart successfully!',
                              style: TextStyle(color: colorScheme.onSecondary),
                            ),
                            backgroundColor: colorScheme.secondary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
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

  Widget _buildFloatingButton(
    IconData icon,
    bool filledIcon,
    ColorScheme colorScheme, {
    VoidCallback? onTap,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF2F2421) // Premium rich dark cocoa brown
              : const Color(0xFFFCF9F4), // Warm premium cream white
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? const Color(0xFFFCF9F4).withValues(
                    alpha: 0.2,
                  ) // Elegant light border for dark mode
                : const Color(0xFF442A22).withValues(
                    alpha: 0.15,
                  ), // Elegant dark border for light mode
            width: 1.5, // Crisp high-fidelity border line
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: icon == Icons.favorite && filledIcon
              ? const Color(
                  0xFFE63946,
                ) // Vibrant premium cherry red for the liked/favorite status
              : (isDark
                    ? const Color(0xFFFCF9F4)
                    : const Color(
                        0xFF442A22,
                      )), // High contrast cream / dark brown
          size: 20,
        ),
      ),
    );
  }

  Widget _buildExpandableRow({
    required String title,
    required ThemeData theme,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            if (isExpanded) ...[const SizedBox(height: 16), content],
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoints(
    dynamic data,
    ColorScheme colorScheme,
    TextTheme textTheme,
    List<String> fallbacks,
  ) {
    if (data == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fallbacks
            .map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  f.startsWith('•') ? f : '• $f',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ),
            )
            .toList(),
      );
    }

    List<String> items = [];
    if (data is List) {
      items = data.map((e) => e.toString()).toList();
    } else if (data is String) {
      if (data.contains('\n')) {
        items = data.split('\n');
      } else {
        items = [data];
      }
    }

    if (items.isEmpty) {
      items = fallbacks;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        final cleanItem = item.startsWith('•') ? item : '• $item';
        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Text(
            cleanItem,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        );
      }).toList(),
    );
  }

  static const String _whatsappSvg = '''
<svg viewBox="0 0 24 24" fill="currentColor">
  <path d="M.057 24l1.687-6.163c-1.041-1.804-1.588-3.849-1.587-5.946C.06 5.348 5.397.01 12.008.01c3.202.001 6.212 1.246 8.477 3.514 2.266 2.268 3.507 5.28 3.505 8.484-.004 6.657-5.34 11.997-11.953 11.997-2.005-.001-3.973-.502-5.73-1.464L0 24zm6.59-4.846c1.6.95 3.197 1.451 4.786 1.451 5.378 0 9.754-4.373 9.757-9.752.001-2.585-1.002-5.015-2.825-6.84S14.2 1.258 11.614 1.258c-5.38 0-9.757 4.374-9.76 9.754-.001 1.636.43 3.232 1.247 4.62l-.994 3.634 3.738-.98c1.393.81 2.923 1.233 4.417 1.233-.001 0 0 0 0 0zm8.384-5.328c-.287-.144-1.696-.838-1.958-.933-.263-.096-.454-.144-.645.144-.191.288-.74.933-.907 1.124-.167.192-.335.216-.622.072-.288-.144-1.215-.448-2.316-1.43-1.001-.892-1.39-1.582-1.581-1.87-.192-.289-.02-.445.124-.588.13-.129.288-.335.43-.503.144-.167.192-.288.288-.48.096-.191.048-.36-.024-.503-.072-.144-.645-1.558-.884-2.132-.233-.56-.47-.483-.645-.492-.167-.008-.36-.01-.55-.01-.19 0-.502.072-.765.36-.263.288-1.004.981-1.004 2.394 0 1.413 1.028 2.78 1.171 2.973.144.192 2.023 3.09 4.9 4.33.684.295 1.218.47 1.634.602.687.218 1.312.187 1.806.114.55-.082 1.696-.693 1.935-1.363.239-.67.239-1.244.167-1.363-.072-.119-.263-.191-.55-.335z"/>
</svg>
''';

  static const String _instagramSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <rect x="2" y="2" width="20" height="20" rx="5" ry="5"></rect>
  <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"></path>
  <line x1="17.5" y1="6.5" x2="17.51" y2="6.5"></line>
</svg>
''';

  static const String _facebookSvg = '''
<svg viewBox="0 0 24 24" fill="currentColor">
  <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
</svg>
''';

  void _showShareSheet(
    BuildContext context,
    String title,
    String category,
    String imageUrl,
    String productId,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final String shareLink;
    if (kIsWeb) {
      final baseUri = Uri.base;
      final origin =
          '${baseUri.scheme}://${baseUri.host}${baseUri.hasPort ? ':${baseUri.port}' : ''}';
      shareLink = '$origin/#/piece/$productId';
    } else {
      shareLink = 'https://mood-store-3f4f7.web.app/#/piece/$productId';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: colorScheme.surface.withValues(alpha: 0.85),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 48,
                      ), // Balancing spacer for the X button
                      Expanded(
                        child: Center(
                          child: Text(
                            'Share to',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colorScheme.primary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Product Preview Card in Share Sheet
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: colorScheme.primary,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.toUpperCase(),
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Scrollable Share Options Grid with Pixel-Perfect Solid Brand Colors
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildShareOption(
                          context,
                          icon: Icons.chat_bubble,
                          iconColor: Colors.white,
                          label: 'Message',
                          backgroundColor: const Color(0xFF34C759),
                          onTap: () async {
                            Navigator.pop(context);
                            await _shareToTelegram(title, shareLink);
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildShareOption(
                          context,
                          customIcon: SvgPicture.string(
                            _facebookSvg,
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: 'Facebook',
                          backgroundColor: const Color(0xFF1877F2),
                          onTap: () async {
                            Navigator.pop(context);
                            await _shareToFacebook(shareLink);
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildShareOption(
                          context,
                          customIcon: SvgPicture.string(
                            _instagramSvg,
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: 'Post',
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF833AB4), // Purple
                              Color(0xFFFD1D1D), // Red
                              Color(0xFFFCAF45), // Yellow
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                          onTap: () async {
                            Navigator.pop(context);
                            final message =
                                'Check out this piece on MOOD: $title\n$shareLink';
                            await _shareNatively(
                              message,
                              'Share via Instagram',
                              shareLink,
                            );
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildShareOption(
                          context,
                          customIcon: SvgPicture.string(
                            _whatsappSvg,
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: 'Whatsapp',
                          backgroundColor: const Color(0xFF25D366),
                          onTap: () async {
                            Navigator.pop(context);
                            await _shareToWhatsApp(title, shareLink);
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildShareOption(
                          context,
                          icon: Icons.link_rounded,
                          iconColor: theme.brightness == Brightness.light
                              ? Colors.black87
                              : Colors.white70,
                          label: 'Copy Link',
                          backgroundColor: theme.brightness == Brightness.light
                              ? const Color(0xFFF5F5F7)
                              : const Color(0xFF2C2C2E),
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(text: shareLink),
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Link copied to clipboard!',
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildShareOption(
                          context,
                          icon: Icons.more_horiz_rounded,
                          iconColor: theme.brightness == Brightness.light
                              ? Colors.black87
                              : Colors.white70,
                          label: 'More',
                          backgroundColor: theme.brightness == Brightness.light
                              ? const Color(0xFFF5F5F7)
                              : const Color(0xFF2C2C2E),
                          onTap: () async {
                            Navigator.pop(context);
                            final message =
                                'Check out this piece on MOOD: $title\n$shareLink';
                            await _shareNatively(
                              message,
                              'Share Piece',
                              shareLink,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    IconData? icon,
    Widget? customIcon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? backgroundColor,
    Gradient? gradient,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: gradient != null
                  ? null
                  : (backgroundColor ??
                        colorScheme.primary.withValues(alpha: 0.05)),
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child:
                  customIcon ??
                  Icon(icon, color: iconColor ?? colorScheme.primary, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareToWhatsApp(String title, String shareLink) async {
    final message = 'Check out this piece on MOOD: $title\n$shareLink';
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/?text=$encodedMessage');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: shareLink));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not open WhatsApp. Link copied to clipboard.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _shareToFacebook(String shareLink) async {
    final url = Uri.parse(
      'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(shareLink)}',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: shareLink));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not open Facebook. Link copied to clipboard.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _shareToTelegram(String title, String shareLink) async {
    final message = 'Check out this piece on MOOD: $title\n$shareLink';
    final url = Uri.parse(
      'https://t.me/share/url?url=${Uri.encodeComponent(shareLink)}&text=${Uri.encodeComponent(message)}',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: shareLink));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not open Telegram. Link copied to clipboard.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _shareNatively(
    String text,
    String title,
    String shareLink,
  ) async {
    try {
      await _shareChannel.invokeMethod('shareText', {
        'text': text,
        'title': title,
      });
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: shareLink));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Link copied! Share drawer ready.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
