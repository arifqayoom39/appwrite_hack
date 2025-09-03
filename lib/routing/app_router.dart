import '../features/seller/screens/shop_preview_screen.dart';
import '../features/buyer/screens/storefront_screen.dart';
import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/landing_screen_loader.dart';
import '../features/auth/screens/about_us_screen.dart';
import '../features/seller/screens/dashboard_screen.dart';
import '../features/seller/screens/create_shop_screen.dart';
import '../features/seller/screens/product_form_screen.dart';
import '../features/seller/screens/orders_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LandingScreenLoader());
      case '/shop-preview':
        return MaterialPageRoute(builder: (_) => const ShopPreviewScreen());
      case '/shop-page':
        // For demo, use a static slug. In production, parse from settings.arguments
        return MaterialPageRoute(builder: (_) => const StorefrontScreen(shopSlug: 'ariftea'));
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case '/about':
        return MaterialPageRoute(builder: (_) => const AboutUsScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/create-shop':
        return MaterialPageRoute(builder: (_) => const CreateShopScreen());
      case '/product-upload':
        return MaterialPageRoute(builder: (_) => const ProductFormScreen());
      case '/orders':
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
