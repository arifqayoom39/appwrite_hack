import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShopPreviewScreen extends StatefulWidget {
  const ShopPreviewScreen({Key? key}) : super(key: key);

  @override
  State<ShopPreviewScreen> createState() => _ShopPreviewScreenState();
}

class _ShopPreviewScreenState extends State<ShopPreviewScreen>
    with TickerProviderStateMixin {
  String _selectedTheme = 'Midnight Pro';
  String _shopName = 'Stellar Shop';
  String _shopUrl = 'stellar-shop';
  int _currentTab = 0;
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock data for shop preview with stunning visuals
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Premium Wireless Headphones',
      'price': '\$299.99',
      'originalPrice': '\$399.99',
      'rating': 4.8,
      'image': '🎧',
      'category': 'Electronics',
      'badge': 'Best Seller',
      'discount': '25% OFF'
    },
    {
      'name': 'Organic Coffee Blend',
      'price': '\$24.99',
      'originalPrice': '\$34.99',
      'rating': 4.9,
      'image': '☕',
      'category': 'Food & Beverage',
      'badge': 'Premium',
      'discount': '30% OFF'
    },
    {
      'name': 'Smart Fitness Watch',
      'price': '\$199.99',
      'originalPrice': '\$249.99',
      'rating': 4.7,
      'image': '⌚',
      'category': 'Fitness',
      'badge': 'New',
      'discount': '20% OFF'
    },
    {
      'name': 'Luxury Leather Wallet',
      'price': '\$89.99',
      'originalPrice': '\$129.99',
      'rating': 4.6,
      'image': '👛',
      'category': 'Fashion',
      'badge': 'Limited',
      'discount': '31% OFF'
    },
    {
      'name': 'Wireless Earbuds Pro',
      'price': '\$149.99',
      'originalPrice': '\$199.99',
      'rating': 4.9,
      'image': '🎵',
      'category': 'Electronics',
      'badge': 'Hot',
      'discount': '25% OFF'
    },
    {
      'name': 'Gaming Mechanical Keyboard',
      'price': '\$179.99',
      'originalPrice': '\$229.99',
      'rating': 4.8,
      'image': '⌨️',
      'category': 'Gaming',
      'badge': 'Pro',
      'discount': '22% OFF'
    },
  ];

  // Premium theme definitions with stunning gradients and colors (same as create shop)
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
    _tabController = TabController(length: 2, vsync: this);
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
    
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = _themes[_selectedTheme] ?? _themes['Midnight Pro']!;

    return Theme(
      data: currentTheme,
      child: Container(
        decoration: BoxDecoration(
          gradient: _getThemeGradient(_selectedTheme),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Preview Your Shop',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Shop'),
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: currentTheme.colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.7),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.palette_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Themes'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Preview'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildThemeSelectionTab(),
              _buildShopPreviewTab(currentTheme),
            ],
          ),
        ),
      ),
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

  Widget _buildThemeSelectionTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.only(top: 120, left: 24, right: 24, bottom: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.palette_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Choose Your Theme',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Select a stunning theme for your shop',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Currently using: $_selectedTheme',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Themes Grid
                Text(
                  'Available Themes',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _themes.keys.length,
                  itemBuilder: (context, index) {
                    final themeName = _themes.keys.elementAt(index);
                    final isSelected = _selectedTheme == themeName;
                    
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _selectedTheme = themeName;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          gradient: isSelected 
                            ? LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                          color: isSelected ? null : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected 
                              ? Colors.white.withOpacity(0.6)
                              : Colors.white.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 0,
                            ),
                          ] : null,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Theme preview
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: _getThemeGradient(themeName),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              width: 20,
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.8),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.6),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            left: 8,
                                            right: 8,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    height: 2,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.4),
                                                      borderRadius: BorderRadius.circular(1),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Container(
                                                  width: 16,
                                                  height: 2,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.6),
                                                    borderRadius: BorderRadius.circular(1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Theme name
                                  Text(
                                    themeName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 4),
                                  
                                  Text(
                                    _getThemeDescription(themeName),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Selection indicator
                            if (isSelected)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Color(0xFF10B981),
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Action Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _tabController.animateTo(1);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility_outlined, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Preview Shop',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        ],
                      ),
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

  String _getThemeDescription(String themeName) {
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

  Widget _buildShopPreviewTab(ThemeData theme) {
    return Theme(
      data: theme,
      child: Container(
        padding: const EdgeInsets.only(top: 120),
        child: Builder(
          builder: (context) => Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                ? const Color(0xFF0F172A)
                : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: theme.colorScheme.primary,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Text(
                    _shopName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                          onPressed: () {},
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Banner Section
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                              theme.colorScheme.tertiary,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Background pattern
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.1,
                                child: CustomPaint(
                                  painter: PatternPainter(),
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: theme.colorScheme.primary,
                                      child: Text(
                                        _shopName.isNotEmpty ? _shopName[0].toUpperCase() : 'S',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Welcome to $_shopName',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'shopurl.com/$_shopUrl',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Discover amazing products with unbeatable prices.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Stats Section
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildStatCard(
                                '1.2K+',
                                'Products',
                                Icons.inventory_2_outlined,
                                theme,
                              ),
                              const SizedBox(width: 16),
                              _buildStatCard(
                                '4.9★',
                                'Rating',
                                Icons.star_outline,
                                theme,
                              ),
                              const SizedBox(width: 16),
                              _buildStatCard(
                                '15K+',
                                'Customers',
                                Icons.people_outline,
                                theme,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Featured Products Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Featured Products',
                                  style: TextStyle(
                                    color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'View All',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                return _buildProductCard(product, theme);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Categories Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shop by Category',
                              style: TextStyle(
                                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 100,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                children: [
                                  'Electronics',
                                  'Fashion',
                                  'Food & Beverage',
                                  'Fitness',
                                  'Gaming',
                                  'Home & Garden',
                                ].map((category) => _buildCategoryCard(category, theme)).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Preview Actions
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.1),
                              theme.colorScheme.secondary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.preview,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Preview Mode',
                                        style: TextStyle(
                                          color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'This is how your "$_selectedTheme" themed shop will look',
                                        style: TextStyle(
                                          color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: theme.colorScheme.primary),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(22),
                                        onTap: () => _tabController.animateTo(0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.arrow_back,
                                              color: theme.colorScheme.primary,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Back to Themes',
                                              style: TextStyle(
                                                color: theme.colorScheme.primary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary,
                                          theme.colorScheme.secondary,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(22),
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          // TODO: Implement publish functionality
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.rocket_launch,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Publish Shop',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, ThemeData theme) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
          ? Colors.white.withOpacity(0.1)
          : theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark 
            ? Colors.white.withOpacity(0.2)
            : theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
          ? Colors.white.withOpacity(0.1)
          : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark 
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.3),
                    theme.colorScheme.secondary.withOpacity(0.3),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      product['image'],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  if (product['badge'] != null)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          product['badge'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (product['discount'] != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product['discount'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product['name'],
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 2),
                    
                    Text(
                      product['category'],
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark ? Colors.white60 : Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          '${product['rating']}',
                          style: TextStyle(
                            color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Price
                    Row(
                      children: [
                        Text(
                          product['price'],
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (product['originalPrice'] != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            product['originalPrice'],
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark ? Colors.white60 : Colors.black54,
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category, ThemeData theme) {
    final icons = {
      'Electronics': Icons.devices,
      'Fashion': Icons.checkroom,
      'Food & Beverage': Icons.restaurant,
      'Fitness': Icons.fitness_center,
      'Gaming': Icons.sports_esports,
      'Home & Garden': Icons.home,
    };
    
    return Container(
      width: 85,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                ? Colors.white.withOpacity(0.1)
                : theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.2)
                  : theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Icon(
              icons[category] ?? Icons.category,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category,
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0;

    const spacing = 20.0;
    
    // Draw diagonal lines
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
