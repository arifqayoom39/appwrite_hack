import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen>
    with TickerProviderStateMixin {
  // Appwrite theme colors
  static const Color appwritePink = Color(0xFFFD366E);
  static const Color appwriteBlack = Color(0xFF000000);
  static const Color appwriteDarkGray = Color(0xFF0F0F0F);
  static const Color appwriteBorder = Color(0xFF1A1A1A);

  late AnimationController _heroAnimationController;
  late Animation<double> _heroFadeAnimation;
  late AnimationController _pricingAnimationController;
  late Animation<double> _pricingSlideAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();

    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pricingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroAnimationController, curve: Curves.easeOut),
    );
    _pricingSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _pricingAnimationController, curve: Curves.easeOut),
    );

    _heroAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _pricingAnimationController.forward();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _pricingAnimationController.dispose();
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
              _buildPricingSection(),
              _buildComparisonSection(),
              _buildFAQSection(),
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
                    Icons.attach_money,
                    color: appwritePink,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Simple Pricing',
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
              'Choose Your Plan',
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
                'Start free and scale as you grow. All plans include our core features with no hidden fees.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _isMobile ? 18 : 20,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 80,
        vertical: _isMobile ? 60 : 100,
      ),
      child: AnimatedBuilder(
        animation: _pricingSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _pricingSlideAnimation.value),
            child: Column(
              children: [
                _isMobile
                    ? Column(
                        children: [
                          _buildPricingCard(
                            title: 'Free',
                            price: '\$0',
                            period: 'forever',
                            description: 'Perfect for getting started',
                            features: [
                              'Up to 10 products',
                              'Basic store customization',
                              'Email support',
                              'StorePe branding',
                            ],
                            isPopular: false,
                            buttonText: 'Get Started',
                          ),
                          const SizedBox(height: 24),
                          _buildPricingCard(
                            title: 'Pro',
                            price: '\$29',
                            period: 'per month',
                            description: 'For growing businesses',
                            features: [
                              'Unlimited products',
                              'Advanced customization',
                              'Priority support',
                              'Remove StorePe branding',
                              'Analytics dashboard',
                              'Custom domain',
                            ],
                            isPopular: true,
                            buttonText: 'Start Free Trial',
                          ),
                          const SizedBox(height: 24),
                          _buildPricingCard(
                            title: 'Enterprise',
                            price: 'Custom',
                            period: 'pricing',
                            description: 'For large businesses',
                            features: [
                              'Everything in Pro',
                              'Advanced analytics',
                              'API access',
                              'Dedicated support',
                              'Custom integrations',
                              'SLA guarantee',
                            ],
                            isPopular: false,
                            buttonText: 'Contact Sales',
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildPricingCard(
                              title: 'Free',
                              price: '\$0',
                              period: 'forever',
                              description: 'Perfect for getting started',
                              features: [
                                'Up to 10 products',
                                'Basic store customization',
                                'Email support',
                                'StorePe branding',
                              ],
                              isPopular: false,
                              buttonText: 'Get Started',
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: _buildPricingCard(
                              title: 'Pro',
                              price: '\$29',
                              period: 'per month',
                              description: 'For growing businesses',
                              features: [
                                'Unlimited products',
                                'Advanced customization',
                                'Priority support',
                                'Remove StorePe branding',
                                'Analytics dashboard',
                                'Custom domain',
                              ],
                              isPopular: true,
                              buttonText: 'Start Free Trial',
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: _buildPricingCard(
                              title: 'Enterprise',
                              price: 'Custom',
                              period: 'pricing',
                              description: 'For large businesses',
                              features: [
                                'Everything in Pro',
                                'Advanced analytics',
                                'API access',
                                'Dedicated support',
                                'Custom integrations',
                                'SLA guarantee',
                              ],
                              isPopular: false,
                              buttonText: 'Contact Sales',
                            ),
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

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    required String description,
    required List<String> features,
    required bool isPopular,
    required String buttonText,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isPopular ? appwriteDarkGray : appwriteDarkGray.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? appwritePink : appwriteBorder,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: appwritePink.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: appwritePink,
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isPopular ? appwritePink : Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                period,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Column(
            children: features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: appwritePink,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: isPopular
                  ? const LinearGradient(
                      colors: [appwritePink, Color(0xFFE91E63)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(8),
              border: !isPopular
                  ? Border.all(
                      color: appwriteBorder,
                      width: 1,
                    )
                  : null,
            ),
            child: ElevatedButton(
              onPressed: () {
                if (buttonText == 'Contact Sales') {
                  // Handle contact sales
                } else {
                  context.go('/signup');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? Colors.transparent : appwriteDarkGray,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection() {
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
            'Why Choose StorePe?',
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
                    _buildComparisonItem(
                      icon: Icons.speed,
                      title: '5-Minute Setup',
                      description: 'Launch your store faster than traditional platforms.',
                    ),
                    const SizedBox(height: 32),
                    _buildComparisonItem(
                      icon: Icons.attach_money,
                      title: 'No Hidden Fees',
                      description: 'Transparent pricing with no surprise charges.',
                    ),
                    const SizedBox(height: 32),
                    _buildComparisonItem(
                      icon: Icons.support,
                      title: '24/7 Support',
                      description: 'Get help whenever you need it from our expert team.',
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildComparisonItem(
                        icon: Icons.speed,
                        title: '5-Minute Setup',
                        description: 'Launch your store faster than traditional platforms.',
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: _buildComparisonItem(
                        icon: Icons.attach_money,
                        title: 'No Hidden Fees',
                        description: 'Transparent pricing with no surprise charges.',
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: _buildComparisonItem(
                        icon: Icons.support,
                        title: '24/7 Support',
                        description: 'Get help whenever you need it from our expert team.',
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: appwritePink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: appwritePink,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFAQSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 80,
        vertical: _isMobile ? 60 : 100,
      ),
      child: Column(
        children: [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: _isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          _buildFAQItem(
            question: 'Can I change plans anytime?',
            answer: 'Yes, you can upgrade or downgrade your plan at any time. Changes take effect immediately.',
          ),
          const SizedBox(height: 24),
          _buildFAQItem(
            question: 'Is there a free trial?',
            answer: 'Yes, our Pro plan comes with a 14-day free trial. No credit card required to start.',
          ),
          const SizedBox(height: 24),
          _buildFAQItem(
            question: 'What payment methods do you accept?',
            answer: 'We accept all major credit cards, PayPal, and bank transfers for Enterprise plans.',
          ),
          const SizedBox(height: 24),
          _buildFAQItem(
            question: 'Can I cancel anytime?',
            answer: 'Yes, you can cancel your subscription at any time. No cancellation fees or penalties.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: appwriteDarkGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appwriteBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            answer,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
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
              'Ready to Get Started?',
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
                'Join thousands of businesses already using StorePe. Start your free trial today.',
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
                  'Start Free Trial',
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
