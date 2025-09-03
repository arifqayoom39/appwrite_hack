import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LandingStorePreview extends StatefulWidget {
  const LandingStorePreview({Key? key}) : super(key: key);

  @override
  State<LandingStorePreview> createState() => _LandingStorePreviewState();
}

class _LandingStorePreviewState extends State<LandingStorePreview>
    with TickerProviderStateMixin {
  AnimationController? _previewController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  int _currentPreviewIndex = 0;

  final List<Map<String, dynamic>> _previewProducts = [
    {
      'name': 'Wireless Headphones',
      'price': '\$299',
      'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300&h=300&fit=crop&crop=center',
      'category': 'Electronics',
      'rating': 4.8,
    },
    {
      'name': 'Smart Watch',
      'price': '\$199',
      'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=300&h=300&fit=crop&crop=center',
      'category': 'Wearables',
      'rating': 4.9,
    },
    {
      'name': 'Appwrite KeyBoard',
      'price': '\$450',
      'image': 'https://th.bing.com/th/id/R.c7295c9d24db9945dd85adbf10706b0f?rik=e5LFfekm4Bxgjg&riu=http%3a%2f%2fappwrite.store%2fcdn%2fshop%2ffiles%2fAppwriter.png%3fv%3d1720101767&ehk=XRO3ETbMzb0PkhQruuBPH%2brbiYV1EhqUvgBQRUnV4Ac%3d&risl=&pid=ImgRaw&r=0',
      'category': 'Gaming',
      'rating': 4.7,
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animations immediately for better performance
    if (kReleaseMode) {
      _previewController = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _previewController!, curve: Curves.easeInOut),
      );

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _previewController!, curve: Curves.elasticOut));

      // Defer controller start to improve initial load performance
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _previewController?.forward();
        // Auto-rotate through products with longer intervals to reduce CPU usage
        Future.delayed(const Duration(seconds: 4), _rotatePreview);
      });
    } else {
      // In debug mode, use static animations for better performance
      _fadeAnimation = AlwaysStoppedAnimation(1.0);
      _slideAnimation = AlwaysStoppedAnimation(Offset.zero);
    }
  }

  @override
  void dispose() {
    _previewController?.dispose();
    super.dispose();
  }

  void _rotatePreview() {
    if (mounted) {
      setState(() {
        _currentPreviewIndex = (_currentPreviewIndex + 1) % _previewProducts.length;
      });
      Future.delayed(const Duration(seconds: 3), _rotatePreview);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentProduct = _previewProducts[_currentPreviewIndex];
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final mainImageSize = isDesktop ? 120.0 : 80.0;
    final thumbnailSize = isDesktop ? 60.0 : 40.0;

    return AnimatedBuilder(
      animation: _previewController ?? AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation ?? AlwaysStoppedAnimation(1.0),
          child: SlideTransition(
            position: _slideAnimation ?? AlwaysStoppedAnimation(Offset.zero),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF334155),
                    Color(0xFF475569),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFD366E).withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.05,
                        child: CustomPaint(
                          painter: StorePatternPainter(),
                        ),
                      ),
                    ),

                    // Mock browser chrome
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F172A),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'yourstore.com',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),

                    // Store content
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFD366E), Color(0xFF8B5CF6)],
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'PopStore',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    '4.9★',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Products grid
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Featured Products',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isDesktop ? 18 : 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        // Current featured product
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.2),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    currentProduct['image'],
                                                    width: mainImageSize,
                                                    height: mainImageSize,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return Container(
                                                        width: mainImageSize,
                                                        height: mainImageSize,
                                                        color: Colors.white.withOpacity(0.1),
                                                        child: Center(
                                                          child: SizedBox(
                                                            width: isDesktop ? 30 : 20,
                                                            height: isDesktop ? 30 : 20,
                                                            child: const CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFD366E)),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        width: mainImageSize,
                                                        height: mainImageSize,
                                                        color: Colors.white.withOpacity(0.1),
                                                        child: Icon(
                                                          Icons.image,
                                                          color: Colors.white54,
                                                          size: isDesktop ? 40 : 30,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  currentProduct['name'],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: isDesktop ? 14 : 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  currentProduct['price'],
                                                  style: TextStyle(
                                                    color: const Color(0xFFFD366E),
                                                    fontSize: isDesktop ? 16 : 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Other products
                                        Expanded(
                                          child: Column(
                                            children: _previewProducts
                                                .where((p) => p != currentProduct)
                                                .map((product) => Expanded(
                                                      child: Container(
                                                        margin: const EdgeInsets.only(bottom: 4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.05),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Center(
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(6),
                                                            child: Image.network(
                                                              product['image'],
                                                              width: thumbnailSize,
                                                              height: thumbnailSize,
                                                              fit: BoxFit.cover,
                                                              loadingBuilder: (context, child, loadingProgress) {
                                                                if (loadingProgress == null) return child;
                                                                return Container(
                                                                  width: thumbnailSize,
                                                                  height: thumbnailSize,
                                                                  color: Colors.white.withOpacity(0.1),
                                                                  child: Center(
                                                                    child: SizedBox(
                                                                      width: isDesktop ? 20 : 12,
                                                                      height: isDesktop ? 20 : 12,
                                                                      child: const CircularProgressIndicator(
                                                                        strokeWidth: 1,
                                                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFD366E)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return Container(
                                                                  width: thumbnailSize,
                                                                  height: thumbnailSize,
                                                                  color: Colors.white.withOpacity(0.1),
                                                                  child: Icon(
                                                                    Icons.image,
                                                                    color: Colors.white54,
                                                                    size: isDesktop ? 24 : 16,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Loading indicator
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFD366E)),
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
      },
    );
  }
}

class StorePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0;

    const spacing = 15.0;

    // Draw grid pattern
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
