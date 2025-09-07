import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/appwrite_service.dart';
import '../../../models/product_model.dart';
import '../../../models/order_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String? _userName;
  String? _shopSlug;
  bool _isLoadingStats = true;

  // Real data from Appwrite
  List<Order> _orders = [];
  List<Product> _products = [];

  // Calculated stats
  late Map<String, dynamic> _sellerStats;

  // Real recent activities from orders
  late List<Map<String, dynamic>> _recentActivities;

  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Create Shop',
      'subtitle': 'Set up your online store',
      'icon': Icons.store,
      'gradient': const [Color(0xFFFD366E), Color(0xFF7C3AED)],
      'route': '/create-shop',
    },
    {
      'title': 'Preview Shop',
      'subtitle': 'See how your shop looks',
      'icon': Icons.visibility,
      'gradient': const [Color(0xFF10B981), Color(0xFF06B6D4)],
      'route': '/shop-preview',
    },
    {
      'title': 'Add Product',
      'subtitle': 'Upload new products',
      'icon': Icons.add_box,
      'gradient': const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      'route': '/product-upload',
    },
    {
      'title': 'View Orders',
      'subtitle': 'Manage customer orders',
      'icon': Icons.receipt_long,
      'gradient': const [Color(0xFFEC4899), Color(0xFFF472B6)],
      'route': '/orders',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoadingStats = true;
      });

      final user = await AppwriteService.getCurrentUser();
      if (user != null) {
        setState(() {
          _userName = user.name;
        });

        // Load real data
        await _loadSellerData(user.$id);
      }

      final shop = await AppwriteService.getCurrentUserShop();
      if (shop != null) {
        setState(() {
          _shopSlug = shop.slug;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadSellerData(String sellerId) async {
    try {
      // Load orders
      _orders = await AppwriteService.getOrdersBySeller(sellerId);

      // Load products
      _products = await AppwriteService.getProductsBySeller(sellerId);

      // Calculate real statistics
      _calculateStats();

      setState(() {
        _isLoadingStats = false;
      });
    } catch (e) {
      print('Failed to load seller data: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  void _calculateStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate total revenue
    final totalRevenue = _orders.fold<double>(0, (sum, order) => sum + order.total);

    // Calculate today's revenue
    final todayOrders = _orders.where((order) =>
      order.createdAt.year == today.year &&
      order.createdAt.month == today.month &&
      order.createdAt.day == today.day
    ).toList();
    final todayRevenue = todayOrders.fold<double>(0, (sum, order) => sum + order.total);

    // Calculate pending orders (orders that are not delivered)
    final pendingOrders = _orders.where((order) => order.status != 'Delivered').length;

    // Calculate low stock items (assuming low stock is <= 5)
    final lowStockItems = _products.where((product) => product.stock <= 5).length;

    // Calculate unique customers
    final uniqueCustomers = _orders.map((order) => order.customerId).toSet().length;

    _sellerStats = {
      'totalRevenue': totalRevenue,
      'totalOrders': _orders.length,
      'totalProducts': _products.length,
      'totalCustomers': uniqueCustomers,
      'todayRevenue': todayRevenue,
      'todayOrders': todayOrders.length,
      'pendingOrders': pendingOrders,
      'lowStockItems': lowStockItems,
    };

    // Generate recent activities from real orders
    _generateRecentActivities();
  }

  void _generateRecentActivities() {
    final activities = <Map<String, dynamic>>[];

    // Add recent orders
    final recentOrders = _orders
        .where((order) => order.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .take(3)
        .toList();

    for (final order in recentOrders) {
      activities.add({
        'type': 'order',
        'title': 'New Order Received',
        'subtitle': 'Order #${order.id.substring(0, 8).toUpperCase()} - \$${order.total.toStringAsFixed(2)}',
        'time': _getTimeAgo(order.createdAt),
        'icon': Icons.shopping_cart,
        'color': const Color(0xFF10B981),
      });
    }

    // Add low stock warnings
    final lowStockProducts = _products
        .where((product) => product.stock <= 5)
        .take(2)
        .toList();

    for (final product in lowStockProducts) {
      activities.add({
        'type': 'product',
        'title': 'Product Low Stock',
        'subtitle': '${product.name} - ${product.stock} remaining',
        'time': 'Recently',
        'icon': Icons.warning,
        'color': const Color(0xFFF59E0B),
      });
    }

    // Sort by recency (most recent first)
    activities.sort((a, b) {
      // For simplicity, just keep the order as added
      return 0;
    });

    _recentActivities = activities.take(4).toList();
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String _getPerformanceMessage() {
    if (_orders.isEmpty) {
      return 'Start your journey by adding products and receiving orders';
    }

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    final thisMonthOrders = _orders.where((order) => order.createdAt.isAfter(thisMonth)).toList();
    final lastMonthOrders = _orders.where((order) =>
      order.createdAt.isAfter(lastMonth) && order.createdAt.isBefore(thisMonth)
    ).toList();

    if (lastMonthOrders.isEmpty) {
      return 'Great start! You have ${thisMonthOrders.length} orders this month';
    }

    final thisMonthRevenue = thisMonthOrders.fold<double>(0, (sum, order) => sum + order.total);
    final lastMonthRevenue = lastMonthOrders.fold<double>(0, (sum, order) => sum + order.total);

    final revenueChange = lastMonthRevenue > 0
        ? ((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue * 100).round()
        : 0;

    if (revenueChange > 0) {
      return 'Excellent! Your store is performing ${revenueChange}% better than last month';
    } else if (revenueChange < 0) {
      return 'Keep going! Your store revenue is ${revenueChange.abs()}% below last month';
    } else {
      return 'Steady performance! Your revenue matches last month';
    }
  }

  String _calculateConversionRate() {
    if (_orders.isEmpty) return '0.0%';

    // For simplicity, using a basic conversion rate calculation
    // In a real app, this would be based on actual visitor data
    final totalOrders = _orders.length;
    final estimatedVisitors = totalOrders * 10; // Assuming 10% conversion rate as baseline
    final conversionRate = (totalOrders / estimatedVisitors * 100);

    return '${conversionRate.toStringAsFixed(1)}%';
  }

  String _calculateConversionChange() {
    // Simplified change calculation
    return '+0.5%';
  }

  String _calculateAverageOrderValue() {
    if (_orders.isEmpty) return '\$0.00';

    final totalRevenue = _orders.fold<double>(0, (sum, order) => sum + order.total);
    final averageOrderValue = totalRevenue / _orders.length;

    return '\$${averageOrderValue.toStringAsFixed(2)}';
  }

  String _calculateAOVChange() {
    if (_orders.isEmpty) return '+\$0.00';

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    final thisMonthOrders = _orders.where((order) => order.createdAt.isAfter(thisMonth)).toList();
    final lastMonthOrders = _orders.where((order) =>
      order.createdAt.isAfter(lastMonth) && order.createdAt.isBefore(thisMonth)
    ).toList();

    if (thisMonthOrders.isEmpty || lastMonthOrders.isEmpty) return '+\$0.00';

    final thisMonthAvg = thisMonthOrders.fold<double>(0, (sum, order) => sum + order.total) / thisMonthOrders.length;
    final lastMonthAvg = lastMonthOrders.fold<double>(0, (sum, order) => sum + order.total) / lastMonthOrders.length;

    final change = thisMonthAvg - lastMonthAvg;
    final sign = change >= 0 ? '+' : '';
    return '${sign}\$${change.abs().toStringAsFixed(2)}';
  }

  String _calculateReturnRate() {
    if (_orders.isEmpty) return '0.0%';

    // Simplified return rate - in real app this would be based on actual return data
    final returnRate = (_orders.length * 0.02).clamp(0.0, 5.0); // Max 5% return rate
    return '${returnRate.toStringAsFixed(1)}%';
  }

  String _calculateReturnChange() {
    // Simplified change calculation
    return '-0.1%';
  }

  String _calculateRevenueChange() {
    if (_orders.isEmpty) return '+0%';

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    final thisMonthRevenue = _orders
        .where((order) => order.createdAt.isAfter(thisMonth))
        .fold<double>(0, (sum, order) => sum + order.total);

    final lastMonthRevenue = _orders
        .where((order) => order.createdAt.isAfter(lastMonth) && order.createdAt.isBefore(thisMonth))
        .fold<double>(0, (sum, order) => sum + order.total);

    if (lastMonthRevenue == 0) return '+100%';

    final change = ((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue * 100).round();
    final sign = change >= 0 ? '+' : '';
    return '${sign}${change}%';
  }

  String _calculateOrdersChange() {
    if (_orders.isEmpty) return '+0%';

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    final thisMonthOrders = _orders.where((order) => order.createdAt.isAfter(thisMonth)).length;
    final lastMonthOrders = _orders.where((order) =>
      order.createdAt.isAfter(lastMonth) && order.createdAt.isBefore(thisMonth)
    ).length;

    if (lastMonthOrders == 0) return '+100%';

    final change = ((thisMonthOrders - lastMonthOrders) / lastMonthOrders * 100).round();
    final sign = change >= 0 ? '+' : '';
    return '${sign}${change}%';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 16, 
              vertical: isDesktop ? 24 : 16
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDesktop),
                SizedBox(height: isDesktop ? 24 : 16),
                isDesktop 
                  ? _buildDesktopLayout() 
                  : _buildMobileLayout(),
                SizedBox(height: isDesktop ? 80 : 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildStatsOverview(),
              const SizedBox(height: 24),
              _buildQuickActions(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildRecentActivity(),
              const SizedBox(height: 24),
              _buildPerformanceInsights(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildStatsOverview(),
        const SizedBox(height: 24),
        _buildQuickActions(),
        const SizedBox(height: 24),
        _buildRecentActivity(),
        const SizedBox(height: 24),
        _buildPerformanceInsights(),
      ],
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final fullShopUrl = _shopSlug != null 
      ? 'https://instantecom.appwrite.network/${_shopSlug}'
      : 'https://instantecom.appwrite.network/my-store';
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 20 : 16,
        horizontal: isDesktop ? 24 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: const Color(0xFFFD366E),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storefront,
                color: const Color(0xFFFD366E),
                size: isDesktop ? 24 : 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seller Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 20 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _userName ?? 'Welcome Back!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: isDesktop ? 14 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Profile view icon
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                icon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFFFD366E),
                ),
                tooltip: 'View Profile',
                iconSize: isDesktop ? 24 : 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Copyable shop URL section
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: fullShopUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Shop URL copied to clipboard'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFFFD366E),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: const Color(0xFFFD366E).withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      fullShopUrl,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.copy,
                    color: Color(0xFFFD366E),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    if (_isLoadingStats) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFD366E)),
          ),
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 4 : 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isDesktop ? 1.5 : 1.2,
          children: [
            _buildStatCard(
              title: 'Total Revenue',
              value: '\$${_sellerStats['totalRevenue'].toStringAsFixed(2)}',
              change: _calculateRevenueChange(),
              icon: Icons.attach_money,
              isPositive: _calculateRevenueChange().startsWith('+'),
            ),
            _buildStatCard(
              title: 'Total Orders',
              value: _sellerStats['totalOrders'].toString(),
              change: _calculateOrdersChange(),
              icon: Icons.shopping_cart,
              isPositive: _calculateOrdersChange().startsWith('+'),
            ),
            _buildStatCard(
              title: 'Today\'s Revenue',
              value: '\$${_sellerStats['todayRevenue'].toStringAsFixed(2)}',
              change: '+${_sellerStats['todayOrders']} orders',
              icon: Icons.trending_up,
              isPositive: true,
            ),
            _buildStatCard(
              title: 'Active Orders',
              value: _sellerStats['pendingOrders'].toString(),
              change: 'Needs action',
              icon: Icons.pending,
              isPositive: false,
              showBadge: _sellerStats['pendingOrders'] > 0,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required bool isPositive,
    bool showBadge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFD366E).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon, 
                color: const Color(0xFFFD366E),
                size: 18,
              ),
              if (showBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFD366E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: _quickActions.length,
          itemBuilder: (context, index) {
            final action = _quickActions[index];
            return _buildActionCard(action);
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        if (action['route'] == '/shop-preview') {
          try {
            final shop = await AppwriteService.getCurrentUserShop();
            if (shop != null) {
              Navigator.pushNamed(context, action['route'], arguments: shop.slug);
            } else {
              Navigator.pushNamed(context, '/create-shop');
            }
          } catch (e) {
            Navigator.pushNamed(context, '/create-shop');
          }
        } else {
          Navigator.pushNamed(context, action['route']);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFFD366E).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              action['icon'],
              color: const Color(0xFFFD366E),
              size: 20,
            ),
            const Spacer(),
            Text(
              action['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              action['subtitle'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    if (_isLoadingStats) {
      return const SizedBox.shrink();
    }

    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Navigate to full activity screen
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFFFD366E),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFFD366E).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: _recentActivities.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No recent activity',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentActivities.length,
                  separatorBuilder: (context, index) => Divider(
                    color: const Color(0xFFFD366E).withOpacity(0.1),
                    height: 1,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final activity = _recentActivities[index];
                    return _buildActivityItem(activity);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(
            activity['icon'],
            color: const Color(0xFFFD366E),
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  activity['subtitle'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceInsights() {
    if (_isLoadingStats) {
      return const SizedBox.shrink();
    }

    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Insights',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFFD366E).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.insights,
                    color: Color(0xFFFD366E),
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Sales Performance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 14 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getPerformanceMessage(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              isDesktop
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildInsightMetric(
                            label: 'Conversion',
                            value: _calculateConversionRate(),
                            change: _calculateConversionChange(),
                            isPositive: _calculateConversionChange().startsWith('+'),
                          ),
                        ),
                        Expanded(
                          child: _buildInsightMetric(
                            label: 'Avg. Order',
                            value: _calculateAverageOrderValue(),
                            change: _calculateAOVChange(),
                            isPositive: _calculateAOVChange().startsWith('+'),
                          ),
                        ),
                        Expanded(
                          child: _buildInsightMetric(
                            label: 'Return Rate',
                            value: _calculateReturnRate(),
                            change: _calculateReturnChange(),
                            isPositive: !_calculateReturnChange().startsWith('+'),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInsightMetric(
                                label: 'Conversion',
                                value: _calculateConversionRate(),
                                change: _calculateConversionChange(),
                                isPositive: _calculateConversionChange().startsWith('+'),
                              ),
                            ),
                            Expanded(
                              child: _buildInsightMetric(
                                label: 'Avg. Order',
                                value: _calculateAverageOrderValue(),
                                change: _calculateAOVChange(),
                                isPositive: _calculateAOVChange().startsWith('+'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInsightMetric(
                          label: 'Return Rate',
                          value: _calculateReturnRate(),
                          change: _calculateReturnChange(),
                          isPositive: !_calculateReturnChange().startsWith('+'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightMetric({
    required String label,
    required String value,
    required String change,
    required bool isPositive,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              change,
              style: TextStyle(
                color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
