import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroAnimationController;
  late Animation<double> _heroFadeAnimation;
  late AnimationController _featuresAnimationController;
  late Animation<double> _featuresSlideAnimation;
  late AnimationController _statsAnimationController;
  late Animation<double> _statsScaleAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Global keys for sections
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();
  final GlobalKey _aboutUsKey = GlobalKey();

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
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroAnimationController, curve: Curves.easeInOut),
    );
    _featuresSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _featuresAnimationController, curve: Curves.elasticOut),
    );
    _statsScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _statsAnimationController, curve: Curves.elasticOut),
    );

    _heroAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _featuresAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _statsAnimationController.forward();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _featuresAnimationController.dispose();
    _statsAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _isScrolled = _scrollController.offset > 50;
    });
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 768;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
              Color(0xFF0F172A),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + (_isMobile ? 80.0 : 56.0)),
                child: _buildHeroSection(),
              ),
              _buildFeaturesSection(),
              _buildHowItWorksSection(),
              _buildStatsSection(),
              _buildTestimonialsSection(),
              _buildPricingSection(),
              _buildCTASection(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _isScrolled
          ? Colors.black.withOpacity(0.8)
          : Colors.transparent,
      elevation: _isScrolled ? 8 : 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'PopStore',
            style: TextStyle(
              color: Colors.white,
              fontSize: _isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: _isMobile ? [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          icon: const Icon(Icons.login, color: Colors.white),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
            icon: const Icon(Icons.person_add, color: Colors.white),
          ),
        ),
      ] : [
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: _isMobile ? null : MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.symmetric(horizontal: _isMobile ? 16 : 24),
      child: FadeTransition(
        opacity: _heroFadeAnimation,
        child: _isMobile ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeroText(),
            const SizedBox(height: 32),
            _buildHeroButtons(),
            const SizedBox(height: 32),
            _buildTrustIndicators(),
            const SizedBox(height: 32),
            _buildHeroImage(),
          ],
        ) : Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroText(),
                  const SizedBox(height: 32),
                  _buildHeroButtons(),
                  const SizedBox(height: 32),
                  _buildTrustIndicators(),
                ],
              ),
            ),
            const SizedBox(width: 80),
            Expanded(
              child: _buildHeroImage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.3),
            ),
          ),
          child: const Text(
            '🚀 #1 Instant Ecommerce Platform',
            style: TextStyle(
              color: Color(0xFF10B981),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Create Stunning\nEcommerce Websites\nin Minutes',
          style: TextStyle(
            fontSize: _isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
          ),
          textAlign: _isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 12),
        Text(
          'Launch your online store instantly with our AI-powered platform. No coding required, just beautiful results.',
          style: TextStyle(
            fontSize: _isMobile ? 16 : 18,
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
          textAlign: _isMobile ? TextAlign.center : TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildHeroButtons() {
    return _isMobile ? Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.rocket_launch, size: 24),
            label: const Text(
              'Start Creating Now',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/signup');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          icon: const Icon(
            Icons.play_circle_fill,
            color: Color(0xFF6366F1),
            size: 24,
          ),
          label: const Text(
            'Watch Demo',
            style: TextStyle(
              color: Color(0xFF6366F1),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            // Handle demo video
            HapticFeedback.lightImpact();
          },
        ),
      ],
    ) : SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.rocket_launch, size: 24),
              label: const Text(
                'Start Creating Now',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          TextButton.icon(
            icon: const Icon(
              Icons.play_circle_fill,
              color: Color(0xFF6366F1),
              size: 24,
            ),
            label: const Text(
              'Watch Demo',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () {
              // Handle demo video
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrustIndicators() {
    return _isMobile ? Column(
      children: [
        _buildTrustIndicator('4.9/5', Icons.star, const Color(0xFFF59E0B)),
        const SizedBox(height: 16),
        _buildTrustIndicator('10K+ Stores', Icons.store, const Color(0xFF10B981)),
        const SizedBox(height: 16),
        _buildTrustIndicator('99.9% Uptime', Icons.verified, const Color(0xFF06B6D4)),
      ],
    ) : SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTrustIndicator('4.9/5', Icons.star, const Color(0xFFF59E0B)),
          const SizedBox(width: 24),
          _buildTrustIndicator('10K+ Stores', Icons.store, const Color(0xFF10B981)),
          const SizedBox(width: 24),
          _buildTrustIndicator('99.9% Uptime', Icons.verified, const Color(0xFF06B6D4)),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: _isMobile ? 300 : 500,
      width: _isMobile ? double.infinity : null,
      margin: _isMobile ? const EdgeInsets.symmetric(horizontal: 16) : EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.2),
                        const Color(0xFF8B5CF6).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Icons.web,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your Store Preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'See how beautiful your store will look',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: _isMobile ? 14 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustIndicator(String text, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      key: _featuresKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _isMobile ? 16 : 24, vertical: _isMobile ? 40 : 80),
        child: Column(
          children: [
            Text(
              'Why Choose PopStore?',
              style: TextStyle(
                fontSize: _isMobile ? 32 : 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Everything you need to create and manage a successful online store',
              style: TextStyle(
                fontSize: _isMobile ? 16 : 20,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _isMobile ? 40 : 80),
            AnimatedBuilder(
              animation: _featuresSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _featuresSlideAnimation.value),
                  child: Wrap(
                    spacing: _isMobile ? 16 : 40,
                    runSpacing: _isMobile ? 16 : 40,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.electric_bolt,
                        title: 'Lightning Fast Setup',
                        description: 'Create your store in under 5 minutes with our intuitive builder',
                        gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                      ),
                      _buildFeatureCard(
                        icon: Icons.palette,
                        title: 'Beautiful Templates',
                        description: 'Choose from 100+ professionally designed templates',
                        gradient: const [Color(0xFFEC4899), Color(0xFFF472B6)],
                      ),
                      _buildFeatureCard(
                        icon: Icons.smartphone,
                        title: 'Mobile Optimized',
                        description: 'Your store looks perfect on all devices and screen sizes',
                        gradient: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
                      ),
                      _buildFeatureCard(
                        icon: Icons.analytics,
                        title: 'Advanced Analytics',
                        description: 'Track sales, customers, and performance with detailed insights',
                        gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      _buildFeatureCard(
                        icon: Icons.payment,
                        title: 'Secure Payments',
                        description: 'Accept payments worldwide with integrated payment gateways',
                        gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      _buildFeatureCard(
                        icon: Icons.support_agent,
                        title: '24/7 Support',
                        description: 'Get help whenever you need it from our expert support team',
                        gradient: const [Color(0xFFEF4444), Color(0xFFF87171)],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
  }) {
    return Container(
      width: _isMobile ? MediaQuery.of(context).size.width * 0.9 : 350,
      padding: EdgeInsets.all(_isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: _isMobile ? 24 : 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: _isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: _isMobile ? 14 : 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _isMobile ? 16 : 24, vertical: _isMobile ? 40 : 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF1E293B).withOpacity(0.5),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'How It Works',
            style: TextStyle(
              fontSize: _isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Get your store up and running in just 3 simple steps',
            style: TextStyle(
              fontSize: _isMobile ? 16 : 20,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _isMobile ? 40 : 80),
          _isMobile ? Column(
            children: [
              _buildStepCard(
                step: '01',
                title: 'Choose Template',
                description: 'Select from our collection of beautiful, mobile-optimized templates',
                icon: Icons.design_services,
                gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              const SizedBox(height: 20),
              _buildStepConnector(),
              const SizedBox(height: 20),
              _buildStepCard(
                step: '02',
                title: 'Customize & Add Products',
                description: 'Personalize your store and upload your products with our easy tools',
                icon: Icons.edit,
                gradient: const [Color(0xFF10B981), Color(0xFF06B6D4)],
              ),
              const SizedBox(height: 20),
              _buildStepConnector(),
              const SizedBox(height: 20),
              _buildStepCard(
                step: '03',
                title: 'Launch & Sell',
                description: 'Go live instantly and start accepting orders from customers worldwide',
                icon: Icons.rocket_launch,
                gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
              ),
            ],
          ) : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepCard(
                  step: '01',
                  title: 'Choose Template',
                  description: 'Select from our collection of beautiful, mobile-optimized templates',
                  icon: Icons.design_services,
                  gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                _buildStepConnector(),
                _buildStepCard(
                  step: '02',
                  title: 'Customize & Add Products',
                  description: 'Personalize your store and upload your products with our easy tools',
                  icon: Icons.edit,
                  gradient: const [Color(0xFF10B981), Color(0xFF06B6D4)],
                ),
                _buildStepConnector(),
                _buildStepCard(
                  step: '03',
                  title: 'Launch & Sell',
                  description: 'Go live instantly and start accepting orders from customers worldwide',
                  icon: Icons.rocket_launch,
                  gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      width: _isMobile ? MediaQuery.of(context).size.width * 0.9 : 300,
      padding: EdgeInsets.all(_isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              step,
              style: TextStyle(
                color: Colors.white,
                fontSize: _isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Icon(icon, color: Colors.white, size: _isMobile ? 40 : 48),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: _isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: _isMobile ? 14 : 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        Icons.arrow_forward,
        color: Colors.white.withOpacity(0.5),
        size: 32,
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _isMobile ? 16 : 24, vertical: _isMobile ? 40 : 80),
      child: AnimatedBuilder(
        animation: _statsScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _statsScaleAnimation.value,
            child: Column(
              children: [
                Text(
                  'Trusted by Thousands',
                  style: TextStyle(
                    fontSize: _isMobile ? 32 : 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: _isMobile ? 40 : 80),
                _isMobile ? Column(
                  children: [
                    _buildStatItem('10,000+', 'Stores Created', const Color(0xFF6366F1)),
                    const SizedBox(height: 40),
                    _buildStatItem('500K+', 'Products Sold', const Color(0xFF10B981)),
                    const SizedBox(height: 40),
                    _buildStatItem('99.9%', 'Uptime', const Color(0xFF06B6D4)),
                    const SizedBox(height: 40),
                    _buildStatItem('24/7', 'Support', const Color(0xFFF59E0B)),
                  ],
                ) : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem('10,000+', 'Stores Created', const Color(0xFF6366F1)),
                      const SizedBox(width: 80),
                      _buildStatItem('500K+', 'Products Sold', const Color(0xFF10B981)),
                      const SizedBox(width: 80),
                      _buildStatItem('99.9%', 'Uptime', const Color(0xFF06B6D4)),
                      const SizedBox(width: 80),
                      _buildStatItem('24/7', 'Support', const Color(0xFFF59E0B)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: _isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: _isMobile ? 14 : 18,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _isMobile ? 16 : 24, vertical: _isMobile ? 40 : 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF1E293B).withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'What Our Customers Say',
            style: TextStyle(
              fontSize: _isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _isMobile ? 40 : 80),
          _isMobile ? Column(
            children: [
              _buildTestimonialCard(
                name: 'Sarah Johnson',
                role: 'Fashion Store Owner',
                content: 'PopStore transformed my business! I went from zero to 10K monthly revenue in just 2 months. The platform is incredibly easy to use.',
                avatar: 'SJ',
                rating: 5,
              ),
              const SizedBox(height: 20),
              _buildTestimonialCard(
                name: 'Mike Chen',
                role: 'Tech Gadgets Seller',
                content: 'The templates are stunning and the analytics help me make better decisions. Customer support is always there when I need them.',
                avatar: 'MC',
                rating: 5,
              ),
              const SizedBox(height: 20),
              _buildTestimonialCard(
                name: 'Emma Davis',
                role: 'Handmade Crafts',
                content: 'I love how professional my store looks. PopStore made it so easy to showcase my handmade items and reach more customers.',
                avatar: 'ED',
                rating: 5,
              ),
            ],
          ) : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTestimonialCard(
                  name: 'Sarah Johnson',
                  role: 'Fashion Store Owner',
                  content: 'PopStore transformed my business! I went from zero to 10K monthly revenue in just 2 months. The platform is incredibly easy to use.',
                  avatar: 'SJ',
                  rating: 5,
                ),
                const SizedBox(width: 40),
                _buildTestimonialCard(
                  name: 'Mike Chen',
                  role: 'Tech Gadgets Seller',
                  content: 'The templates are stunning and the analytics help me make better decisions. Customer support is always there when I need them.',
                  avatar: 'MC',
                  rating: 5,
                ),
                const SizedBox(width: 40),
                _buildTestimonialCard(
                  name: 'Emma Davis',
                  role: 'Handmade Crafts',
                  content: 'I love how professional my store looks. PopStore made it so easy to showcase my handmade items and reach more customers.',
                  avatar: 'ED',
                  rating: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard({
    required String name,
    required String role,
    required String content,
    required String avatar,
    required int rating,
  }) {
    return Container(
      width: _isMobile ? MediaQuery.of(context).size.width * 0.9 : 350,
      padding: EdgeInsets.all(_isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(
              rating,
              (index) => const Icon(
                Icons.star,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '"$content"',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: _isMobile ? 14 : 16,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _isMobile ? 40 : 50,
                height: _isMobile ? 40 : 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    avatar,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: _isMobile ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      key: _pricingKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _isMobile ? 16 : 24, vertical: _isMobile ? 40 : 80),
        child: Column(
          children: [
            Text(
              'Simple, Transparent Pricing',
              style: TextStyle(
                fontSize: _isMobile ? 32 : 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Choose the perfect plan for your business needs',
              style: TextStyle(
                fontSize: _isMobile ? 16 : 20,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _isMobile ? 40 : 80),
            _isMobile ? Column(
              children: [
                _buildPricingCard(
                  title: 'Starter',
                  price: '\$29',
                  period: '/month',
                  features: [
                    'Up to 100 products',
                    'Basic templates',
                    'Email support',
                    'Basic analytics',
                    'Mobile responsive',
                  ],
                  gradient: const [Color(0xFF6B7280), Color(0xFF9CA3AF)],
                  isPopular: false,
                ),
                const SizedBox(height: 20),
                _buildPricingCard(
                  title: 'Professional',
                  price: '\$79',
                  period: '/month',
                  features: [
                    'Unlimited products',
                    'Premium templates',
                    'Priority support',
                    'Advanced analytics',
                    'Custom domain',
                    'Payment integration',
                  ],
                  gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  isPopular: true,
                ),
                const SizedBox(height: 20),
                _buildPricingCard(
                  title: 'Enterprise',
                  price: '\$199',
                  period: '/month',
                  features: [
                    'Everything in Professional',
                    'White-label solution',
                    'API access',
                    'Dedicated manager',
                    'Custom integrations',
                    'Advanced security',
                  ],
                  gradient: const [Color(0xFF10B981), Color(0xFF06B6D4)],
                  isPopular: false,
                ),
              ],
            ) : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPricingCard(
                    title: 'Starter',
                    price: '\$29',
                    period: '/month',
                    features: [
                      'Up to 100 products',
                      'Basic templates',
                      'Email support',
                      'Basic analytics',
                      'Mobile responsive',
                    ],
                    gradient: const [Color(0xFF6B7280), Color(0xFF9CA3AF)],
                    isPopular: false,
                  ),
                  const SizedBox(width: 40),
                  _buildPricingCard(
                    title: 'Professional',
                    price: '\$79',
                    period: '/month',
                    features: [
                      'Unlimited products',
                      'Premium templates',
                      'Priority support',
                      'Advanced analytics',
                      'Custom domain',
                      'Payment integration',
                    ],
                    gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    isPopular: true,
                  ),
                  const SizedBox(width: 40),
                  _buildPricingCard(
                    title: 'Enterprise',
                    price: '\$199',
                    period: '/month',
                    features: [
                      'Everything in Professional',
                      'White-label solution',
                      'API access',
                      'Dedicated manager',
                      'Custom integrations',
                      'Advanced security',
                    ],
                    gradient: const [Color(0xFF10B981), Color(0xFF06B6D4)],
                    isPopular: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required List<Color> gradient,
    required bool isPopular,
  }) {
    return Container(
      width: _isMobile ? MediaQuery.of(context).size.width * 0.9 : 350,
      padding: EdgeInsets.all(_isMobile ? 20 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.map((color) => color.withOpacity(0.1)).toList(),
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular ? gradient[0].withOpacity(0.3) : Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Most Popular',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: _isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _isMobile ? 40 : 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                period,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: _isMobile ? 16 : 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: gradient[0],
                  size: _isMobile ? 18 : 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: _isMobile ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: _isMobile ? 14 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _isMobile ? 16 : 24, vertical: _isMobile ? 40 : 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF6366F1).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(_isMobile ? 32 : 64),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Text(
              'Ready to Start Your Success Story?',
              style: TextStyle(
                fontSize: _isMobile ? 32 : 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Join thousands of successful sellers who have transformed their businesses with PopStore',
              style: TextStyle(
                fontSize: _isMobile ? 16 : 20,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _isMobile ? Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.rocket_launch, size: 24),
                    label: const Text(
                      'Create Your Store Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, '/signup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ) : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.rocket_launch, size: 24),
                      label: const Text(
                        'Create Your Store Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(_isMobile ? 24 : 48),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          _isMobile ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFooterBrand(),
              const SizedBox(height: 32),
              _buildFooterLinks(),
            ],
          ) : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: _buildFooterBrand(),
                ),
                const SizedBox(width: 80),
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: _buildFooterSection('Product', [
                    'Templates',
                    'Features',
                    'Pricing',
                    'Integrations',
                  ]),
                ),
                const SizedBox(width: 40),
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: _buildFooterSection('Support', [
                    'Help Center',
                    'Contact Us',
                    'Status',
                    'API Docs',
                  ]),
                ),
                const SizedBox(width: 40),
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: _buildFooterSection('Company', [
                    'About Us',
                    'Careers',
                    'Blog',
                    'Press',
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          _isMobile ? Column(
            children: [
              Text(
                '© 2025 PopStore. All rights reserved.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 8,
                children: [
                  _buildFooterLink('Privacy Policy'),
                  _buildFooterLink('Terms of Service'),
                  _buildFooterLink('Cookie Policy'),
                ],
              ),
            ],
          ) : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '© 2025 PopStore. All rights reserved.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    _buildFooterLink('Privacy Policy'),
                    const SizedBox(width: 24),
                    _buildFooterLink('Terms of Service'),
                    const SizedBox(width: 24),
                    _buildFooterLink('Cookie Policy'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.storefront,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'PopStore',
              style: TextStyle(
                color: Colors.white,
                fontSize: _isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'The #1 platform for creating stunning ecommerce websites instantly. No coding required.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: _isMobile ? 14 : 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildSocialIcon(Icons.facebook),
            const SizedBox(width: 16),
            _buildSocialIcon(Icons.camera_alt), // Instagram
            const SizedBox(width: 16),
            _buildSocialIcon(Icons.business), // LinkedIn
            const SizedBox(width: 16),
            _buildSocialIcon(Icons.chat), // Twitter
          ],
        ),
      ],
    );
  }

  Widget _buildFooterSection(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: _isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => _buildFooterLink(link)),
      ],
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFooterSection('Product', [
                'Features',
                'Pricing',
                'Integrations',
              ]),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: _buildFooterSection('Company', [
                'About Us',
              ]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: Colors.white.withOpacity(0.8),
        size: 20,
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {
        if (text == 'Features') {
          _scrollToSection(_featuresKey);
        } else if (text == 'Pricing') {
          _scrollToSection(_pricingKey);
        } else if (text == 'About Us') {
          Navigator.pushNamed(context, '/about');
        }
        // For others, do nothing or add more cases
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
