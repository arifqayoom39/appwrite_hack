import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';

class FeaturesScreen extends ConsumerStatefulWidget {
  const FeaturesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends ConsumerState<FeaturesScreen>
    with TickerProviderStateMixin {
  // Appwrite theme colors
  static const Color appwritePink = Color(0xFFFD366E);
  static const Color appwriteBlack = Color(0xFF000000);
  static const Color appwriteDarkGray = Color(0xFF0F0F0F);
  static const Color appwriteBorder = Color(0xFF1A1A1A);

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
      backgroundColor: appwriteBlack,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
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
              _buildFeaturesGrid(),
              _buildDetailedFeatures(),
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
        if (isAuthenticated)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => context.go('/dashboard'),
              icon: const Icon(Icons.dashboard, color: Colors.white),
            ),
          )
        else ...[
          IconButton(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.login, color: Colors.white),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => context.go('/signup'),
              icon: const Icon(Icons.person_add, color: Colors.white),
            ),
          ),
        ]
      ] : [
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

  Widget _buildHeroSection() {
    return Container(
      padding: EdgeInsets.only(
        top: _isMobile ? 100 : 150,
        left: _isMobile ? 20 : 80,
        right: _isMobile ? 20 : 80,
        bottom: _isMobile ? 60 : 100,
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
                    Icons.star,
                    color: appwritePink,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Powerful Features',
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
              'Everything You Need\nto Succeed Online',
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
                'Discover the powerful features that make StorePe the perfect platform for your online business. From AI-powered design to advanced analytics, we have everything you need.',
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
            child: OutlinedButton.icon(
              onPressed: () => context.go('/pricing'),
              icon: const Icon(
                Icons.attach_money,
                size: 20,
              ),
              label: const Text(
                'View Pricing',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: appwriteBorder),
                padding: EdgeInsets.symmetric(horizontal: _isMobile ? 24 : 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturesGrid() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 80,
        vertical: _isMobile ? 60 : 100,
      ),
      child: AnimatedBuilder(
        animation: _featuresSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _featuresSlideAnimation.value),
            child: Column(
              children: [
                Text(
                  'Core Features',
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
                    'Powerful tools designed to help you create, manage, and scale your online business.',
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
                      icon: Icons.auto_awesome,
                      title: 'AI-Powered Design',
                      description: 'Intelligent design system creates beautiful stores automatically.',
                    ),
                    _buildFeatureCard(
                      icon: Icons.speed,
                      title: 'Lightning Fast',
                      description: 'Deploy in under 5 minutes with our optimized platform.',
                    ),
                    _buildFeatureCard(
                      icon: Icons.palette,
                      title: 'Beautiful Templates',
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

  Widget _buildDetailedFeatures() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 80,
        vertical: _isMobile ? 60 : 100,
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
            'Advanced Capabilities',
            style: TextStyle(
              fontSize: _isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          _isMobile
              ? Column(
                  children: [
                    _buildDetailedFeature(
                      icon: Icons.inventory,
                      title: 'Inventory Management',
                      description: 'Advanced inventory tracking with automatic stock alerts and low-stock notifications.',
                      isReversed: false,
                    ),
                    const SizedBox(height: 60),
                    _buildDetailedFeature(
                      icon: Icons.people,
                      title: 'Customer Management',
                      description: 'Comprehensive customer profiles with purchase history and personalized recommendations.',
                      isReversed: true,
                    ),
                    const SizedBox(height: 60),
                    _buildDetailedFeature(
                      icon: Icons.trending_up,
                      title: 'Advanced Analytics',
                      description: 'Deep insights into customer behavior, sales trends, and performance metrics.',
                      isReversed: false,
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildDetailedFeature(
                      icon: Icons.inventory,
                      title: 'Inventory Management',
                      description: 'Advanced inventory tracking with automatic stock alerts and low-stock notifications.',
                      isReversed: false,
                    ),
                    const SizedBox(height: 80),
                    _buildDetailedFeature(
                      icon: Icons.people,
                      title: 'Customer Management',
                      description: 'Comprehensive customer profiles with purchase history and personalized recommendations.',
                      isReversed: true,
                    ),
                    const SizedBox(height: 80),
                    _buildDetailedFeature(
                      icon: Icons.trending_up,
                      title: 'Advanced Analytics',
                      description: 'Deep insights into customer behavior, sales trends, and performance metrics.',
                      isReversed: false,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildDetailedFeature({
    required IconData icon,
    required String title,
    required String description,
    required bool isReversed,
  }) {
    return _isMobile
        ? Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: appwritePink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: appwritePink,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          )
        : Row(
            children: isReversed
                ? [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 300,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [appwritePink.withOpacity(0.2), appwritePink.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: appwritePink.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            color: appwritePink,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                  ]
                : [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 300,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [appwritePink.withOpacity(0.2), appwritePink.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: appwritePink.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            color: appwritePink,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.6,
                              ),
                            ),
                          ],
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
              'Ready to Experience These Features?',
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
                'Join thousands of successful businesses using StorePe. Start your free trial today and see the difference our features can make.',
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
                  context.go('/register');
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
