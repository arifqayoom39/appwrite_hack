import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  // Static routes
  static const String landing = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String features = '/features';
  static const String pricing = '/pricing';
  static const String about = '/about';
  static const String support = '/support';
  static const String profile = '/profile';
  static const String dashboard = '/dashboard';
  static const String createShop = '/create-shop';
  static const String productUpload = '/product-upload';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String shopPreview = '/shop-preview';
  static const String productDetail = '/product-detail';

  // Named routes
  static const String storefront = 'storefront';

  // Navigation helpers
  static void goToStorefront(BuildContext context, String shopSlug) {
    context.goNamed(storefront, pathParameters: {'shopSlug': shopSlug});
  }

  static void goToCart(BuildContext context) {
    context.go(cart);
  }

  static void goToLanding(BuildContext context) {
    context.go(landing);
  }

  static void goToDashboard(BuildContext context) {
    context.go(dashboard);
  }

  // Push helpers (for navigation that can go back)
  static void pushToProductDetail(BuildContext context, Map<String, dynamic> extra) {
    context.push(productDetail, extra: extra);
  }

  static void pushToStorefront(BuildContext context, String shopSlug) {
    context.pushNamed(storefront, pathParameters: {'shopSlug': shopSlug});
  }
}
