import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:mood/services/firestore_service.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Order? _order;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.orderId.isEmpty) {
      _errorMessage = 'Order ID is missing.';
    } else {
      _loadOrder();
    }
  }

  Future<void> _loadOrder() async {
    try {
      final order = await _firestoreService.getOrder(widget.orderId);
      if (mounted) {
        setState(() {
          _order = order;
          _errorMessage = order == null ? 'Order not found.' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Unable to load this order.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (_order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final order = _order!;
    final orderReference = '#${order.orderId.substring(0, 8).toUpperCase()}';

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
              automaticallyImplyLeading: false,
              title: Text(
                'MOOD',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6.0,
                  color: colorScheme.primary,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          32,
          40,
          32,
          120,
        ), // Bottom padding for nav
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
                        color: colorScheme.surface,
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
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.05),
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
                      color: colorScheme.primary.withValues(alpha: 0.6),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    orderReference,
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 48,
                    height: 1,
                    color: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 24),

                  // Item Thumbnails (Stacked)
                  SizedBox(
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: List.generate(
                        order.items.length > 3 ? 3 : order.items.length,
                        (index) {
                          if (index == 2 && order.items.length > 3) {
                            return Positioned(
                              left:
                                  MediaQuery.of(context).size.width * 0.25 +
                                  (index * 32) -
                                  42,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.surfaceContainerLow,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '+${order.items.length - 2}',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Positioned(
                            left:
                                MediaQuery.of(context).size.width * 0.25 +
                                (index * 32) -
                                42,
                            child: _buildThumbnail(
                              order.items[index].imageUrl,
                              theme,
                            ),
                          );
                        },
                      ).toList(),
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
                  context.push('/order_details/${order.orderId}');
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
    );
  }

  Widget _buildThumbnail(String imageUrl, ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.surfaceContainerLow,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
