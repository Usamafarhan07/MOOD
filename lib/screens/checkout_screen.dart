import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:mood/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'cod'; // 'visa' or 'cod'
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;
  String? _validationError;
  UserProfile? _profile;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCheckoutProfile();
  }

  Future<void> _loadCheckoutProfile() async {
    try {
      final profile = await _firestoreService.getUserProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        if (profile?.paymentMethod?['last4'] != null) {
          _selectedPaymentMethod = 'visa';
        }
        _fullNameController.text = profile?.fullName ?? '';
        _phoneController.text = profile?.phone ?? '';
        _addressController.text = profile?.address ?? '';
      });
    } on FirebaseAuthException {
      if (mounted) context.go('/login');
    } catch (_) {
      // Keep checkout usable with manual shipping details if profile loading fails.
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  bool _validateShippingDetails() {
    _validationError = null;

    if (_fullNameController.text.trim().isEmpty) {
      _validationError = 'Please enter your full name';
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      _validationError = 'Please enter your phone number';
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      _validationError = 'Please enter your delivery address';
      return false;
    }
    if (_cityController.text.trim().isEmpty) {
      _validationError = 'Please enter your city';
      return false;
    }
    if (_postalCodeController.text.trim().isEmpty) {
      _validationError = 'Please enter your postal code';
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firestore.QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestoreService.getCartStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final cartItems = snapshot.data!.docs
            .map((doc) => CartItem.fromSnapshot(doc))
            .toList();
        final subtotal = cartItems.fold(
          0,
          (sum, item) => sum + (item.price * item.quantity),
        );
        final delivery = 500;
        final tax = (subtotal * 0.02).toInt();
        final total = subtotal + delivery + tax;
        final savedPayment = _profile?.paymentMethod;
        final savedCardLast4 = savedPayment?['last4']?.toString();

        String formatCurrency(int amount) {
          return 'LKR ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
        }

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AppBar(
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
                  elevation: 0,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1.0),
                    child: Container(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.2),
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
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: colorScheme.primary,
                          ),
                          onPressed: () {
                            context.push('/notifications');
                          },
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
                _buildInputField(
                  'FULL NAME',
                  'Enter your full name',
                  theme,
                  _fullNameController,
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  'PHONE NUMBER',
                  '+94 1162 946 623',
                  theme,
                  _phoneController,
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  'DELIVERY ADDRESS',
                  'Enter your address',
                  theme,
                  _addressController,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        'CITY',
                        'City',
                        theme,
                        _cityController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        'POSTAL CODE',
                        'Zip',
                        theme,
                        _postalCodeController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Shipping Method
                _buildSectionHeader('02. SHIPPING METHOD', theme),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.brightness == Brightness.light
                        ? Colors.white
                        : colorScheme.surfaceContainerLow,
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
                        child: Icon(
                          Icons.local_shipping,
                          color:
                              theme.colorScheme.brightness == Brightness.light
                              ? Colors.white
                              : theme.colorScheme.surface,
                          size: 24,
                        ),
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
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
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

                      if (cartItems.isEmpty)
                        Text('No items in cart', style: textTheme.bodyMedium)
                      else
                        ...cartItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _buildSummaryItem(
                              imageUrl: item.imageUrl,
                              title: item.title,
                              subtitle:
                                  '${item.subtitle} / Qty: ${item.quantity}',
                              price: item.formattedPrice,
                              theme: theme,
                            ),
                          ),
                        ),

                      const Divider(),
                      const SizedBox(height: 24),

                      // Cost Breakdown
                      _buildCostRow(
                        'Subtotal',
                        formatCurrency(subtotal),
                        theme,
                      ),
                      const SizedBox(height: 12),
                      _buildCostRow(
                        'Delivery',
                        formatCurrency(delivery),
                        theme,
                      ),
                      const SizedBox(height: 12),
                      _buildCostRow('Tax', formatCurrency(tax), theme),
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
                            formatCurrency(total),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                (theme.colorScheme.brightness ==
                                            Brightness.light
                                        ? const Color(0xFFD4C3BE)
                                        : const Color(0xFF4E3A35))
                                    .withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Promo Code',
                                  hintStyle: textTheme.bodySmall?.copyWith(
                                    color: const Color(
                                      0xFF827470,
                                    ).withValues(alpha: 0.5),
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                ),
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
                if (savedCardLast4 != null) ...[
                  _buildPaymentOption(
                    id: 'visa',
                    title: 'Visa',
                    subtitle: 'Ending in $savedCardLast4',
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                ],
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
                      formatCurrency(total),
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
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            if (!_validateShippingDetails()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _validationError ??
                                        'Please fill in all details',
                                  ),
                                  backgroundColor: colorScheme.error,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                              return;
                            }

                            if (cartItems.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Your cart is empty'),
                                ),
                              );
                              return;
                            }
                            if (_selectedPaymentMethod == 'visa' &&
                                savedCardLast4 == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Please add a card in your profile or choose Cash on Delivery',
                                  ),
                                  backgroundColor: colorScheme.error,
                                ),
                              );
                              return;
                            }

                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) {
                              if (mounted) context.go('/login');
                              return;
                            }

                            setState(() => _isProcessing = true);

                            try {
                              final orderItems = cartItems
                                  .map(
                                    (item) => OrderItem(
                                      productId: item.productId,
                                      title: item.title,
                                      imageUrl: item.imageUrl,
                                      quantity: item.quantity,
                                      unitPrice: item.price,
                                    ),
                                  )
                                  .toList();

                              final shippingAddress = {
                                'fullName': _fullNameController.text.trim(),
                                'phone': _phoneController.text.trim(),
                                'address': _addressController.text.trim(),
                                'city': _cityController.text.trim(),
                                'postalCode': _postalCodeController.text.trim(),
                              };

                              final order = Order(
                                orderId: '',
                                userId: user.uid,
                                userEmail: user.email ?? '',
                                items: orderItems,
                                totalPrice: total,
                                subtotal: subtotal,
                                shippingFee: delivery,
                                taxFee: tax,
                                orderStatus: 'pending',
                                createdAt: DateTime.now(),
                                paymentMethod: _selectedPaymentMethod == 'visa'
                                    ? 'visa_ending_$savedCardLast4'
                                    : 'cod',
                                shippingAddress: shippingAddress,
                              );

                              final orderId = await _firestoreService
                                  .createOrderAndClearCart(order);

                              if (!context.mounted) return;
                              context.push('/order_confirmation/$orderId');
                            } on FirebaseAuthException catch (e) {
                              if (!context.mounted) return;
                              setState(() => _isProcessing = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Authentication error: ${e.message}',
                                  ),
                                  backgroundColor: colorScheme.error,
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              setState(() => _isProcessing = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to place order. Please try again.',
                                  ),
                                  backgroundColor: colorScheme.error,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
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
      },
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

  Widget _buildInputField(
    String label,
    String hint,
    ThemeData theme,
    TextEditingController controller,
  ) {
    final isLight = theme.colorScheme.brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isLight
                ? Colors.white
                : theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  (isLight ? const Color(0xFFD4C3BE) : const Color(0xFF4E3A35))
                      .withValues(alpha: 0.4),
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isLight
                    ? const Color(0xFF827470).withValues(alpha: 0.6)
                    : theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
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
            child: Image.network(imageUrl, fit: BoxFit.cover),
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
    final isLight = theme.colorScheme.brightness == Brightness.light;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isLight
                    ? Colors.white
                    : theme.colorScheme.surfaceContainerHigh)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isLight ? const Color(0xFFD4C3BE) : const Color(0xFF4E3A35))
                      .withValues(alpha: 0.5),
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
                color: id == 'visa'
                    ? const Color(0xFF1A1F71)
                    : Colors.transparent,
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
                  : Icon(
                      Icons.payments,
                      color: const Color(0xFF2D5A27),
                      size: 24,
                    ),
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
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
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
