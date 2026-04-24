import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'visa'; // 'visa' or 'cod'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: colorScheme.background.withOpacity(0.8),
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: colorScheme.outlineVariant.withOpacity(0.2),
                  height: 1.0,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/cart');
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
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications_outlined, color: colorScheme.primary),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title
            Text(
              'Checkout',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Review your details and complete the purchase.',
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF827470),
              ),
            ),
            const SizedBox(height: 40),

            // Shipping Details
            _buildSectionHeader('01. SHIPPING DETAILS', theme),
            const SizedBox(height: 24),
            _buildInputField('FULL NAME', 'Enter your full name', theme),
            const SizedBox(height: 16),
            _buildInputField('PHONE NUMBER', '+94 1162 946 623', theme),
            const SizedBox(height: 16),
            _buildInputField('DELIVERY ADDRESS', 'Enter your address', theme),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInputField('CITY', 'City', theme)),
                const SizedBox(width: 16),
                Expanded(child: _buildInputField('POSTAL CODE', 'Zip', theme)),
              ],
            ),
            const SizedBox(height: 40),

            // Shipping Method
            _buildSectionHeader('02. SHIPPING METHOD', theme),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_shipping, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Express Courier',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Delivered in 2-3 business days',
                          style: textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF827470),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'LKR 500',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Order Summary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Item 1
                  _buildSummaryItem(
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDNHN-xw2EVV9V-z1_pQatvYZqGsqw40CKM6zOVcE1rCKB5-hXd8_RkCGUl_0HVwDHFB1z5DXVyhuu0V0fG4_85Ml857EYH-i_P7an0mnxpU8FhbOYwR1NlmAb-l-vJLDnnpjZqVKG2Y-Hg5WPvKRYWDD8nEHWm9HwwS7tLfrzBB2KAGq2PhnbYJrt7PrTNSc2U-FrpnD73r88Iu-B3-JNeQ_0c89NuNqRc5R2z_FsX-tVSP94vL-BQwID6rZlH1A8OtV11LSjr6xo',
                    title: 'Structured Wool Coat',
                    subtitle: 'Heritage Camel / Medium',
                    price: 'LKR 9000',
                    theme: theme,
                  ),
                  const SizedBox(height: 24),
                  
                  // Item 2
                  _buildSummaryItem(
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCA16s8gU3Q3dVbA2ImRxW4SG_zISeO256rZS9mwcU8K_Zr-c4K7uDvrgTn--hItdF6VV9fnliWPHqQeFl3hnvhrngX_FFfBRKgbZqD6nR_0SvXDNsRD9gpYwodqNSJsMS6VG97RrkwMcCo9mNDUy-Lqp9MsMJQ8zU4PIFBRyCe6k670JLYUbFPJY9RwSCuVpuLxhEJvSofTCw1I7lZmx5gYtSarE0YDbic-MdGyTuuwVdqr09_9v4p3sJ7uVGhnoeR0rEmAp46JYM',
                    title: 'Toscana Leather Boot',
                    subtitle: 'Jet Black / 39',
                    price: 'LKR 15,000',
                    theme: theme,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Cost Breakdown
                  _buildCostRow('Subtotal', 'LKR 24,000', theme),
                  const SizedBox(height: 12),
                  _buildCostRow('Delivery', 'LKR 200', theme),
                  const SizedBox(height: 12),
                  _buildCostRow('Tax', 'LKR 20', theme),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'LKR 24,220',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Promo Code
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Promo Code',
                              hintStyle: textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF827470).withOpacity(0.5),
                              ),
                              border: InputBorder.none,
                            ),
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'APPLY',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Payment Method
            _buildSectionHeader('03. PAYMENT METHOD', theme),
            const SizedBox(height: 24),
            _buildPaymentOption(
              id: 'visa',
              title: 'Visa',
              subtitle: 'Ending in 8842',
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              id: 'cod',
              title: 'Cash on Delivery',
              subtitle: 'Pay upon receipt of goods',
              theme: theme,
            ),
            const SizedBox(height: 48),

            // Footer Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TOTAL TO PAY',
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF827470),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    fontSize: 10,
                  ),
                ),
                Text(
                  'LKR 24,220',
                  style: textTheme.displaySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                  context.push('/order_confirmation');
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
                  'PLACE ORDER',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
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

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        color: const Color(0xFF827470),
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        fontSize: 10,
      ),
    );
  }

  Widget _buildInputField(String label, String hint, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF827470).withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required String imageUrl,
    required String title,
    required String subtitle,
    required String price,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 96,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF827470),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String label, String amount, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF827470),
          ),
        ),
        Text(
          amount,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    final isSelected = _selectedPaymentMethod == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: id == 'visa' ? const Color(0xFF1A1F71) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
              child: id == 'visa'
                  ? const Text(
                      'VISA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Icon(Icons.payments, color: const Color(0xFF2D5A27), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF827470),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
