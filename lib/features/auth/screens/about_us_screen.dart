import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with TickerProviderStateMixin {
  // Appwrite theme colors
  static const Color appwritePink = Color(0xFFFD366E);
  static const Color appwritePurple = Color(0xFF8B5CF6);
  static const Color appwriteBlue = Color(0xFF3B82F6);

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  late AnimationController _heroController;
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeInOut),
    );

    _heroSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroController, curve: Curves.elasticOut));

    _heroController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _isScrolled = _scrollController.offset > 50;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF334155),
                  Color(0xFF475569),
                  Color(0xFF0F172A),
                ],
                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),

          // Website Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: _isScrolled ? const Color(0xFF0F172A).withOpacity(0.95) : Colors.transparent,
                border: _isScrolled ? Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ) : null,
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    // Logo
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [appwritePink, appwritePurple],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.store,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: const Text(
                                'PopStore',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Navigation Links
                    if (isDesktop) ...[
                      _buildNavLink('Home'),
                      _buildNavLink('Features'),
                      _buildNavLink('About'),
                      _buildNavLink('Contact'),
                      const SizedBox(width: 32),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appwritePink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Get Started'),
                        ),
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Positioned.fill(
            top: 80,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Hero Section - Flexible height
                        Flexible(
                          flex: 1,
                          fit: FlexFit.loose,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: isDesktop ? 500 : 400,
                              maxHeight: isDesktop ? 700 : 600,
                            ),
                            child: _buildHeroSection(isDesktop),
                          ),
                        ),

                        // Stats Section
                        _buildStatsSection(isDesktop),

                        // Our Story Section
                        _buildStorySection(isDesktop),

                        // Features Section
                        _buildFeaturesSection(isDesktop),

                        // Vision Section
                        _buildVisionSection(isDesktop),

                        // Team Section
                        _buildTeamSection(isDesktop),

                        // CTA Section
                        _buildCTASection(isDesktop),

                        // Footer
                        _buildFooter(isDesktop),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;

        // Calculate responsive dimensions
        final iconSize = isDesktop ? 80.0 : (availableWidth * 0.15).clamp(60.0, 80.0);
        final titleFontSize = isDesktop ? 48.0 : (availableWidth * 0.08).clamp(24.0, 32.0);
        final subtitleFontSize = isDesktop ? 20.0 : (availableWidth * 0.045).clamp(14.0, 16.0);
        final buttonFontSize = isDesktop ? 16.0 : (availableWidth * 0.04).clamp(14.0, 16.0);

        // Calculate minimum required height for content
        final minContentHeight = iconSize + 24 + // icon + padding
                               titleFontSize * 2 + 24 + // title lines + spacing
                               subtitleFontSize * 2 + 40 + // subtitle lines + spacing
                               80; // buttons + spacing

        return AnimatedBuilder(
          animation: _heroController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _heroFadeAnimation,
              child: SlideTransition(
                position: _heroSlideAnimation,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: minContentHeight,
                    maxHeight: availableHeight > minContentHeight ? availableHeight : minContentHeight,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 80 : 24,
                    vertical: isDesktop ? 40 : 20,
                  ),
                  child: SingleChildScrollView(
                    physics: availableHeight >= minContentHeight
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: availableHeight >= minContentHeight ? availableHeight : minContentHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(isDesktop ? 24 : 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [appwritePink, appwritePurple],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: appwritePink.withOpacity(0.3),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.business_center,
                              color: Colors.white,
                              size: iconSize,
                            ),
                          ),
                          SizedBox(height: isDesktop ? 32 : 24),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Empowering Entrepreneurs Worldwide',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: appwritePink.withOpacity(0.5),
                                    blurRadius: 15,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: isDesktop ? 24 : 16),
                          Text(
                            'Building the future of ecommerce with innovation and simplicity',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isDesktop ? 40 : 32),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              SizedBox(
                                width: isDesktop ? 200 : (availableWidth * 0.8).clamp(200.0, double.infinity),
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appwritePink,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 24 : 20,
                                      vertical: isDesktop ? 16 : 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 8,
                                  ),
                                  child: Text(
                                    'Start Your Journey',
                                    style: TextStyle(
                                      fontSize: buttonFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: isDesktop ? 200 : (availableWidth * 0.8).clamp(200.0, double.infinity),
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white, width: 2),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 24 : 20,
                                      vertical: isDesktop ? 16 : 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Learn More',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: buttonFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsSection(bool isDesktop) {
    final stats = [
      {'number': '10K+', 'label': 'Active Stores'},
      {'number': '500K+', 'label': 'Happy Customers'},
      {'number': '99.9%', 'label': 'Uptime'},
      {'number': '24/7', 'label': 'Support'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: 60,
      ),
      child: Column(
        children: [
          Text(
            'Trusted by Entrepreneurs Worldwide',
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands of successful businesses already using PopStore',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 20,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: stats.map((stat) => Container(
              width: isDesktop ? null : 120,
              constraints: BoxConstraints(
                minWidth: isDesktop ? 150 : 100,
                maxWidth: isDesktop ? 200 : 120,
              ),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      stat['number']!,
                      style: TextStyle(
                        fontSize: isDesktop ? 48 : 32,
                        fontWeight: FontWeight.bold,
                        color: appwritePink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stat['label']!,
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: 80,
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [appwritePink, appwritePurple],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.history,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
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
                          'PopStore was born from the frustration of our founders with the complexity and high costs associated with traditional ecommerce platforms. We saw an opportunity to create a solution that combines cutting-edge technology with intuitive design, making it possible for small businesses, entrepreneurs, and creators to launch professional online stores in minutes.',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
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
                    height: 400,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [appwritePink, appwritePurple],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: appwritePink.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.timeline,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [appwritePink, appwritePurple],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.history,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Our Story',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'PopStore was born from the frustration of our founders with the complexity and high costs associated with traditional ecommerce platforms. We saw an opportunity to create a solution that combines cutting-edge technology with intuitive design, making it possible for small businesses, entrepreneurs, and creators to launch professional online stores in minutes.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFeaturesSection(bool isDesktop) {
    final features = [
      {
        'icon': Icons.auto_awesome,
        'title': 'AI-Powered Design',
        'description': 'Our intelligent system creates beautiful, conversion-optimized stores automatically.',
      },
      {
        'icon': Icons.phone_android,
        'title': 'Mobile-First Approach',
        'description': 'Every store is optimized for all devices, ensuring your customers have a seamless experience.',
      },
      {
        'icon': Icons.edit,
        'title': 'No Coding Required',
        'description': 'Build professional stores with our drag-and-drop interface.',
      },
      {
        'icon': Icons.payment,
        'title': 'Integrated Payments',
        'description': 'Accept payments worldwide with our secure, built-in payment processing.',
      },
      {
        'icon': Icons.support_agent,
        'title': '24/7 Support',
        'description': 'Our expert team is always here to help you succeed.',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'What Sets Us Apart',
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Powerful features designed to help you succeed',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: features.map((feature) => Container(
              width: isDesktop ? 350 : double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [appwritePink, appwriteBlue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    feature['title'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feature['description'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVisionSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: 80,
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [appwritePurple, appwriteBlue],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: appwritePurple.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 60),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [appwritePurple, appwriteBlue],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Our Vision',
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
                          'We envision a world where anyone with a great idea can easily turn it into a thriving online business. By removing technical barriers and providing affordable, powerful tools, we\'re helping millions of entrepreneurs around the globe achieve their dreams.',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [appwritePurple, appwriteBlue],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Our Vision',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'We envision a world where anyone with a great idea can easily turn it into a thriving online business. By removing technical barriers and providing affordable, powerful tools, we\'re helping millions of entrepreneurs around the globe achieve their dreams.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTeamSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Meet the Developer',
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
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
                  width: isDesktop ? 150 : 120,
                  height: isDesktop ? 150 : 120,
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
                          color: appwritePurple.withOpacity(0.2),
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
                  'Full-Stack Developer & Flutter Enthusiast',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
                  child: Text(
                    'Passionate about creating innovative solutions and empowering entrepreneurs through technology. Built PopStore to democratize ecommerce and make online business creation accessible to everyone.',
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

  Widget _buildCTASection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: 80,
      ),
      child: Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [appwritePink, appwritePurple, appwriteBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: appwritePink.withOpacity(0.3),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Ready to Start Your Journey?',
              style: TextStyle(
                fontSize: isDesktop ? 40 : 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Join thousands of entrepreneurs who have already built their dream online stores with PopStore.',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 300 : double.infinity,
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: appwritePink,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.3),
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: const Text(
                  'Get Started Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.8),
        border: const Border(
          top: BorderSide(
            color: Colors.white10,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              // Logo and description
              Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 400 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [appwritePink, appwritePurple],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.store,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'PopStore',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Empowering entrepreneurs worldwide with innovative ecommerce solutions.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                    ),
                  ],
                ),
              ),

              if (isDesktop) ...[
                // Quick Links
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Links',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFooterLink('Home'),
                      _buildFooterLink('Features'),
                      _buildFooterLink('About'),
                      _buildFooterLink('Contact'),
                    ],
                  ),
                ),

                // Contact
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFooterLink('arif*****@gmail.com'),
                      _buildFooterLink('+91 600******81'),
                    ],
                  ),
                ),
              ] else ...[
                // Mobile footer links
                Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      const Text(
                        'Quick Links',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 20,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildFooterLink('Home'),
                          _buildFooterLink('Features'),
                          _buildFooterLink('About'),
                          _buildFooterLink('Contact'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Contact',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFooterLink('support@popstore.com'),
                      _buildFooterLink('+1 (555) 123-4567'),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 32),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),

          // Copyright
          Text(
            '© 2025 PopStore. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
        ),
      ),
    );
  }
    }