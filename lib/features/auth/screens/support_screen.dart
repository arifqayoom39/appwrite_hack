import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen>
    with TickerProviderStateMixin {
  // Appwrite theme colors
  static const Color appwritePink = Color(0xFFFD366E);
  static const Color appwriteBlack = Color(0xFF000000);
  static const Color appwriteDarkGray = Color(0xFF0F0F0F);
  static const Color appwriteBorder = Color(0xFF1A1A1A);

  late AnimationController _heroAnimationController;
  late Animation<double> _heroFadeAnimation;
  late AnimationController _supportAnimationController;
  late Animation<double> _supportSlideAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();

    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _supportAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroAnimationController, curve: Curves.easeOut),
    );
    _supportSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _supportAnimationController, curve: Curves.easeOut),
    );

    _heroAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _supportAnimationController.forward();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _supportAnimationController.dispose();
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
              _buildSupportOptions(),
              _buildHelpCenter(),
              _buildContactSection(),
              _buildStatusSection(),
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
                    Icons.support_agent,
                    color: appwritePink,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '24/7 Support',
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
              'How Can We Help?',
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
                'Get the help you need, when you need it. Our support team is here to ensure your success with StorePe.',
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

  Widget _buildSupportOptions() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 80,
        vertical: _isMobile ? 60 : 100,
      ),
      child: AnimatedBuilder(
        animation: _supportSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _supportSlideAnimation.value),
            child: Column(
              children: [
                Text(
                  'Support Options',
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
                    'Choose the support option that works best for you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _isMobile ? 16 : 18,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                _isMobile
                    ? Column(
                        children: [
                          _buildSupportCard(
                            icon: Icons.chat,
                            title: 'Live Chat',
                            description: 'Get instant help from our support team',
                            availability: '24/7',
                            responseTime: 'Instant',
                          ),
                          const SizedBox(height: 24),
                          _buildSupportCard(
                            icon: Icons.email,
                            title: 'Email Support',
                            description: 'Send us a detailed message about your issue',
                            availability: '24/7',
                            responseTime: '< 2 hours',
                          ),
                          const SizedBox(height: 24),
                          _buildSupportCard(
                            icon: Icons.phone,
                            title: 'Phone Support',
                            description: 'Speak directly with our experts',
                            availability: 'Mon-Fri 9AM-6PM',
                            responseTime: 'Immediate',
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildSupportCard(
                              icon: Icons.chat,
                              title: 'Live Chat',
                              description: 'Get instant help from our support team',
                              availability: '24/7',
                              responseTime: 'Instant',
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildSupportCard(
                              icon: Icons.email,
                              title: 'Email Support',
                              description: 'Send us a detailed message about your issue',
                              availability: '24/7',
                              responseTime: '< 2 hours',
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildSupportCard(
                              icon: Icons.phone,
                              title: 'Phone Support',
                              description: 'Speak directly with our experts',
                              availability: 'Mon-Fri 9AM-6PM',
                              responseTime: 'Immediate',
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

  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String description,
    required String availability,
    required String responseTime,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: appwriteDarkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appwriteBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appwritePink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: appwritePink,
              size: 32,
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
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: appwritePink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              availability,
              style: TextStyle(
                fontSize: 12,
                color: appwritePink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Response: $responseTime',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [appwritePink, Color(0xFFE91E63)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                // Handle support action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                title == 'Live Chat' ? 'Start Chat' :
                title == 'Email Support' ? 'Send Email' : 'Call Now',
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

  Widget _buildHelpCenter() {
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
            'Help Center',
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
                    _buildHelpCategory(
                      icon: Icons.store,
                      title: 'Getting Started',
                      description: 'Learn the basics of setting up your store',
                      articles: ['Create your first store', 'Add products', 'Customize design'],
                    ),
                    const SizedBox(height: 24),
                    _buildHelpCategory(
                      icon: Icons.payment,
                      title: 'Payments & Billing',
                      description: 'Everything about payments and subscriptions',
                      articles: ['Payment methods', 'Billing FAQ', 'Refunds'],
                    ),
                    const SizedBox(height: 24),
                    _buildHelpCategory(
                      icon: Icons.analytics,
                      title: 'Analytics & Reports',
                      description: 'Understand your store performance',
                      articles: ['View analytics', 'Generate reports', 'Track sales'],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildHelpCategory(
                        icon: Icons.store,
                        title: 'Getting Started',
                        description: 'Learn the basics of setting up your store',
                        articles: ['Create your first store', 'Add products', 'Customize design'],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildHelpCategory(
                        icon: Icons.payment,
                        title: 'Payments & Billing',
                        description: 'Everything about payments and subscriptions',
                        articles: ['Payment methods', 'Billing FAQ', 'Refunds'],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildHelpCategory(
                        icon: Icons.analytics,
                        title: 'Analytics & Reports',
                        description: 'Understand your store performance',
                        articles: ['View analytics', 'Generate reports', 'Track sales'],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildHelpCategory({
    required IconData icon,
    required String title,
    required String description,
    required List<String> articles,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: appwriteDarkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appwriteBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              size: 24,
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
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: articles.map((article) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_right,
                    color: appwritePink,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      article,
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
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: Text(
              'View all articles',
              style: TextStyle(
                color: appwritePink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 80,
        vertical: _isMobile ? 60 : 100,
      ),
      child: Column(
        children: [
          Text(
            'Contact Information',
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
                    _buildContactItem(
                      icon: Icons.email,
                      title: 'Email',
                      value: 'support@storepe.com',
                      description: 'Send us an email anytime',
                    ),
                    const SizedBox(height: 24),
                    _buildContactItem(
                      icon: Icons.phone,
                      title: 'Phone',
                      value: '+1 (555) 123-4567',
                      description: 'Mon-Fri 9AM-6PM EST',
                    ),
                    const SizedBox(height: 24),
                    _buildContactItem(
                      icon: Icons.chat,
                      title: 'Live Chat',
                      value: 'Available 24/7',
                      description: 'Get instant help',
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildContactItem(
                        icon: Icons.email,
                        title: 'Email',
                        value: 'support@storepe.com',
                        description: 'Send us an email anytime',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildContactItem(
                        icon: Icons.phone,
                        title: 'Phone',
                        value: '+1 (555) 123-4567',
                        description: 'Mon-Fri 9AM-6PM EST',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildContactItem(
                        icon: Icons.chat,
                        title: 'Live Chat',
                        value: 'Available 24/7',
                        description: 'Get instant help',
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: appwriteDarkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appwriteBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appwritePink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: appwritePink,
              size: 32,
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
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: appwritePink,
              fontWeight: FontWeight.w500,
            ),
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
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
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
            'System Status',
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
              'Check the current status of our services and systems.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _isMobile ? 16 : 18,
                color: Colors.white.withOpacity(0.7),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: appwriteDarkGray,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: appwriteBorder,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'All Systems Operational',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Last updated: September 7, 2025 at 10:30 AM EST',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View detailed status page',
                    style: TextStyle(
                      color: appwritePink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
