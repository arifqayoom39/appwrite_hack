import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/order_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../services/appwrite_service.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessingOrder = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _notesController = TextEditingController();

  // App colors matching storefront
  static const Color primaryColor = Color(0xFFFD366E);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF3D3D3D);
  static const Color lightGrayColor = Color(0xFFF5F5F5);
  static const Color darkGrayColor = Color(0xFF9E9E9E);

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
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    // Prefill user data
    _prefillUserData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _prefillUserData() async {
    try {
      final user = await AppwriteService.getCurrentUser();
      if (user != null) {
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email;
        });
      }
    } catch (e) {
      // Handle error silently - no user required
    }
  }

  Future<void> _processOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    setState(() {
      _isProcessingOrder = true;
    });

    try {
      // Get current user (optional - allow guest orders)
      final user = await AppwriteService.getCurrentUser();

      // Validate all cart items have required data and sufficient stock
      for (final item in cartItems) {
        if (item.product.sellerId.isEmpty || item.product.shopId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Some products have incomplete information. Please remove them and try again.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
          return;
        }

        // Check if there's sufficient stock
        if (item.product.stock < item.quantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Insufficient stock for ${item.product.name}. Available: ${item.product.stock}, Requested: ${item.quantity}'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
          return;
        }
      }

      // Validate shop exists
      final shopExists = await AppwriteService.validateShopExists(cartItems.first.product.shopId);
      if (!shopExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop no longer exists. Please contact support.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      // Calculate total
      final total = cartItems.fold(0.0, (sum, item) => sum + item.total);

      // Calculate total number of items
      final totalItemCount = cartItems.fold(0, (sum, item) => sum + item.quantity);

      // Create shipping address
      final shippingAddress = [
        _addressController.text.trim(),
        _cityController.text.trim(),
        _stateController.text.trim(),
        _zipCodeController.text.trim(),
      ].where((part) => part.isNotEmpty).join(', ');

      // Create order
      final order = Order(
        id: '', // Will be set by Appwrite
        customerId: user?.$id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}',
        sellerId: cartItems.first.product.sellerId,
        shopId: cartItems.first.product.shopId,
        items: totalItemCount,
        total: total,
        status: 'Pending',
        createdAt: DateTime.now(),
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerPhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        shippingAddress: shippingAddress.isNotEmpty ? shippingAddress : null,
        paymentMethod: 'Cash on Delivery', // Default payment method
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      // Create order in database
      final createdOrder = await AppwriteService.createOrder(order);

      // Update product stock quantities
      bool stockUpdateFailed = false;
      for (final item in cartItems) {
        try {
          final newStock = item.product.stock - item.quantity;
          if (newStock < 0) {
            // This shouldn't happen if validation is correct, but handle it just in case
            print('Warning: Stock would go negative for product ${item.product.id}');
            continue;
          }
          await AppwriteService.updateProduct(item.product.id, {
            'stock': newStock,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          print('Failed to update stock for product ${item.product.id}: $e');
          stockUpdateFailed = true;
        }
      }

      // Clear cart
      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        // Show warning if stock update failed
        if (stockUpdateFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully, but there was an issue updating inventory. Please contact support if you notice discrepancies.'),
              backgroundColor: Color(0xFFF59E0B), // Amber color for warning
              duration: Duration(seconds: 5),
            ),
          );
        }

        // Navigate to order success screen
        context.go('/order-success/${createdOrder.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartProvider.notifier).total;
    final itemCount = ref.watch(cartProvider.notifier).itemCount;

    // Get theme matching storefront
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final currentTheme = _themes[isDarkMode ? 'Dark' : 'Light']!;

    return Theme(
      data: currentTheme,
      child: Scaffold(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        appBar: _buildAppBar(currentTheme, itemCount),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOrderSummary(currentTheme, cartItems, total),
                          const SizedBox(height: 24),
                          _buildShippingForm(currentTheme),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildPlaceOrderButton(currentTheme, total),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, int itemCount) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0.5,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: Text(
        'Order Details',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: theme.brightness == Brightness.dark ? Colors.white : textColor,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        color: theme.brightness == Brightness.dark ? Colors.white : textColor,
      ),
    );
  }

  Widget _buildOrderSummary(ThemeData theme, List<CartItem> cartItems, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : lightGrayColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white : textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...cartItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.product.name} x${item.quantity}',
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark ? Colors.white70 : textColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '\$${item.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          Divider(color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.2) : darkGrayColor.withOpacity(0.2)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: theme.brightness == Brightness.dark ? Colors.white : textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping Information',
          style: TextStyle(
            color: theme.brightness == Brightness.dark ? Colors.white : textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          theme: theme,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Enter your email',
          theme: theme,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number (Optional)',
          hint: 'Enter your phone number',
          theme: theme,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Street Address',
          hint: 'Enter your street address',
          theme: theme,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Enter city',
                theme: theme,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _stateController,
                label: 'State/Province',
                hint: 'Enter state',
                theme: theme,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _zipCodeController,
          label: 'ZIP/Postal Code',
          hint: 'Enter ZIP code',
          theme: theme,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter ZIP code';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _notesController,
          label: 'Order Notes (Optional)',
          hint: 'Any special instructions...',
          theme: theme,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        color: theme.brightness == Brightness.dark ? Colors.white : textColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: darkGrayColor,
        ),
        labelStyle: TextStyle(
          color: theme.brightness == Brightness.dark ? Colors.white70 : textColor,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.3) : darkGrayColor.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
      ),
      validator: validator,
    );
  }

  Widget _buildPlaceOrderButton(ThemeData theme, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : lightGrayColor),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _isProcessingOrder ? null : _processOrder,
                child: Center(
                  child: _isProcessingOrder
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Place Order - \$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'By placing this order, you agree to our terms and conditions.',
            style: TextStyle(
              color: darkGrayColor,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
