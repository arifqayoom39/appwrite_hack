import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/appwrite_service.dart';
import '../../../models/shop_model.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({Key? key}) : super(key: key);

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> 
    with TickerProviderStateMixin {
  String _selectedTheme = 'Midnight Pro';
  String _shopName = '';
  String _shopSlug = '';
  String _shopDescription = '';
  String _shopEmail = '';
  String _shopPhone = '';
  int _currentStep = 0;
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  
  final PageController _pageController = PageController();
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  
  // Mock data for shop preview
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Premium Wireless Headphones',
      'price': '\$299.99',
      'rating': 4.8,
      'image': '🎧',
      'category': 'Electronics'
    },
    {
      'name': 'Organic Coffee Blend',
      'price': '\$24.99',
      'rating': 4.9,
      'image': '☕',
      'category': 'Food & Beverage'
    },
    {
      'name': 'Smart Fitness Watch',
      'price': '\$199.99',
      'rating': 4.7,
      'image': '⌚',
      'category': 'Fitness'
    },
    {
      'name': 'Luxury Leather Wallet',
      'price': '\$89.99',
      'rating': 4.6,
      'image': '👛',
      'category': 'Fashion'
    },
  ];
  
  // Premium theme definitions with stunning gradients and colors
  final Map<String, ThemeData> _themes = {
    'Midnight Pro': ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFD366E),
        secondary: Color(0xFF7C3AED),
        surface: Color(0xFF0F172A),
        background: Color(0xFF1E293B),
        tertiary: Color(0xFF06B6D4),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF1E293B),
      ),
    ),
    'Ocean Breeze': ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.cyan,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0891B2),
        secondary: Color(0xFF06B6D4),
        surface: Color(0xFFF0F9FF),
        background: Color(0xFFFAFBFC),
        tertiary: Color(0xFF3B82F6),
      ),
      scaffoldBackgroundColor: const Color(0xFFF0F9FF),
      cardTheme: CardTheme(
        elevation: 6,
        shadowColor: const Color(0xFF0891B2).withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Colors.white,
      ),
    ),
    'Sunset Glow': ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.orange,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFEA580C),
        secondary: Color(0xFFF59E0B),
        surface: Color(0xFFFFF7ED),
        background: Color(0xFFFFFBF5),
        tertiary: Color(0xFFDC2626),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF7ED),
      cardTheme: CardTheme(
        elevation: 6,
        shadowColor: const Color(0xFFEA580C).withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
      ),
    ),
    'Forest Zen': ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.green,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF059669),
        secondary: Color(0xFF10B981),
        surface: Color(0xFFF0FDF4),
        background: Color(0xFFF9FDF9),
        tertiary: Color(0xFF84CC16),
      ),
      scaffoldBackgroundColor: const Color(0xFFF0FDF4),
      cardTheme: CardTheme(
        elevation: 6,
        shadowColor: const Color(0xFF059669).withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.white,
      ),
    ),
    'Royal Purple': ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.purple,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7C3AED),
        secondary: Color(0xFFA855F7),
        surface: Color(0xFF1E1B4B),
        background: Color(0xFF312E81),
        tertiary: Color(0xFFEC4899),
      ),
      scaffoldBackgroundColor: const Color(0xFF1E1B4B),
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: const Color(0xFF7C3AED).withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        color: const Color(0xFF312E81),
      ),
    ),
    'Aurora': ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.pink,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFDB2777),
        secondary: Color(0xFFEC4899),
        surface: Color(0xFFFDF2F8),
        background: Color(0xFFFEF7FF),
        tertiary: Color(0xFF7C3AED),
      ),
      scaffoldBackgroundColor: const Color(0xFFFDF2F8),
      cardTheme: CardTheme(
        elevation: 6,
        shadowColor: const Color(0xFFDB2777).withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        color: Colors.white,
      ),
    ),
    'Cosmic Dark': ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.indigo,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4F46E5),
        secondary: Color(0xFFFD366E),
        surface: Color(0xFF111827),
        background: Color(0xFF374151),
        tertiary: Color(0xFF10B981),
      ),
      scaffoldBackgroundColor: const Color(0xFF111827),
      cardTheme: CardTheme(
        elevation: 10,
        shadowColor: const Color(0xFF4F46E5).withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: const Color(0xFF374151),
      ),
    ),
    'Golden Luxury': ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.amber,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFD97706),
        secondary: Color(0xFFF59E0B),
        surface: Color(0xFFFFFBEB),
        background: Color(0xFFFFF8E1),
        tertiary: Color(0xFF92400E),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFBEB),
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: const Color(0xFFD97706).withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    ),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.elasticOut),
    );
    
    _animationController.forward();
    _progressController.forward();
  }

  Future<void> _createShop() async {
    if (_shopName.isEmpty || _shopSlug.isEmpty || _shopEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      // Get current user
      final user = await AppwriteService.getCurrentUser();
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      // Create shop
      final shop = Shop(
        id: '',
        name: _shopName,
        slug: _shopSlug,
        description: _shopDescription,
        email: _shopEmail,
        phone: _shopPhone,
        sellerId: user.$id,
        theme: _selectedTheme,
        createdAt: DateTime.now(),
      );

      final createdShop = await AppwriteService.createShop(shop);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shop "${createdShop.name}" created successfully!')),
      );

      // Navigate to dashboard or shop management
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create shop: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme = _themes[_selectedTheme] ?? _themes['Midnight Pro']!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0B14),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0B14),
              Color(0xFF1A1B2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildBasicInfoStep(),
                    _buildDesignStep(),
                    _buildPreviewStep(currentTheme),
                  ],
                ),
              ),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFD366E), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFD366E).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.storefront,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Your Shop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Build your dream store in minutes',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Text(
              'Step ${_currentStep + 1} of 3',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(3, (index) {
          bool isActive = index <= _currentStep;
          bool isCurrent = index == _currentStep;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: isActive
                    ? const LinearGradient(
                        colors: [Color(0xFFFD366E), Color(0xFF7C3AED)],
                      )
                    : null,
                color: isActive ? null : Colors.white.withOpacity(0.2),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFD366E).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFD366E), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFD366E).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                icon: Icon(_currentStep == 2 ? Icons.rocket_launch : Icons.arrow_forward),
                label: Text(_currentStep == 2 ? 'Launch Shop' : 'Continue'),
                onPressed: () {
                  if (_currentStep == 2) {
                    _createShop();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell us about your shop',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This information will help customers find and connect with your store',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            
            // Shop Name Card
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFD366E), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.store, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Shop Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildModernTextField(
                    controller: _controllers[0],
                    label: 'Shop Name',
                    hint: 'Enter your shop name',
                    icon: Icons.storefront,
                    onChanged: (value) => setState(() => _shopName = value),
                  ),
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    controller: _controllers[1],
                    label: 'Shop URL',
                    hint: 'your-shop-url',
                    icon: Icons.link,
                    onChanged: (value) => setState(() => _shopSlug = value),
                    prefix: 'shop.com/',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Shop Details Card
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.description, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Shop Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildModernTextField(
                    controller: _controllers[2],
                    label: 'Description',
                    hint: 'Tell customers about your shop...',
                    icon: Icons.edit_note,
                    maxLines: 3,
                    onChanged: (value) => setState(() => _shopDescription = value),
                  ),
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    controller: _controllers[3],
                    label: 'Contact Email',
                    hint: 'your@email.com',
                    icon: Icons.email,
                    onChanged: (value) => setState(() => _shopEmail = value),
                  ),
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    controller: _controllers[4],
                    label: 'Phone Number',
                    hint: '+1 (555) 123-4567',
                    icon: Icons.phone,
                    onChanged: (value) => setState(() => _shopPhone = value),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Design your shop',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose colors and themes that represent your brand',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            
            // Theme Selection Card
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEC4899), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.palette, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Choose Your Theme',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _themes.length,
                    itemBuilder: (context, index) {
                      final themeName = _themes.keys.elementAt(index);
                      final theme = _themes[themeName]!;
                      final isSelected = _selectedTheme == themeName;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTheme = themeName;
                          });
                          HapticFeedback.lightImpact();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFD366E) : Colors.white.withOpacity(0.1),
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFD366E).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Color(0xFFFD366E),
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.7),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  themeName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Brand Assets Card
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Brand Assets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildUploadCard(
                          title: 'Logo',
                          subtitle: 'Upload your logo',
                          icon: Icons.account_balance,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildUploadCard(
                          title: 'Banner',
                          subtitle: 'Shop banner image',
                          icon: Icons.panorama,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStep(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Theme(
        data: theme,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.scaffoldBackgroundColor,
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: Column(
            children: [
              // Preview Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFD366E), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.visibility, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Shop Preview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedTheme} • ${_shopSlug.isNotEmpty ? 'shop.com/$_shopSlug' : 'Custom URL'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Mobile Preview Frame
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Scaffold(
                      backgroundColor: theme.scaffoldBackgroundColor,
                      appBar: AppBar(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        title: Text(_shopName.isNotEmpty ? _shopName : 'My Shop'),
                        actions: [
                          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
                        ],
                      ),
                      body: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Shop Header
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.1),
                                    theme.colorScheme.secondary.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary,
                                          theme.colorScheme.secondary,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.store,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _shopName.isNotEmpty ? _shopName : 'Amazing Shop',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _shopDescription.isNotEmpty 
                                        ? _shopDescription 
                                        : 'Welcome to our amazing store with great products!',
                                    style: theme.textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_shopEmail.isNotEmpty || _shopPhone.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_shopEmail.isNotEmpty) ...[
                                          Icon(Icons.email, size: 16, color: theme.colorScheme.primary),
                                          const SizedBox(width: 4),
                                          Text(_shopEmail, style: const TextStyle(fontSize: 12)),
                                        ],
                                        if (_shopEmail.isNotEmpty && _shopPhone.isNotEmpty)
                                          const SizedBox(width: 16),
                                        if (_shopPhone.isNotEmpty) ...[
                                          Icon(Icons.phone, size: 16, color: theme.colorScheme.primary),
                                          const SizedBox(width: 4),
                                          Text(_shopPhone, style: const TextStyle(fontSize: 12)),
                                        ],
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            // Products Grid
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Featured Products',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.8,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                    itemCount: _products.length,
                                    itemBuilder: (context, index) {
                                      final product = _products[index];
                                      return Card(
                                        elevation: 4,
                                        clipBehavior: Clip.antiAlias,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 80,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    theme.colorScheme.primary.withOpacity(0.1),
                                                    theme.colorScheme.secondary.withOpacity(0.1),
                                                  ],
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  product['image'],
                                                  style: const TextStyle(fontSize: 32),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      product['name'],
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const Spacer(),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          product['price'],
                                                          style: TextStyle(
                                                            color: theme.colorScheme.primary,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.star, size: 12, color: Colors.amber),
                                                            Text(
                                                              '${product['rating']}',
                                                              style: const TextStyle(fontSize: 10),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    String? prefix,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          prefixText: prefix,
          prefixStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        // Handle file upload
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFD366E), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
