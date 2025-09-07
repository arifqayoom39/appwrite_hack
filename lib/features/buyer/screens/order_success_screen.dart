import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../services/appwrite_service.dart';
import '../../../models/order_model.dart';
import '../../../models/shop_model.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;

  const OrderSuccessScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  String? _shopSlug;
  bool _isLoadingShop = true;

  // App colors matching storefront
  static const Color primaryColor = Color(0xFFFD366E);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF3D3D3D);
  static const Color lightGrayColor = Color(0xFFF5F5F5);

  // Theme system matching storefront
  final Map<String, ThemeData> _themes = {
    'Light': ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
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
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: textColor),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
      ),
    ),
    'Dark': ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });

    _loadShopSlug();
  }

  Future<void> _loadShopSlug() async {
    try {
      final order = await AppwriteService.getOrderById(widget.orderId);
      if (order != null) {
        final shop = await AppwriteService.getShopById(order.shopId);
        if (shop != null) {
          setState(() {
            _shopSlug = shop.slug;
            _isLoadingShop = false;
          });
        } else {
          setState(() {
            _isLoadingShop = false;
          });
        }
      } else {
        setState(() {
          _isLoadingShop = false;
        });
      }
    } catch (e) {
      print('Error loading shop slug: $e');
      setState(() {
        _isLoadingShop = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _copyTrackingId() {
    Clipboard.setData(ClipboardData(text: widget.orderId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tracking ID copied to clipboard!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _copyTrackingUrl(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tracking URL copied to clipboard!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get theme matching storefront
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final currentTheme = _themes[isDarkMode ? 'Dark' : 'Light']!;

    return Theme(
      data: currentTheme,
      child: Scaffold(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildSuccessIcon(currentTheme),
                    const SizedBox(height: 32),
                    _buildSuccessMessage(currentTheme),
                    const SizedBox(height: 32),
                    _buildTrackingSection(currentTheme),
                    const SizedBox(height: 32),
                    _buildPsychologicalNote(currentTheme),
                    const SizedBox(height: 32),
                    _buildActionButtons(currentTheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon(ThemeData theme) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle,
          color: Color(0xFF10B981),
          size: 80,
        ),
      ),
    );
  }

  Widget _buildSuccessMessage(ThemeData theme) {
    return Column(
      children: [
        Text(
          '🎉 Order Placed Successfully!',
          style: TextStyle(
            color: theme.brightness == Brightness.dark ? Colors.white : textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Thank you for your order. We\'re preparing your items with care.',
          style: TextStyle(
            color: theme.brightness == Brightness.dark ? Colors.white70 : textColor,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTrackingSection(ThemeData theme) {
    final trackingUrl = 'https://storepe.appwrite.network/order-tracking?orderId=${widget.orderId}';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : lightGrayColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Your Tracking ID',
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white : textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.orderId,
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: _copyTrackingId,
                      color: primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          trackingUrl,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () => _copyTrackingUrl(trackingUrl),
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '📋 Copy this tracking ID or URL for your records. You can use it to track your order status anytime.',
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white70 : textColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPsychologicalNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite,
            color: primaryColor,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Take a deep breath...',
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white : textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order is now in good hands. We understand that waiting can be exciting yet anxious. Rest assured, we\'re working diligently to get your items to you as quickly as possible.\n\n💡 Pro tip: Save this tracking URL for easy access to your order updates anytime!',
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white70 : textColor,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                // Navigate to tracking page with the order ID
                context.go('/order-tracking?orderId=${widget.orderId}');
              },
              child: const Center(
                child: Text(
                  'Track My Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : lightGrayColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                // Navigate to tracking page with the order ID pre-filled
                context.go('/order-tracking?orderId=${widget.orderId}');
              },
              child: const Center(
                child: Text(
                  'How to Track My Order',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            if (_shopSlug != null) {
              context.go('/$_shopSlug');
            } else {
              // Fallback to dashboard if shop slug not available
              context.go('/dashboard');
            }
          },
          child: Text(
            'Continue Shopping',
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white70 : textColor,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
