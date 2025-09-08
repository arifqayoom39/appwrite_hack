import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../services/appwrite_service.dart';
import '../../../models/product_model.dart';
import '../../../models/shop_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../themes/shop_themes.dart';

class StorefrontScreen extends StatefulWidget {
  final String shopSlug;
  const StorefrontScreen({Key? key, required this.shopSlug}) : super(key: key);

  @override
  State<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends State<StorefrontScreen> {
  Shop? _shop;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Theme variables will be initialized from ShopThemes based on shop's theme
  late Color primaryColor;
  late Color backgroundColor;
  late Color textColor;
  late Color lightGrayColor;
  late Color darkGrayColor;
  late Map<String, ThemeData> _themes;

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get shop by slug
      final shop = await AppwriteService.getShopBySlug(widget.shopSlug);
      if (shop == null) {
        setState(() {
          _error = 'Shop not found';
          _isLoading = false;
        });
        return;
      }

      _shop = shop;

      // Initialize theme based on shop's theme
      final shopTheme = shop.theme;
      final palette = ShopThemes.getBuyerThemePalette(shopTheme);
      
      // Set colors based on shop theme
      primaryColor = palette['primary']!;
      backgroundColor = palette['background']!;
      textColor = palette['text']!;
      lightGrayColor = palette['lightGray']!;
      darkGrayColor = palette['darkGray']!;
      
      // Set theme data
      _themes = ShopThemes.getBuyerThemes(shopTheme);

      // Get products for this shop
      final products = await AppwriteService.getProductsByShop(shop.id);
      _products = products;
      _filteredProducts = products;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load shop data: $e';
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.tags?.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase())) ?? false);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  List<String> get _categories {
    final categories = _products.map((p) => p.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Helper to check if on mobile device
  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;

  // Get psychological loading message
  String _getPsychologicalMessage() {
    final messages = [
      'Preparing something amazing...',
      'Your experience is loading...',
      'Almost ready to impress...',
      'Creating magic for you...',
      'Your journey begins soon...',
      'Getting everything ready...',
      'Loading your perfect experience...',
    ];

    return messages[DateTime.now().millisecondsSinceEpoch % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  'assets/loading.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
              const SizedBox(height: 24),
              
              // Psychological Message
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _getPsychologicalMessage(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3D3D3D),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Loading dots animation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(milliseconds: 500 + (index * 200)),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFD366E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.grey[400],
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFF3D3D3D)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadShopData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFD366E), // Default primary color
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Get theme - simplify to just light/dark
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final currentTheme = _themes[isDarkMode ? 'Dark' : 'Light']!;

    return Theme(
      data: currentTheme,
      child: Scaffold(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        appBar: _buildAppBar(currentTheme),
        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            final itemCount = ref.watch(cartProvider.notifier).itemCount;

            if (itemCount == 0) return const SizedBox.shrink();

            return FloatingActionButton.extended(
              onPressed: () => context.go('/cart?shopSlug=${widget.shopSlug}'),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart),
              label: Text('$itemCount'),
              elevation: 2,
            );
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShopHeader(currentTheme),
                _buildSearchBar(currentTheme),
                _buildCategoryFilters(currentTheme),
                _filteredProducts.isEmpty
                    ? _buildEmptyState(currentTheme)
                    : _buildProductGrid(currentTheme),
                const SizedBox(height: 80), // Space for FAB
              ],
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
        _shop?.name ?? 'Store',
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
        Consumer(
          builder: (context, ref, child) {
            final itemCount = ref.watch(cartProvider.notifier).itemCount;
            return IconButton(
              icon: Badge(
                label: itemCount > 0 ? Text('$itemCount') : null,
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                  size: 22,
                ),
              ),
              onPressed: () => context.go('/cart?shopSlug=${widget.shopSlug}'),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            color: theme.brightness == Brightness.dark ? Colors.white : textColor,
            size: 22,
          ),
          onPressed: () {
            // Focus on search field
            FocusScope.of(context).requestFocus(FocusNode());
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildShopHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Banner - sleeker and minimal
          if (_shop?.bannerUrl != null)
            Container(
              height: 120,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _shop!.bannerUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        color: lightGrayColor,
                        child: Icon(
                          Icons.store_outlined,
                          color: darkGrayColor,
                          size: 32,
                        ),
                      ),
                ),
              ),
            ),

          // Shop info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Logo and description
              Expanded(
                flex: 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Shop Logo - simplified
                    if (_shop?.logoUrl != null)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: lightGrayColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _shop!.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.store_outlined, color: darkGrayColor, size: 24),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: lightGrayColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.store_outlined, color: darkGrayColor, size: 24),
                      ),
                    const SizedBox(width: 12),

                    // Shop description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_shop?.description.isNotEmpty ?? false)
                            Text(
                              _shop!.description,
                              style: TextStyle(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white70
                                    : textColor,
                                fontSize: 14,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right side: Email and phone
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_shop?.email.isNotEmpty ?? false)
                      Text(
                        'Email: ${_shop!.email}',
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : textColor,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    if (_shop?.phone.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Phone: ${_shop!.phone}',
                          style: TextStyle(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white70
                                : textColor,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      height: 48,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? const Color(0xFF2A2A2A) 
            : lightGrayColor,
        borderRadius: BorderRadius.circular(8),
        border: theme.brightness == Brightness.dark
            ? Border.all(color: Colors.grey[800]!, width: 0.5)
            : null,
      ),
      child: TextField(
        onChanged: (value) {
          _searchQuery = value;
          _filterProducts();
        },
        style: TextStyle(
          fontSize: 15,
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : textColor,
        ),
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: TextStyle(
            color: theme.brightness == Brightness.dark
                ? Colors.grey[500]
                : darkGrayColor,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: darkGrayColor,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                category,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected 
                      ? (theme.brightness == Brightness.dark ? Colors.white : primaryColor)
                      : (theme.brightness == Brightness.dark ? Colors.grey[400] : darkGrayColor),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                  _filterProducts();
                });
                HapticFeedback.lightImpact();
              },
              backgroundColor: theme.brightness == Brightness.dark 
                  ? const Color(0xFF2A2A2A)
                  : lightGrayColor,
              selectedColor: theme.brightness == Brightness.dark
                  ? primaryColor.withOpacity(0.15)
                  : primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: isSelected
                    ? BorderSide(color: primaryColor.withOpacity(0.5), width: 1)
                    : BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 60,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            color: darkGrayColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'All'
                ? 'No products found'
                : 'No products available',
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Try adjusting your search or filter',
                style: TextStyle(
                  color: darkGrayColor,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile(context) ? 2 : 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          return _buildProductCard(_filteredProducts[index], theme);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, ThemeData theme) {
    final hasSale = product.salePrice != null && product.salePrice! < product.price;

    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : lightGrayColor,
                child: product.images.isNotEmpty
                    ? Image.network(
                        product.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: darkGrayColor,
                                size: 24,
                              ),
                            ),
                      )
                    : Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: darkGrayColor,
                          size: 24,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Product Name
          Text(
            product.name,
            style: TextStyle(
              color: theme.brightness == Brightness.dark 
                  ? Colors.white 
                  : textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Price row
          Row(
            children: [
              if (hasSale) ...[
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: darkGrayColor,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                '\$${(product.salePrice ?? product.price).toStringAsFixed(2)}',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              
              // Stock indicator - minimalistic dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: product.stock > 0
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Product product) {
    if (_shop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Shop data not available. Please try again.'),
          backgroundColor: primaryColor,
        ),
      );
      return;
    }

    context.push(
      '/product-detail',
      extra: {
        'product': product,
        'shop': _shop!,
      },
    );
  }
}
