import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/order_model.dart';
import '../../../services/appwrite_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderId;

  const OrderTrackingScreen({Key? key, this.orderId}) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _trackingController = TextEditingController();
  Order? _order;
  bool _isLoading = false;
  String? _error;

  // App colors matching storefront
  static const Color primaryColor = Color(0xFFFD366E);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF3D3D3D);
  static const Color lightGrayColor = Color(0xFFF5F5F5);

  // Theme system matching storefront
  final Map<String, ThemeData> _themes = {
    'Light': ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Colors.white,
        background: backgroundColor,
        onBackground: textColor,
      ),
      cardTheme: const CardTheme(
        color: Colors.white,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: textColor),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
      ),
    ),
    'Dark': ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
        onBackground: Colors.white,
      ),
      cardTheme: const CardTheme(
        color: Color(0xFF1E1E1E),
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    ),
  };

  @override
  void initState() {
    super.initState();
    if (widget.orderId != null) {
      _trackingController.text = widget.orderId!;
      _trackOrder();
    }
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _trackOrder() async {
    final trackingId = _trackingController.text.trim();
    if (trackingId.isEmpty) {
      setState(() {
        _error = 'Please enter a tracking ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Try to get the order directly by ID (works for both logged-in and guest users)
      final order = await AppwriteService.getOrderById(trackingId);

      if (order == null) {
        throw Exception('Order not found. Please check your tracking ID.');
      }

      // Optional: If user is logged in, verify they own this order
      final user = await AppwriteService.getCurrentUser();
      if (user != null && order.customerId != user.$id && order.customerId != 'guest') {
        throw Exception('You do not have permission to view this order.');
      }

      setState(() {
        _order = order;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme matching storefront
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final currentTheme = _themes[isDarkMode ? 'Dark' : 'Light']!;

    return Theme(
      data: currentTheme,
      child: Scaffold(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: currentTheme.scaffoldBackgroundColor,
          elevation: 0.5,
          scrolledUnderElevation: 1,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          title: Text(
            'Track Order',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: currentTheme.brightness == Brightness.dark ? Colors.white : textColor,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            color: currentTheme.brightness == Brightness.dark ? Colors.white : textColor,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrackingInput(currentTheme),
                if (_error != null) _buildError(currentTheme),
                if (_order != null) _buildOrderDetails(currentTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : lightGrayColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter Tracking ID',
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white : textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Paste your tracking ID or use the direct URL: storepe.appwrite.network/order-tracking?orderId=[your-id]',
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white70 : textColor.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _trackingController,
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white : textColor,
            ),
            decoration: InputDecoration(
              hintText: 'Paste your tracking ID here',
              hintStyle: TextStyle(
                color: theme.brightness == Brightness.dark ? Colors.white70 : textColor.withOpacity(0.6),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.3) : textColor.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: primaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste),
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data?.text != null) {
                    _trackingController.text = data!.text!;
                  }
                },
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _isLoading ? null : _trackOrder,
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Track Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Color(0xFFEF4444)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(ThemeData theme) {
    if (_order == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : lightGrayColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order #${_order!.id}',
                style: TextStyle(
                  color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(_order!.status),
            ],
          ),
          const SizedBox(height: 16),
          _buildOrderInfo(theme),
          const SizedBox(height: 20),
          _buildOrderTimeline(theme),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = const Color(0xFFF59E0B);
        break;
      case 'processing':
        color = primaryColor;
        break;
      case 'shipped':
        color = const Color(0xFF3B82F6);
        break;
      case 'delivered':
        color = const Color(0xFF10B981);
        break;
      case 'cancelled':
        color = const Color(0xFFEF4444);
        break;
      default:
        color = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOrderInfo(ThemeData theme) {
    return Column(
      children: [
        _buildInfoRow('Date', _formatDate(_order!.createdAt), theme),
        _buildInfoRow('Items', '${_order!.items} items', theme),
        _buildInfoRow('Total', '\$${_order!.total.toStringAsFixed(2)}', theme),
        if (_order!.customerName != null)
          _buildInfoRow('Customer', _order!.customerName!, theme),
        if (_order!.shippingAddress != null)
          _buildInfoRow('Shipping', _order!.shippingAddress!, theme),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: theme.brightness == Brightness.dark ? Colors.white70 : textColor.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(ThemeData theme) {
    final steps = [
      {'status': 'Order Placed', 'date': _order!.createdAt, 'completed': true},
      {'status': 'Processing', 'date': null, 'completed': ['processing', 'shipped', 'delivered'].contains(_order!.status.toLowerCase())},
      {'status': 'Shipped', 'date': null, 'completed': ['shipped', 'delivered'].contains(_order!.status.toLowerCase())},
      {'status': 'Delivered', 'date': null, 'completed': _order!.status.toLowerCase() == 'delivered'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Timeline',
          style: TextStyle(
            color: theme.brightness == Brightness.dark ? Colors.white : textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...steps.map((step) => _buildTimelineStep(step, theme)),
      ],
    );
  }

  Widget _buildTimelineStep(Map<String, dynamic> step, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: step['completed'] ? primaryColor : theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.3) : textColor.withOpacity(0.3),
            ),
            child: step['completed']
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['status'],
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (step['date'] != null)
                  Text(
                    _formatDate(step['date']),
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark ? Colors.white70 : textColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
