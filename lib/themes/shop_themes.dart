import 'package:flutter/material.dart';

/// ShopThemes class handles all theme-related functionality for shops
/// This centralizes theme management across the app
class ShopThemes {
  // Premium theme definitions with stunning gradients and colors
  static Map<String, ThemeData> getThemes() {
    return {
      'Midnight Pro': ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        colorScheme: const ColorScheme.dark(
          tertiary: Color(0xFF06B6D4),
          primary: Color(0xFFFD366E),
          secondary: Color(0xFF7C3AED),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardTheme: const CardTheme(
          color: Color(0xFF1E293B),
        ),
      ),
      'Ocean Breeze': ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.cyan,
        colorScheme: const ColorScheme.light(
          tertiary: Color(0xFF3B82F6),
          primary: Color(0xFF0891B2),
          secondary: Color(0xFF06B6D4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F9FF),
        cardTheme: const CardTheme(
          color: Colors.white,
        ),
      ),
      'Sunset Glow': ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
        colorScheme: const ColorScheme.light(
          tertiary: Color(0xFFDC2626),
          primary: Color(0xFFEA580C),
          secondary: Color(0xFFF59E0B),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF7ED),
        cardTheme: const CardTheme(
          color: Colors.white,
        ),
      ),
      'Forest Zen': ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        colorScheme: const ColorScheme.light(
          tertiary: Color(0xFF84CC16),
          primary: Color(0xFF059669),
          secondary: Color(0xFF10B981),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0FDF4),
        cardTheme: const CardTheme(
          color: Colors.white,
        ),
      ),
      'Royal Purple': ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        colorScheme: const ColorScheme.dark(
          tertiary: Color(0xFFEC4899),
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFFA855F7),
        ),
        scaffoldBackgroundColor: const Color(0xFF1E1B4B),
        cardTheme: const CardTheme(
          color: Color(0xFF312E81),
        ),
      ),
      'Aurora': ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
        colorScheme: const ColorScheme.light(
          tertiary: Color(0xFF7C3AED),
          primary: Color(0xFFDB2777),
          secondary: Color(0xFFEC4899),
        ),
        scaffoldBackgroundColor: const Color(0xFFFDF2F8),
        cardTheme: const CardTheme(
          color: Colors.white,
        ),
      ),
      'Cosmic Dark': ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        colorScheme: const ColorScheme.dark(
          tertiary: Color(0xFF10B981),
          primary: Color(0xFF4F46E5),
          secondary: Color(0xFFFD366E),
        ),
        scaffoldBackgroundColor: const Color(0xFF111827),
        cardTheme: const CardTheme(
          color: Color(0xFF374151),
        ),
      ),
      'Golden Luxury': ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.amber,
        colorScheme: const ColorScheme.light(
          tertiary: Color(0xFF92400E),
          primary: Color(0xFFD97706),
          secondary: Color(0xFFF59E0B),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFBEB),
        cardTheme: const CardTheme(
          color: Colors.white,
        ),
      ),
    };
  }

  // Helper method to get appropriate theme based on shop's theme name
  static ThemeData getThemeByName(String themeName) {
    final themes = getThemes();
    return themes[themeName] ?? themes['Midnight Pro']!;
  }

  // Get theme gradient based on theme name
  static LinearGradient getThemeGradient(String themeName) {
    switch (themeName) {
      case 'Midnight Pro':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
        );
      case 'Ocean Breeze':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4), Color(0xFF0891B2)],
        );
      case 'Sunset Glow':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEA580C), Color(0xFFF59E0B), Color(0xFFFBBF24)],
        );
      case 'Forest Zen':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
        );
      case 'Royal Purple':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7), Color(0xFFC084FC)],
        );
      case 'Aurora':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEC4899), Color(0xFFF472B6), Color(0xFFFBBF24)],
        );
      case 'Cosmic Dark':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFD366E), Color(0xFF7C3AED), Color(0xFF10B981)],
        );
      case 'Golden Luxury':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFFFDE047)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
        );
    }
  }

  // Get theme description
  static String getThemeDescription(String themeName) {
    switch (themeName) {
      case 'Midnight Pro':
        return 'Dark & Professional';
      case 'Ocean Breeze':
        return 'Fresh & Clean';
      case 'Sunset Glow':
        return 'Warm & Vibrant';
      case 'Forest Zen':
        return 'Natural & Calm';
      case 'Royal Purple':
        return 'Luxury & Elegant';
      case 'Aurora':
        return 'Colorful & Bold';
      case 'Cosmic Dark':
        return 'Modern & Tech';
      case 'Golden Luxury':
        return 'Premium & Rich';
      default:
        return 'Beautiful Theme';
    }
  }
  
  // Get color palette for simple buyer themes
  static Map<String, Color> getBuyerThemePalette(String themeName) {
    switch (themeName) {
      case 'Midnight Pro':
        return {
          'primary': const Color(0xFFFD366E),
          'background': Colors.white,
          'text': const Color(0xFF3D3D3D),
          'lightGray': const Color(0xFFF5F5F5),
          'darkGray': const Color(0xFF9E9E9E),
        };
      case 'Ocean Breeze':
        return {
          'primary': const Color(0xFF0891B2),
          'background': Colors.white,
          'text': const Color(0xFF3D3D3D),
          'lightGray': const Color(0xFFF5F5F5),
          'darkGray': const Color(0xFF9E9E9E),
        };
      case 'Sunset Glow':
        return {
          'primary': const Color(0xFFEA580C),
          'background': Colors.white,
          'text': const Color(0xFF3D3D3D),
          'lightGray': const Color(0xFFF5F5F5),
          'darkGray': const Color(0xFF9E9E9E),
        };
      case 'Forest Zen':
        return {
          'primary': const Color(0xFF059669),
          'background': Colors.white,
          'text': const Color(0xFF3D3D3D),
          'lightGray': const Color(0xFFF5F5F5),
          'darkGray': const Color(0xFF9E9E9E),
        };
      case 'Royal Purple':
        return {
          'primary': const Color(0xFF7C3AED),
          'background': Colors.white,
          'text': const Color(0xFF3D3D3D),
          'lightGray': const Color(0xFFF5F5F5),
          'darkGray': const Color(0xFF9E9E9E),
        };
      case 'Aurora':
        return {
          'primary': const Color(0xFFDB2777),
          'background': Colors.white,
          'text': const Color(0xFF3D3D3D),
          'lightGray': const Color(0xFFF5F5F5),
          'darkGray': const Color(0xFF9E9E9E),
        };
      case 'Cosmic Dark':
        return {
          'primary': const Color(0xFF4F46E5),
          'background': Colors.white,
          'text': const Color(0xFF3D3D3D),
          'lightGray': const Color(0xFFF5F5F5),
          'darkGray': const Color(0xFF9E9E9E),
        };
      case 'Golden Luxury':
        return {
          'primary': const Color(0xFFD97706),
          'background': Colors.white,
          'text': const Color(0xFF3D3D3D),
          'lightGray': const Color(0xFFF5F5F5),
          'darkGray': const Color(0xFF9E9E9E),
        };
      default:
        return {
          'primary': const Color(0xFFFD366E),
          'background': Colors.white,
          'text': const Color(0xFF3D3D3D),
          'lightGray': const Color(0xFFF5F5F5),
          'darkGray': const Color(0xFF9E9E9E),
        };
    }
  }
  
  // Get light/dark themes for buyer UI
  static Map<String, ThemeData> getBuyerThemes(String shopThemeName) {
    // Get primary color from the shop theme
    final palette = getBuyerThemePalette(shopThemeName);
    final primaryColor = palette['primary']!;
    final textColor = palette['text']!;
    final lightGrayColor = palette['lightGray']!;
    final backgroundColor = palette['background']!;
    
    return {
      'Light': ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: primaryColor,
          surface: Colors.white,
          background: backgroundColor,
          onBackground: textColor,
        ),
        cardTheme: const CardTheme(
          color: Colors.white,
          elevation: 0,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: IconThemeData(color: textColor),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
        ),
      ),
      'Dark': ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: primaryColor,
          surface: const Color(0xFF1E1E1E),
          background: const Color(0xFF121212),
          onBackground: Colors.white,
        ),
        cardTheme: const CardTheme(
          color: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0.5,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
    };
  }
}
