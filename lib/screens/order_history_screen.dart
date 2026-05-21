import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:mood/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
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
                'Order History',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: colorScheme.primary,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getUserOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error loading orders: ${snapshot.error}',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs
              .map((doc) => Order.fromSnapshot(doc))
              .toList();

          // Sort in-memory descending by createdAt
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (orders.isEmpty) {
            return Center(
              child: Text('No orders yet', style: textTheme.bodyLarge),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order, theme);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    String formatCurrency(int amount) {
      return 'LKR ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    }

    return GestureDetector(
      onTap: () {
        context.push('/order_details/${order.orderId}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderId.substring(0, 8)}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.orderStatus, colorScheme),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.orderStatus.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(order.totalPrice),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }
}
