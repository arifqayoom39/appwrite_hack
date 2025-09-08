import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/landing_store_preview.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen>
    with TickerProviderStateMixin {
  // Appwrite theme colors
  static const Color appwritePink = Color(0xFFFD366E);
  static const Color appwriteBlack = Color(0xFF000000);
  static const Color appwriteDarkGray = Color(0xFF0F0F0F);
  static const Color appwriteBorder = Color(0xFF1A1A1A);
  static const Color appwriteGreen = Color(0xFF4CAF50);
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  late AnimationController _heroAnimationController;
  late Animation<double> _heroFadeAnimation;
  late AnimationController _featuresAnimationController;
  late Animation<double> _featuresSlideAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();

    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _featuresAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroAnimationController, curve: Curves.easeOut),
    );
    _featuresSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _featuresAnimationController, curve: Curves.easeOut),
    );

    _heroAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _featuresAnimationController.forward();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _featuresAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _isScrolled = _scrollController.offset > 50;
    });
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 768;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: appwriteBlack,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      endDrawer: _buildDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appwriteBlack,
              appwriteDarkGray,
              appwriteBlack,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              _buildHeroSection(),
              _buildFeaturesSection(),
              _buildStatsSection(),
              _buildCTASection(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = authState == AuthState.authenticated;
    
    return AppBar(
      backgroundColor: _isScrolled
          ? appwriteBlack.withOpacity(0.95)
          : Colors.transparent,
      elevation: _isScrolled ? 0 : 0,
      surfaceTintColor: Colors.transparent,
      title: GestureDetector(
        onTap: () => context.go('/'),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: appwritePink,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: appwritePink.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.storefront,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'StorePe',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      actions: _isMobile ? [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ] : [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: appwriteGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: appwriteGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.psychology,
                  color: appwriteGreen,
                  size: 14,
                ),
                const SizedBox(width: 6),
                const Text(
                  'AI Coming Soon 🚀',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/features'),
          child: const Text(
            'Features',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/pricing'),
          child: const Text(
            'Pricing',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/about'),
          child: const Text(
            'About',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/support'),
          child: const Text(
            'Support',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (isAuthenticated) ...[
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => context.go('/dashboard'),
              icon: const Icon(Icons.dashboard, size: 18),
              label: const Text('Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: appwritePink,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ] else ...[
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text(
              'Sign In',
              style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () => context.go('/signup'),
              child: const Text('Get Started'),
              style: ElevatedButton.styleFrom(
          backgroundColor: appwritePink,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDrawer() {
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = authState == AuthState.authenticated;
    
    return Drawer(
      backgroundColor: appwriteDarkGray,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: appwriteBlack,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: appwritePink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'StorePe',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.speed, color: appwritePink),
            title: const Text('Features', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              context.go('/features');
            },
          ),
          ListTile(
            leading: Icon(Icons.attach_money, color: appwritePink),
            title: const Text('Pricing', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              context.go('/pricing');
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: appwritePink),
            title: const Text('About', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              context.go('/about');
            },
          ),
          ListTile(
            leading: Icon(Icons.support, color: appwritePink),
            title: const Text('Support', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              context.go('/support');
            },
          ),
          if (!isAuthenticated) ...[
            ListTile(
              leading: Icon(Icons.login, color: appwritePink),
              title: const Text('Sign In', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                context.go('/login');
              },
            ),
            ListTile(
              leading: Icon(Icons.rocket_launch, color: appwritePink),
              title: const Text('Get Started', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                context.go('/signup');
              },
            ),
          ] else
            ListTile(
              leading: Icon(Icons.dashboard, color: appwritePink),
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                context.go('/dashboard');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: EdgeInsets.only(
        top: _isMobile ? 100 : 150,
        left: _isMobile ? 20 : 80,
        right: _isMobile ? 20 : 80,
      ),
      child: FadeTransition(
        opacity: _heroFadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: appwritePink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: appwritePink.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.rocket_launch,
                    color: appwritePink,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Launch your store in minutes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Main heading
            Text(
              'Build Beautiful Stores\nInstantly',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _isMobile ? 40 : 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -0.02,
              ),
            ),
            const SizedBox(height: 20),
            
            // Subheading
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Text(
                'Create stunning ecommerce websites without any coding. Our AI-powered platform helps you launch your online store in minutes, not months.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _isMobile ? 18 : 20,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // CTA Buttons
            _buildHeroButtons(),
            const SizedBox(height: 60),
            
            // Store preview
            _buildHeroPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroButtons() {
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = authState == AuthState.authenticated;
    
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [appwritePink, Color(0xFFE91E63)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: appwritePink.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              context.go(isAuthenticated ? '/dashboard' : '/signup');
            },
            icon: Icon(
              isAuthenticated ? Icons.dashboard : Icons.rocket_launch,
              size: 20,
            ),
            label: Text(
              isAuthenticated ? 'Go to Dashboard' : 'Start Building',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: _isMobile ? 24 : 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (!isAuthenticated)
          Container(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: _isMobile ? 24 : 32),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: appwriteGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: appwriteGreen.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: appwriteGreen.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.psychology,
                    color: appwriteGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Features Coming Soon 🚀',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeroPreview() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: _isMobile ? double.infinity : 800,
        maxHeight: _isMobile ? 300 : 500,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appwriteBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: appwritePink.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                appwriteDarkGray,
                appwriteBlack,
              ],
            ),
          ),
          child: const LandingStorePreview(),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 80,
        vertical: _isMobile ? 80 : 120,
      ),
      child: AnimatedBuilder(
        animation: _featuresSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _featuresSlideAnimation.value),
            child: Column(
              children: [
                Text(
                  'Everything you need to succeed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _isMobile ? 32 : 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Text(
                    'Powerful features designed to help you create, manage, and scale your online business.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _isMobile ? 16 : 18,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: _isMobile ? 2 : 3,
                  mainAxisSpacing: _isMobile ? 16 : 32,
                  crossAxisSpacing: _isMobile ? 16 : 32,
                  childAspectRatio: _isMobile ? 1.3 : 1.0,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.speed,
                      title: 'Lightning Fast',
                      description: 'Deploy in under 5 minutes with our optimized platform.',
                    ),
                    _buildFeatureCard(
                      icon: Icons.palette,
                      title: 'Beautiful Designs',
                      description: 'Professional templates that convert visitors.',
                    ),
                    _buildFeatureCard(
                      icon: Icons.analytics,
                      title: 'Real-time Analytics',
                      description: 'Track performance with detailed insights.',
                    ),
                    _buildFeatureCard(
                      icon: Icons.payment,
                      title: 'Secure Payments',
                      description: 'Accept payments safely with integrated solutions.',
                    ),
                    _buildFeatureCard(
                      icon: Icons.mobile_friendly,
                      title: 'Mobile Optimized',
                      description: 'Perfect on every device, automatically.',
                    ),
                    _buildFeatureCard(
                      icon: Icons.support_agent,
                      title: '24/7 Support',
                      description: 'Get help anytime from our expert team.',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(_isMobile ? 12 : 32),
      decoration: BoxDecoration(
        color: appwriteDarkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appwriteBorder,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appwritePink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: appwritePink,
              size: _isMobile ? 20 : 32,
            ),
          ),
          SizedBox(height: _isMobile ? 8 : 24),
          _isMobile
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
          SizedBox(height: _isMobile ? 4 : 12),
          _isMobile
              ? Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 80,
        vertical: _isMobile ? 60 : 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            appwritePink.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Trusted by thousands of businesses',
            style: TextStyle(
              fontSize: _isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: _isMobile ? 2 : 4,
            mainAxisSpacing: _isMobile ? 16 : 32,
            crossAxisSpacing: _isMobile ? 16 : 32,
            childAspectRatio: _isMobile ? 1.3 : 1.0,
            children: [
              _buildStatCard('10K+', 'Active Stores'),
              _buildStatCard('99.9%', 'Uptime'),
              _buildStatCard('\$50M+', 'Revenue Generated'),
              _buildStatCard('4.9/5', 'Customer Rating'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: _isMobile
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: appwritePink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFD366E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
        SizedBox(height: _isMobile ? 4 : 8),
        Expanded(
          flex: 1,
          child: _isMobile
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCTASection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 80,
        vertical: _isMobile ? 80 : 120,
      ),
      child: Container(
        padding: EdgeInsets.all(_isMobile ? 40 : 80),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appwritePink.withOpacity(0.1),
              appwritePink.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: appwritePink.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Ready to start selling?',
              style: TextStyle(
                fontSize: _isMobile ? 32 : 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Text(
                'Join thousands of successful businesses. Create your online store today and start selling within minutes.',
                style: TextStyle(
                  fontSize: _isMobile ? 16 : 18,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [appwritePink, Color(0xFFE91E63)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: appwritePink.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/signup');
                },
                icon: const Icon(Icons.rocket_launch, size: 20),
                label: const Text(
                  'Get Started Free',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: _isMobile ? 20 : 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(_isMobile ? 32 : 80),
      decoration: const BoxDecoration(
        color: appwriteDarkGray,
        border: Border(
          top: BorderSide(
            color: appwriteBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _isMobile
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: appwritePink,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'StorePe',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFooterLink('Features'),
                        _buildFooterLink('Pricing'),
                        _buildFooterLink('About'),
                        _buildFooterLink('Support'),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: appwritePink,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'StorePe',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildFooterLink('Features'),
                        const SizedBox(width: 32),
                        _buildFooterLink('Pricing'),
                        const SizedBox(width: 32),
                        _buildFooterLink('About'),
                        const SizedBox(width: 32),
                        _buildFooterLink('Support'),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 32),
          Divider(
            color: appwriteBorder,
            thickness: 1,
          ),
          const SizedBox(height: 32),
          _isMobile
              ? Column(
                  children: [
                    Text(
                      '© 2025 StorePe. All rights reserved.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(Icons.chat),
                        const SizedBox(width: 12),
                        _buildSocialIcon(Icons.email),
                        const SizedBox(width: 12),
                        _buildSocialIcon(Icons.link),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '© 2025 StorePe. All rights reserved.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        _buildSocialIcon(Icons.chat),
                        const SizedBox(width: 12),
                        _buildSocialIcon(Icons.email),
                        const SizedBox(width: 12),
                        _buildSocialIcon(Icons.link),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return TextButton(
      onPressed: () {
        if (text == 'Features') context.go('/features');
        if (text == 'Pricing') context.go('/pricing');
        if (text == 'About') context.go('/about');
        if (text == 'Support') context.go('/support');
      },
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: appwriteBorder,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: Colors.white.withOpacity(0.7),
        size: 16,
      ),
    );
  }
}
