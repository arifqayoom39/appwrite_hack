import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import '../themes/shop_themes.dart';

/// Provides a more comprehensive theming solution for buyer screens
class BuyerScreenTheme extends ConsumerWidget {
  final String shopTheme;
  final Widget child;

  // Default static values for when we need constants
  static const Color defaultPrimaryColor = Color(0xFFFD366E);
  static const Color defaultBackgroundColor = Colors.white;
  static const Color defaultTextColor = Color(0xFF3D3D3D);
  static const Color defaultLightGrayColor = Color(0xFFF5F5F5);
  static const Color defaultDarkGrayColor = Color(0xFF9E9E9E);

  const BuyerScreenTheme({
    Key? key,
    required this.shopTheme,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get theme based on shop theme
    final palette = ShopThemes.getBuyerThemePalette(shopTheme);
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final themes = ShopThemes.getBuyerThemes(shopTheme);
    final currentTheme = themes[isDarkMode ? 'Dark' : 'Light']!;

    return Theme(
      data: currentTheme,
      child: child,
    );
  }
}

/// Extensions to help with product price formatting and display
extension ProductPriceHelper on Product {
  bool get hasSale => salePrice != null && salePrice! < price;
  
  double get currentPrice => salePrice ?? price;
  
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  
  String get formattedSalePrice => '\$${salePrice!.toStringAsFixed(2)}';
  
  String get formattedCurrentPrice => '\$${currentPrice.toStringAsFixed(2)}';
}
