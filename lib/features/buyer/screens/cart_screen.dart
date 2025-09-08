import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  final String? shopSlug;
  const CartScreen({Key? key, this.shopSlug}) : super(key: key);

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with TickerProviderStateMixin {
  bool _isProcessingOrder = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // App colors matching storefront
  static const Color primaryColor = Color(0xFFFD366E);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF3D3D3D);
  static const Color lightGrayColor = Color(0xFFF5F5F5);
  static const Color darkGrayColor = Color(0xFF9E9E9E);

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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartProvider.notifier).total;
    final itemCount = ref.watch(cartProvider.notifier).itemCount;

    // Get theme matching storefront
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final currentTheme = _themes[isDarkMode ? 'Dark' : 'Light']!;

    return Theme(
      data: currentTheme,
      child: Scaffold(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        appBar: _buildAppBar(currentTheme, itemCount),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Expanded(
                  child: cartItems.isEmpty
                      ? _buildEmptyCart(currentTheme)
                      : _buildCartItems(currentTheme, cartItems),
                ),
                if (cartItems.isNotEmpty) _buildCheckoutSection(currentTheme, total),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, int itemCount) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0.5,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: Text(
        'Cart (${itemCount} items)',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: theme.brightness == Brightness.dark ? Colors.white : textColor,
        ),
      ),
      actions: [
        if (itemCount > 0)
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: theme.brightness == Brightness.dark ? Colors.white : textColor,
              size: 22,
            ),
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              HapticFeedback.lightImpact();
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : lightGrayColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: darkGrayColor,
              size: 80,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white : textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: TextStyle(
              color: darkGrayColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 32),
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
                  final cartItems = ref.read(cartProvider);
                  if (widget.shopSlug != null) {
                    // Navigate back to the specific storefront
                    context.go('/${widget.shopSlug}');
                  } else if (cartItems.isNotEmpty) {
                    // Fallback: try to get shop slug from cart items
                    // This would require fetching shop data, for now just go to dashboard
                    context.go('/dashboard');
                  } else {
                    // If cart is empty, go to dashboard
                    context.go('/dashboard');
                  }
                },
                child: const Center(
                  child: Text(
                    'Continue Shopping',
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
        ],
      ),
    );
  }

  Widget _buildCartItems(ThemeData theme, List<CartItem> cartItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return _buildCartItem(theme, item);
      },
    );
  }

  Widget _buildCartItem(ThemeData theme, CartItem item) {
    final hasSale = item.product.salePrice != null &&
        item.product.salePrice! < item.product.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : lightGrayColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : lightGrayColor,
            ),
            child: item.product.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image, color: darkGrayColor, size: 32),
                    ),
                  )
                : Icon(Icons.inventory, color: darkGrayColor, size: 32),
          ),

          const SizedBox(width: 16),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (hasSale) ...[
                      Text(
                        '\$${item.product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: darkGrayColor,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '\$${(item.product.salePrice ?? item.product.price).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: \$${item.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark ? Colors.white70 : textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Quantity Controls
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : lightGrayColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove,
                        color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                        size: 16,
                      ),
                      onPressed: item.quantity > 1
                          ? () => ref.read(cartProvider.notifier).updateQuantity(
                                item.product.id,
                                item.quantity - 1,
                              )
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                        size: 16,
                      ),
                      onPressed: item.quantity < item.product.stock
                          ? () => ref.read(cartProvider.notifier).updateQuantity(
                                item.product.id,
                                item.quantity + 1,
                              )
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 20),
                onPressed: () => ref.read(cartProvider.notifier).removeItem(item.product.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(ThemeData theme, double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : lightGrayColor),
        ),
      ),
      child: Column(
        children: [
          // Order Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : lightGrayColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark ? Colors.white70 : textColor,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shipping',
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark ? Colors.white70 : textColor,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Free',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.2) : darkGrayColor.withOpacity(0.2)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Checkout Button
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
                onTap: _isProcessingOrder ? null : () => context.go('/order-details'),
                child: Center(
                  child: _isProcessingOrder
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Place Order',
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
        ],
      ),
    );
  }
}
