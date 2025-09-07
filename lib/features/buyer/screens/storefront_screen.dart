import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/appwrite_service.dart';
import '../../../models/product_model.dart';
import '../../../models/shop_model.dart';
import '../../../providers/cart_provider.dart';

class StorefrontScreen extends StatefulWidget {
  final String shopSlug;
  const StorefrontScreen({Key? key, required this.shopSlug}) : super(key: key);

  @override
  State<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends State<StorefrontScreen>
    with TickerProviderStateMixin {
  Shop? _shop;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Theme definitions (same as shop preview)
  final Map<String, ThemeData> _themes = {
    'Midnight Pro': ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      colorScheme: const ColorScheme.dark(
        tertiary: Color(0xFF06B6D4),
        primary: Color(0xFFFD366E),
        secondary: Color(0xFF7C3AED),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardTheme: CardTheme(
        color: const Color(0xFF1E293B),
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
      cardTheme: CardTheme(
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
      cardTheme: CardTheme(
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
      cardTheme: CardTheme(
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
      cardTheme: CardTheme(
        color: const Color(0xFF312E81),
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
      cardTheme: CardTheme(
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
      cardTheme: CardTheme(
        color: const Color(0xFF374151),
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
      cardTheme: CardTheme(
        color: Colors.white,
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
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

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

      // Get products for this shop
      final products = await AppwriteService.getProductsByShop(shop.id);
      _products = products;
      _filteredProducts = products;

      setState(() {
        _isLoading = false;
      });

      // Start animations
      _fadeController.forward();
      _slideController.forward();
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
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFD366E),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white.withOpacity(0.7),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadShopData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFD366E),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Get the theme from shop settings
    final shopTheme = _shop?.theme ?? 'Midnight Pro';
    final currentTheme = _themes[shopTheme] ?? _themes['Midnight Pro']!;

    return Theme(
      data: currentTheme,
      child: Container(
        decoration: BoxDecoration(
          gradient: _getThemeGradient(shopTheme),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: Consumer(
            builder: (context, ref, child) {
              final itemCount = ref.watch(cartProvider.notifier).itemCount;

              if (itemCount == 0) return const SizedBox.shrink();

              return FloatingActionButton.extended(
                onPressed: () => Navigator.pushNamed(context, '/cart'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.shopping_cart),
                label: Text('$itemCount'),
                elevation: 8,
              );
            },
          ),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildShopHeader(),
                    _buildSearchBar(),
                    _buildCategoryFilters(),
                    Expanded(
                      child: _filteredProducts.isEmpty
                          ? _buildEmptyState()
                          : _buildProductGrid(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopHeader() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Shop Logo and Banner
          if (_shop?.bannerUrl != null)
            Container(
              height: 120,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(_shop!.bannerUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          Row(
            children: [
              // Shop Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _shop?.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          _shop!.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.store, color: Colors.white, size: 30),
                        ),
                      )
                    : const Icon(Icons.store, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shop?.name ?? 'Shop',
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_shop?.description.isNotEmpty ?? false)
                      Text(
                        _shop!.description,
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black54,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          Consumer(
            builder: (context, ref, child) {
              final itemCount = ref.watch(cartProvider.notifier).itemCount;
              return Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(top: 16),
                child: IconButton(
                  icon: Badge(
                    label: itemCount > 0 ? Text('$itemCount') : null,
                    child: Icon(
                      Icons.shopping_cart,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: TextField(
        onChanged: (value) {
          _searchQuery = value;
          _filterProducts();
        },
        style: TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.5)
                : Colors.black38,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                  _filterProducts();
                });
                HapticFeedback.lightImpact();
              },
              backgroundColor: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white,
              selectedColor: theme.colorScheme.primary.withOpacity(0.3),
              checkmarkColor: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
              labelStyle: TextStyle(
                color: isSelected
                    ? (theme.brightness == Brightness.dark ? Colors.white : Colors.black87)
                    : (theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.7) : Colors.black54),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.5)
                : Colors.black38,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'All'
                ? 'No products found'
                : 'No products available',
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.7)
                  : Colors.black54,
              fontSize: 18,
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Try adjusting your search or filter',
                style: TextStyle(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black38,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final hasSale = product.salePrice != null && product.salePrice! < product.price;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showProductDetails(product),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                    ),
                    child: product.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image, color: Colors.white, size: 40),
                            ),
                          )
                        : Icon(
                            Icons.inventory,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.grey,
                            size: 40,
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Product Name
                Text(
                  product.name,
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Product Price
                Row(
                  children: [
                    if (hasSale) ...[
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black54,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '\$${(product.salePrice ?? product.price).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Stock Status
                Row(
                  children: [
                    Icon(
                      product.stock > 0 ? Icons.check_circle : Icons.cancel,
                      color: product.stock > 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.stock > 0 ? '${product.stock} in stock' : 'Out of stock',
                      style: TextStyle(
                        color: product.stock > 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // Category Tag
                if (product.category.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProductDetails(Product product) {
    if (_shop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shop data not available. Please try again.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/product-detail',
      arguments: {
        'product': product,
        'shop': _shop!,
      },
    );
  }

  LinearGradient _getThemeGradient(String themeName) {
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
}
