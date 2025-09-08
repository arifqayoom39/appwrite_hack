import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';

class AboutUsScreen extends ConsumerStatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends ConsumerState<AboutUsScreen>
    with TickerProviderStateMixin {
  // Appwrite theme colors
  static const Color appwritePink = Color(0xFFFD366E);
  static const Color appwriteBlack = Color(0xFF000000);
  static const Color appwriteDarkGray = Color(0xFF0F0F0F);
  static const Color appwriteBorder = Color(0xFF1A1A1A);
  static const Color appwriteGreen = Color(0xFF4CAF50);

  late AnimationController _heroAnimationController;
  late Animation<double> _heroFadeAnimation;
  late AnimationController _aboutAnimationController;
  late Animation<double> _aboutSlideAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();

    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _aboutAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroAnimationController, curve: Curves.easeOut),
    );
    _aboutSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _aboutAnimationController, curve: Curves.easeOut),
    );

    _heroAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _aboutAnimationController.forward();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _aboutAnimationController.dispose();
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
              _buildStorySection(),
              _buildMissionSection(),
              _buildTeamSection(),
              _buildValuesSection(),
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
                    Icons.business,
                    color: appwritePink,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'About StorePe',
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
              'Empowering Entrepreneurs\nWorldwide',
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
                'We believe everyone should have the tools to turn their ideas into successful online businesses. Our mission is to democratize ecommerce.',
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

  Widget _buildStorySection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 80,
        vertical: _isMobile ? 60 : 100,
      ),
      child: AnimatedBuilder(
        animation: _aboutSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _aboutSlideAnimation.value),
            child: _isMobile
                ? Column(
                    children: [
                      Container(
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
                              child: const Icon(
                                Icons.history,
                                color: appwritePink,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Our Story',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'StorePe was born from the frustration of our founders with the complexity and high costs associated with traditional ecommerce platforms. We saw an opportunity to create a solution that combines cutting-edge technology with intuitive design.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: appwritePink.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.history,
                                      color: appwritePink,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Our Story',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'StorePe was born from the frustration of our founders with the complexity and high costs associated with traditional ecommerce platforms. We saw an opportunity to create a solution that combines cutting-edge technology with intuitive design, making it possible for small businesses, entrepreneurs, and creators to launch professional online stores in minutes.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.9),
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
                          child: const Center(
                            child: Icon(
                              Icons.timeline,
                              color: appwritePink,
                              size: 80,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildMissionSection() {
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
            'Our Mission',
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
                    _buildMissionCard(
                      icon: Icons.rocket_launch,
                      title: 'Innovation First',
                      description: 'We constantly push the boundaries of what\'s possible in ecommerce technology.',
                    ),
                    const SizedBox(height: 24),
                    _buildMissionCard(
                      icon: Icons.people,
                      title: 'People Centered',
                      description: 'Every decision we make puts our users and their success first.',
                    ),
                    const SizedBox(height: 24),
                    _buildMissionCard(
                      icon: Icons.public,
                      title: 'Global Impact',
                      description: 'We\'re helping entrepreneurs worldwide achieve their dreams.',
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildMissionCard(
                        icon: Icons.rocket_launch,
                        title: 'Innovation First',
                        description: 'We constantly push the boundaries of what\'s possible in ecommerce technology.',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildMissionCard(
                        icon: Icons.people,
                        title: 'People Centered',
                        description: 'Every decision we make puts our users and their success first.',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildMissionCard(
                        icon: Icons.public,
                        title: 'Global Impact',
                        description: 'We\'re helping entrepreneurs worldwide achieve their dreams.',
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildMissionCard({
    required IconData icon,
    required String title,
    required String description,
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
              fontSize: 20,
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
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 80,
        vertical: _isMobile ? 60 : 100,
      ),
      child: Column(
        children: [
          Text(
            'Meet the Team',
            style: TextStyle(
              fontSize: _isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Container(
                  width: _isMobile ? 120 : 150,
                  height: _isMobile ? 120 : 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: appwritePink,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: appwritePink.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/developer.jpeg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: appwritePink.withOpacity(0.2),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 60,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Arif Qayoom',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Founder & Lead Developer',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  constraints: BoxConstraints(maxWidth: _isMobile ? double.infinity : 600),
                  child: Text(
                    'Passionate about creating innovative solutions and empowering entrepreneurs through technology. Built StorePe to democratize ecommerce and make online business creation accessible to everyone.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuesSection() {
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
            'Our Values',
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
                    _buildValueItem(
                      number: '01',
                      title: 'Innovation',
                      description: 'We embrace cutting-edge technology to solve real problems.',
                    ),
                    const SizedBox(height: 32),
                    _buildValueItem(
                      number: '02',
                      title: 'Simplicity',
                      description: 'We believe complex technology should be simple to use.',
                    ),
                    const SizedBox(height: 32),
                    _buildValueItem(
                      number: '03',
                      title: 'Empowerment',
                      description: 'We give entrepreneurs the tools they need to succeed.',
                    ),
                    const SizedBox(height: 32),
                    _buildValueItem(
                      number: '04',
                      title: 'Community',
                      description: 'We build together and support each other\'s success.',
                    ),
                  ],
                )
              : GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 32,
                  crossAxisSpacing: 32,
                  childAspectRatio: 1.5,
                  children: [
                    _buildValueItem(
                      number: '01',
                      title: 'Innovation',
                      description: 'We embrace cutting-edge technology to solve real problems.',
                    ),
                    _buildValueItem(
                      number: '02',
                      title: 'Simplicity',
                      description: 'We believe complex technology should be simple to use.',
                    ),
                    _buildValueItem(
                      number: '03',
                      title: 'Empowerment',
                      description: 'We give entrepreneurs the tools they need to succeed.',
                    ),
                    _buildValueItem(
                      number: '04',
                      title: 'Community',
                      description: 'We build together and support each other\'s success.',
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildValueItem({
    required String number,
    required String title,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: appwritePink,
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
              'Join Our Mission',
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
                'Be part of the revolution in ecommerce. Start building your dream online store today.',
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
                  'Get Started Today',
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