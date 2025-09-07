import '../features/seller/screens/shop_preview_screen.dart';
import '../features/buyer/screens/storefront_screen.dart';
import '../features/buyer/screens/product_detail_screen.dart';
import '../features/buyer/screens/cart_screen.dart';
import '../features/buyer/screens/order_details_screen.dart';
import '../features/buyer/screens/order_success_screen.dart';
import '../features/buyer/screens/order_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/landing_screen.dart';
import '../features/auth/screens/about_us_screen.dart';
import '../features/auth/screens/features_screen.dart';
import '../features/auth/screens/pricing_screen.dart';
import '../features/auth/screens/support_screen.dart';
import '../features/auth/screens/profile_screen.dart';
import '../features/seller/screens/dashboard_screen.dart';
import '../features/seller/screens/create_shop_screen.dart';
import '../features/seller/screens/product_form_screen.dart';
import '../features/seller/screens/orders_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/features',
        builder: (context, state) => const FeaturesScreen(),
      ),
      GoRoute(
        path: '/pricing',
        builder: (context, state) => const PricingScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/create-shop',
        builder: (context, state) => const CreateShopScreen(),
      ),
      GoRoute(
        path: '/product-upload',
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/order-details',
        builder: (context, state) => const OrderDetailsScreen(),
      ),
      GoRoute(
        path: '/order-success/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderSuccessScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/order-tracking',
        builder: (context, state) {
          final orderId = state.uri.queryParameters['orderId'];
          return OrderTrackingScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/shop-preview',
        builder: (context, state) {
          final shopSlug = state.uri.queryParameters['slug'];
          return ShopPreviewScreen(shopSlug: shopSlug);
        },
      ),
      GoRoute(
        path: '/product-detail',
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>?;
          if (product != null && product.containsKey('product') && product.containsKey('shop')) {
            return ProductDetailScreen(
              product: product['product'],
              shop: product['shop'],
            );
          }
          return const Scaffold(
            body: Center(child: Text('Invalid product arguments')),
          );
        },
      ),
      // Dynamic route for shop storefronts
      GoRoute(
        path: '/:shopSlug',
        builder: (context, state) {
          final shopSlug = state.pathParameters['shopSlug']!;
          // Check if it's not a predefined route
          final predefinedRoutes = [
            'login', 'signup', 'profile', 'about', 'features', 'pricing',
            'support', 'dashboard', 'create-shop', 'product-upload', 'orders',
            'cart', 'shop-preview', 'product-detail', 'order-details', 'order-success', 'order-tracking'
          ];
          if (!predefinedRoutes.contains(shopSlug)) {
            return StorefrontScreen(shopSlug: shopSlug);
          }
          return const Scaffold(
            body: Center(child: Text('Page not found')),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: Text('Page not found')),
    ),
  );
}
