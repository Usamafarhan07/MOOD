import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mood/services/firestore_service.dart';
import 'package:mood/widgets/firestore_image.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
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

  String formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day.toString().padLeft(2, '0')}, ${dateTime.year}';
  }

  String formatCurrency(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return 'LKR $str';
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        buffer.write(',');
        count = 0;
      }
      buffer.write(str[i]);
      count++;
    }
    return 'LKR ${buffer.toString().split('').reversed.join()}';
  }

  void _showTrackingSheet(
    BuildContext context,
    Order order,
    Color terracottaColor,
    Color primaryTextColor,
    Color surfaceColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceColor.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              border: Border(
                top: BorderSide(
                  color: primaryTextColor.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: primaryTextColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Delivery Tracker',
                  style: GoogleFonts.notoSerif(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Order #${order.orderId.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: primaryTextColor.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),

                // Timeline Step 1
                _buildTrackingStep(
                  title: 'Order Placed',
                  subtitle:
                      'Successfully authenticated at our digital checkout',
                  time: formatDate(order.createdAt),
                  isCompleted: true,
                  isLast: false,
                  terracottaColor: terracottaColor,
                  primaryTextColor: primaryTextColor,
                ),

                // Timeline Step 2
                _buildTrackingStep(
                  title: 'Atelier Processing',
                  subtitle:
                      'Our luxury concierges packaged and verified your garments',
                  time: formatDate(
                    order.createdAt.add(const Duration(hours: 4)),
                  ),
                  isCompleted: true,
                  isLast: false,
                  terracottaColor: terracottaColor,
                  primaryTextColor: primaryTextColor,
                ),

                // Timeline Step 3
                _buildTrackingStep(
                  title: 'Out For Delivery',
                  subtitle: 'Dispatched from Colombo central atelier hubs',
                  time: 'Active Now',
                  isCompleted:
                      order.orderStatus == 'shipped' ||
                      order.orderStatus == 'delivered',
                  isActive:
                      order.orderStatus == 'confirmed' ||
                      order.orderStatus == 'pending',
                  isLast: false,
                  terracottaColor: terracottaColor,
                  primaryTextColor: primaryTextColor,
                ),

                // Timeline Step 4
                _buildTrackingStep(
                  title: 'Delivered',
                  subtitle:
                      'Signature verified and securely placed at your doorstep',
                  time: 'Estimated Oct 26',
                  isCompleted: order.orderStatus == 'delivered',
                  isLast: true,
                  terracottaColor: terracottaColor,
                  primaryTextColor: primaryTextColor,
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTextColor,
                      foregroundColor: surfaceColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackingStep({
    required String title,
    required String subtitle,
    required String time,
    required bool isCompleted,
    bool isActive = false,
    required bool isLast,
    required Color terracottaColor,
    required Color primaryTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? terracottaColor
                    : isActive
                    ? terracottaColor.withValues(alpha: 0.15)
                    : primaryTextColor.withValues(alpha: 0.06),
                border: Border.all(
                  color: isCompleted
                      ? terracottaColor
                      : isActive
                      ? terracottaColor
                      : primaryTextColor.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 11)
                  : isActive
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: terracottaColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isCompleted
                    ? terracottaColor
                    : primaryTextColor.withValues(alpha: 0.1),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontWeight: isCompleted || isActive
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isCompleted || isActive
                          ? primaryTextColor
                          : primaryTextColor.withValues(alpha: 0.4),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    time,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? terracottaColor
                          : primaryTextColor.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: primaryTextColor.withValues(alpha: 0.5),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showConciergeSupport(
    BuildContext context,
    Order order,
    Color terracottaColor,
    Color primaryTextColor,
    Color surfaceColor,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: surfaceColor.withValues(alpha: 0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: primaryTextColor.withValues(alpha: 0.08)),
            ),
            title: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: terracottaColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: terracottaColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'MOOD Concierge',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '24/7 Premium Atelier Support',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: primaryTextColor.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryTextColor.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryTextColor.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Text(
                    'Welcome! We are connected to the central database. How would you like us to assist you with Order #${order.orderId.substring(0, 8).toUpperCase()}?',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      height: 1.5,
                      color: primaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                _buildConciergeOption(
                  icon: Icons.local_shipping_outlined,
                  label: 'Query Delivery Route',
                  onTap: () {
                    Navigator.pop(context);
                    _showTrackingSheet(
                      context,
                      order,
                      terracottaColor,
                      primaryTextColor,
                      surfaceColor,
                    );
                  },
                  terracottaColor: terracottaColor,
                  primaryTextColor: primaryTextColor,
                ),
                const SizedBox(height: 10),
                _buildConciergeOption(
                  icon: Icons.assignment_return_outlined,
                  label: 'Inquire Return Policy',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: primaryTextColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: Text(
                          'All MOOD orders feature a premium 30-day complimentary return collection.',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            color: surfaceColor,
                          ),
                        ),
                      ),
                    );
                  },
                  terracottaColor: terracottaColor,
                  primaryTextColor: primaryTextColor,
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            actions: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close Conversation',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConciergeOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color terracottaColor,
    required Color primaryTextColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: primaryTextColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: terracottaColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: primaryTextColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: primaryTextColor.withValues(alpha: 0.25),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Premium Color System based on code.html
    final Color bgColor = isDark
        ? colorScheme.surface
        : const Color(0xFFFCF9F4);
    final Color primaryTextColor = isDark
        ? const Color(0xFFFCF9F4)
        : const Color(0xFF442A22);
    final Color terracottaColor = isDark
        ? const Color(0xFFFE8763)
        : const Color(0xFFA04022);
    final Color surfaceContainerColor = isDark
        ? colorScheme.surfaceContainerLow
        : const Color(0xFFF6F3EE);
    final Color surfaceContainerHighColor = isDark
        ? colorScheme.surfaceContainerHigh
        : const Color(0xFFEBE8E3);
    final Color moodGrayTextColor = isDark
        ? Colors.white60
        : const Color(0xFF504441);

    final address = order.shippingAddress;
    final fullName = address['fullName']?.toString() ?? 'Your Name';
    final street = address['address']?.toString() ?? 'Delivery address';
    final city = address['city']?.toString() ?? 'City';
    final postalCode = address['postalCode']?.toString() ?? 'Postal code';

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: false,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: bgColor.withValues(alpha: 0.8),
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                'MOOD',
                style: GoogleFonts.notoSerif(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 6.0,
                  fontSize: 22,
                  color: primaryTextColor,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Reference Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER REFERENCE',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: moodGrayTextColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '#${order.orderId.toUpperCase()}',
                      style: GoogleFonts.notoSerif(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: terracottaColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.orderStatus.toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: moodGrayTextColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 1,
                          height: 12,
                          color: primaryTextColor.withValues(alpha: 0.15),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          formatDate(order.createdAt),
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: moodGrayTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Shipping Destination Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceContainerColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryTextColor.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SHIPPING DESTINATION',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: moodGrayTextColor,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        fullName,
                        style: GoogleFonts.notoSerif(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$street\n$city, $postalCode.',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: moodGrayTextColor,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () => _showTrackingSheet(
                          context,
                          order,
                          terracottaColor,
                          primaryTextColor,
                          bgColor,
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: primaryTextColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Track Delivery',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: primaryTextColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: primaryTextColor,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Payment Method Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceContainerColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryTextColor.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAYMENT METHOD',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: moodGrayTextColor,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          if (order.paymentMethod.toLowerCase().contains(
                                'visa',
                              ) ||
                              order.paymentMethod.toLowerCase().contains(
                                'card',
                              ))
                            const VisaLogoWidget()
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primaryTextColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'CASH',
                                style: GoogleFonts.manrope(
                                  color: bgColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.paymentMethod.toUpperCase(),
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: primaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Billing address same as shipping.',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: moodGrayTextColor,
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

              // Selected Pieces Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELECTED PIECES (${order.items.length})',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: moodGrayTextColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Product Cards List
                    Column(
                      children: order.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Aspect Ratio 3:4 Luxury Image Card
                              InkWell(
                                onTap: () =>
                                    context.push('/piece/${item.productId}'),
                                child: AspectRatio(
                                  aspectRatio: 3 / 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: primaryTextColor.withValues(
                                          alpha: 0.05,
                                        ),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: FirestoreImage(
                                        imageUrl: item.imageUrl,
                                        fit: BoxFit.cover,
                                        backgroundColor: surfaceContainerColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => context.push(
                                        '/piece/${item.productId}',
                                      ),
                                      child: Text(
                                        item.title,
                                        style: GoogleFonts.notoSerif(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: primaryTextColor,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    formatCurrency(item.unitPrice),
                                    style: GoogleFonts.manrope(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Premium Garment Selection',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  color: moodGrayTextColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: surfaceContainerHighColor,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      'SIZE M',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: surfaceContainerHighColor,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      'QTY ${item.quantity.toString().padLeft(2, '0')}',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () {
                                  context.push('/piece/${item.productId}');
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: primaryTextColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Product Details',
                                        style: GoogleFonts.manrope(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: primaryTextColor,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: primaryTextColor,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Price Summary Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceContainerHighColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryTextColor.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: moodGrayTextColor,
                            ),
                          ),
                          Text(
                            formatCurrency(order.subtotal),
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Shipping',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: moodGrayTextColor,
                            ),
                          ),
                          Text(
                            order.shippingFee == 0
                                ? 'COMPLIMENTARY'
                                : formatCurrency(order.shippingFee),
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: order.shippingFee == 0
                                  ? terracottaColor
                                  : primaryTextColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(color: primaryTextColor.withValues(alpha: 0.08)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL',
                            style: GoogleFonts.notoSerif(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor,
                            ),
                          ),
                          Text(
                            formatCurrency(order.totalPrice),
                            style: GoogleFonts.notoSerif(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Footer Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 80),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: LinearGradient(
                          colors: [
                            terracottaColor,
                            Color.lerp(terracottaColor, Colors.black, 0.12) ??
                                terracottaColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: terracottaColor.withValues(alpha: 0.25),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          'CONTINUE SHOPPING',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Need assistance with your order? Our\nMOOD concierges are available 24/7.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: moodGrayTextColor,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _showConciergeSupport(
                            context,
                            order,
                            terracottaColor,
                            primaryTextColor,
                            bgColor,
                          ),
                          child: Text(
                            'CONTACT SUPPORT',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                              letterSpacing: 1.5,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: primaryTextColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                content: Text(
                                  '30-day premium return policy is active on this order.',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w600,
                                    color: bgColor,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'RETURN POLICY',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                              letterSpacing: 1.5,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VisaLogoWidget extends StatelessWidget {
  final double width;
  final double height;

  const VisaLogoWidget({super.key, this.width = 46, this.height = 26});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(
                    'V',
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      color: const Color(0xFF1A1F71),
                      fontSize: height * 0.46,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -1.0,
                    ),
                  ),
                  Positioned(
                    top: height * 0.09,
                    left: -height * 0.04,
                    child: Transform.rotate(
                      angle: -0.25,
                      child: Container(
                        width: height * 0.16,
                        height: height * 0.08,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7B600), // Visa Gold
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(1),
                            bottomLeft: Radius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'ISA',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  color: const Color(0xFF1A1F71),
                  fontSize: height * 0.46,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
