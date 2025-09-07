import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/product_model.dart';
import '../../../models/shop_model.dart';
import '../../../providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;
  final Shop shop;

  const ProductDetailScreen({
    Key? key,
    required this.product,
    required this.shop,
  }) : super(key: key);

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with TickerProviderStateMixin {
  int _quantity = 1;
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

  void _addToCart() {
    // Validate shop data
    if (widget.shop.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shop information is missing. Please try again.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Validate product data
    if (widget.product.sellerId.isEmpty || widget.product.shopId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product information is incomplete. Please contact support.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    ref.read(cartProvider.notifier).addItem(widget.product, _quantity);
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${widget.product.name} x$_quantity to cart'),
        backgroundColor: const Color(0xFF10B981),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => context.go('/cart'),
        ),
      ),
    );
  }

  void _buyNow() async {
    // Validate shop data
    if (widget.shop.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shop information is missing. Please try again.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Validate product data
    if (widget.product.sellerId.isEmpty || widget.product.shopId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product information is incomplete. Please contact support.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Add to cart first
    ref.read(cartProvider.notifier).addItem(widget.product, _quantity);

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${widget.product.name} x$_quantity to cart'),
        backgroundColor: const Color(0xFF10B981),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => context.go('/cart'),
        ),
      ),
    );

    // Navigate to order details
    context.go('/order-details');
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
        appBar: _buildAppBar(currentTheme),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(currentTheme),
                  _buildProductInfo(currentTheme),
                  _buildQuantitySelector(currentTheme),
                  _buildActionButtons(currentTheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0.5,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: Text(
        widget.shop.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: theme.brightness == Brightness.dark ? Colors.white : textColor,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        color: theme.brightness == Brightness.dark ? Colors.white : textColor,
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.share,
            color: theme.brightness == Brightness.dark ? Colors.white : textColor,
            size: 22,
          ),
          onPressed: () {
            // TODO: Share product
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildImageGallery(ThemeData theme) {
    if (widget.product.images.isEmpty) {
      return Container(
        height: 300,
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : lightGrayColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.inventory,
          color: darkGrayColor,
          size: 80,
        ),
      );
    }

    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      child: PageView.builder(
        itemCount: widget.product.images.length,
        onPageChanged: (index) {
          // Handle page change if needed
        },
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(widget.product.images[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductInfo(ThemeData theme) {
    final hasSale = widget.product.salePrice != null &&
        widget.product.salePrice! < widget.product.price;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name and Category
          Text(
            widget.product.name,
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white : textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.product.category.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.product.category,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Price
          Row(
            children: [
              if (hasSale) ...[
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: darkGrayColor,
                    fontSize: 18,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                '\$${(widget.product.salePrice ?? widget.product.price).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stock Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.product.stock > 0
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  widget.product.stock > 0 ? Icons.check_circle : Icons.cancel,
                  color: widget.product.stock > 0
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF4444),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.product.stock > 0
                      ? '${widget.product.stock} items in stock'
                      : 'Out of stock',
                  style: TextStyle(
                    color: widget.product.stock > 0
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFEF4444),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Description
          if (widget.product.description.isNotEmpty) ...[
            Text(
              'Description',
              style: TextStyle(
                color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.product.description,
              style: TextStyle(
                color: theme.brightness == Brightness.dark ? Colors.white70 : textColor,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Product Details
          Text(
            'Product Details',
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white : textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailGrid(theme),
        ],
      ),
    );
  }

  Widget _buildDetailGrid(ThemeData theme) {
    final details = <Map<String, String>>[];

    if (widget.product.sku != null) {
      details.add({'label': 'SKU', 'value': widget.product.sku!});
    }
    if (widget.product.weight != null) {
      details.add({'label': 'Weight', 'value': '${widget.product.weight} kg'});
    }
    if (widget.product.dimensions != null) {
      final dims = widget.product.dimensions!;
      details.add({
        'label': 'Dimensions',
        'value': '${dims['length']} × ${dims['width']} × ${dims['height']} cm'
      });
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : lightGrayColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: details.map((detail) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    '${detail['label']}:',
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark ? Colors.white70 : textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    detail['value']!,
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuantitySelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Text(
            'Quantity',
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white : textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
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
                  ),
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$_quantity',
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                  ),
                  onPressed: _quantity < widget.product.stock
                      ? () => setState(() => _quantity++)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Add to Cart Button
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
                onTap: widget.product.stock > 0 ? _addToCart : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Add to Cart - \$${(widget.product.salePrice ?? widget.product.price) * _quantity}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Buy Now Button
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
                onTap: widget.product.stock > 0 ? _buyNow : null,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: primaryColor,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Buy Now',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
