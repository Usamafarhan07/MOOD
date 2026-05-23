import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mood/screens/cover_page.dart';
import 'package:mood/screens/login_screen.dart';
import 'package:mood/screens/registration_screen.dart';
import 'package:mood/screens/home_screen.dart';
import 'package:mood/screens/product_listing_screen.dart';
import 'package:mood/screens/product_details_screen.dart';
import 'package:mood/screens/shopping_cart_screen.dart';
import 'package:mood/screens/checkout_screen.dart';
import 'package:mood/screens/category_products_screen.dart';
import 'package:mood/screens/order_confirmation_screen.dart';
import 'package:mood/screens/order_details_screen.dart';
import 'package:mood/screens/order_history_screen.dart';
import 'package:mood/screens/wishlist_screen.dart';
import 'package:mood/screens/profile_screen.dart';
import 'package:mood/screens/notifications_screen.dart';
import 'package:mood/screens/settings_screen.dart';

GoRouter createAppRouter() {
  final authChangeNotifier = AuthChangeNotifier();

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authChangeNotifier,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final currentLocation = state.uri.toString();
      final isGoingToAuth =
          currentLocation == '/' ||
          currentLocation == '/login' ||
          currentLocation == '/register';

      if (user != null) {
        return isGoingToAuth ? '/home' : null;
      }

      if (!isGoingToAuth) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const CoverPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/category/:category',
        builder: (context, state) {
          final category = state.pathParameters['category'] ?? '';
          return CategoryProductsScreen(
            categoryName: Uri.decodeComponent(category),
          );
        },
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductListingScreen(),
      ),
      GoRoute(
        path: '/product_details',
        builder: (context, state) {
          final productData = state.extra as Map<String, dynamic>?;
          return ProductDetailsScreen(productData: productData);
        },
      ),
      GoRoute(
        path: '/piece/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ProductDetailsScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const ShoppingCartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order_confirmation/:id',
        builder: (context, state) =>
            OrderConfirmationScreen(orderId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/order_history',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/order_details/:id',
        builder: (context, state) =>
            OrderDetailsScreen(orderId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }
}
