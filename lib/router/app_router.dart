import 'package:go_router/go_router.dart';
import 'package:mood/screens/cover_page.dart';
import 'package:mood/screens/login_screen.dart';
import 'package:mood/screens/registration_screen.dart';
import 'package:mood/screens/home_screen.dart';
import 'package:mood/screens/product_listing_screen.dart';
import 'package:mood/screens/product_details_screen.dart';
import 'package:mood/screens/shopping_cart_screen.dart';
import 'package:mood/screens/checkout_screen.dart';
import 'package:mood/screens/order_confirmation_screen.dart';
import 'package:mood/screens/order_details_screen.dart';
import 'package:mood/screens/wishlist_screen.dart';
import 'package:mood/screens/profile_screen.dart';
import 'package:mood/screens/notifications_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CoverPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
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
      path: '/cart',
      builder: (context, state) => const ShoppingCartScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/order_confirmation',
      builder: (context, state) => const OrderConfirmationScreen(),
    ),
    GoRoute(
      path: '/order_details',
      builder: (context, state) => const OrderDetailsScreen(),
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
  ],
);
