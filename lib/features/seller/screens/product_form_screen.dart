import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../services/appwrite_service.dart';
import '../../../models/product_model.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({Key? key}) : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late AnimationController _progressController;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _shortDescriptionController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dimensionsController = TextEditingController();

  // Form data
  String _selectedCategory = 'Electronics';
  String _selectedStatus = 'Draft';
  bool _isVirtual = false;
  bool _isDownloadable = false;
  bool _manageStock = true;
  bool _allowBackorders = false;
  List<PlatformFile> _selectedImages = [];
  List<String> _tags = [];

  // Loading state
  bool _isSubmitting = false;
  bool _isPickingImage = false;

  Future<void> _pickImages() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          _selectedImages.addAll(result.files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home & Garden',
    'Sports & Outdoors',
    'Books & Media',
    'Health & Beauty',
    'Automotive',
    'Toys & Games',
  ];

  final List<String> _statuses = ['Draft', 'Pending Review', 'Published'];

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animationController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    super.dispose();
  }

  Future<void> _submitProduct() async {
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get current user and shop
      final user = await AppwriteService.getCurrentUser();
      final shop = await AppwriteService.getCurrentUserShop();

      if (user == null || shop == null) {
        throw Exception('User or shop not found');
      }

      // Parse dimensions
      Map<String, dynamic>? dimensions;
      if (_dimensionsController.text.isNotEmpty) {
        // Expected format: "10×20×5" or "10x20x5"
        final parts = _dimensionsController.text.replaceAll('×', 'x').split('x');
        if (parts.length == 3) {
          dimensions = {
            'length': double.tryParse(parts[0].trim()) ?? 0,
            'width': double.tryParse(parts[1].trim()) ?? 0,
            'height': double.tryParse(parts[2].trim()) ?? 0,
          };
        }
      }

      // Upload images if any
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final uploadedFileIds = await AppwriteService.uploadMultipleProductImages(_selectedImages);
        imageUrls = await AppwriteService.getProductImageUrls(uploadedFileIds);
      }

      // Create product
      final product = Product(
        id: '', // Will be set by Appwrite
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0,
        salePrice: _salePriceController.text.isNotEmpty
            ? double.tryParse(_salePriceController.text)
            : null,
        category: _selectedCategory,
        images: imageUrls, // Use actual uploaded image URLs
        sellerId: user.$id,
        shopId: shop.id,
        stock: int.tryParse(_stockController.text) ?? 0,
        isActive: _selectedStatus == 'Published',
        createdAt: DateTime.now(),
        updatedAt: null,
        sku: _skuController.text.isNotEmpty ? _skuController.text.trim() : null,
        weight: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        dimensions: dimensions,
        tags: _tags.isNotEmpty ? _tags : null,
      );

      await AppwriteService.createProduct(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Product created successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        // Navigate to dashboard using Go Router
        GoRouter.of(context).go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create product: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product name is required')),
      );
      return false;
    }

    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price is required')),
      );
      return false;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: isDesktop ? 16 : 8),
              child: Column(
                children: [
                  _buildHeader(isDesktop),
                  _buildProgressIndicator(isDesktop),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentStep = index;
                        });
                      },
                      children: [
                        _buildBasicInfoStep(isDesktop),
                        _buildPricingStep(isDesktop),
                        _buildMediaStep(isDesktop),
                        _buildInventoryStep(isDesktop),
                      ],
                    ),
                  ),
                  _buildBottomNavigation(isDesktop),
                ],
              ),
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFD366E)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Publishing your product...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: const Color(0xFFFD366E).withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.add_box,
            color: const Color(0xFFFD366E),
            size: isDesktop ? 24 : 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Product',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Build your product listing step by step',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFFD366E).withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Step ${_currentStep + 1} of 4',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: List.generate(4, (index) {
          bool isActive = index <= _currentStep;

          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isActive ? const Color(0xFFFD366E) : Colors.white.withOpacity(0.2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomNavigation(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFFD366E).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: const Color(0xFFFD366E).withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFD366E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton.icon(
                icon: Icon(_currentStep == 3 ? Icons.rocket_launch : Icons.arrow_forward),
                label: Text(_currentStep == 3 ? 'Publish Product' : 'Continue'),
                onPressed: _isSubmitting
                    ? null
                    : () {
                        if (_currentStep == 3) {
                          _submitProduct();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tell customers about your product',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Product Details Section
          _buildSectionCard(
            title: 'Product Details',
            icon: Icons.inventory,
            children: [
              _buildModernTextField(
                controller: _nameController,
                label: 'Product Name',
                hint: 'Enter your product name',
                icon: Icons.shopping_bag,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildModernDropdown(
                label: 'Category',
                value: _selectedCategory,
                items: _categories,
                icon: Icons.category,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                controller: _shortDescriptionController,
                label: 'Short Description',
                hint: 'Brief product description',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                controller: _descriptionController,
                label: 'Full Description',
                hint: 'Detailed product description',
                icon: Icons.article,
                maxLines: 5,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Product Type Section
          _buildSectionCard(
            title: 'Product Type',
            icon: Icons.settings,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildToggleOption(
                      title: 'Virtual',
                      subtitle: 'Digital product',
                      value: _isVirtual,
                      onChanged: (value) {
                        setState(() {
                          _isVirtual = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildToggleOption(
                      title: 'Downloadable',
                      subtitle: 'Downloadable files',
                      value: _isDownloadable,
                      onChanged: (value) {
                        setState(() {
                          _isDownloadable = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: isDesktop ? 60 : 40),
        ],
      ),
    );
  }

  Widget _buildPricingStep(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing & Sales',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Set your product pricing and sales options',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionCard(
            title: 'Pricing Information',
            icon: Icons.attach_money,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildModernTextField(
                      controller: _priceController,
                      label: 'Regular Price',
                      hint: '0.00',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModernTextField(
                      controller: _salePriceController,
                      label: 'Sale Price',
                      hint: '0.00',
                      icon: Icons.discount,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFFFD366E),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sale price will override regular price when active',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: isDesktop ? 60 : 40),
        ],
      ),
    );
  }

  Widget _buildMediaStep(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Media',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Upload stunning images for your product',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionCard(
            title: 'Product Images',
            icon: Icons.photo_library,
            children: [
              // Image Upload Area
              Container(
                height: isDesktop ? 200 : 150,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFD366E).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Pick images using file picker
                      _pickImages();
                      HapticFeedback.lightImpact();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFD366E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate,
                            color: Color(0xFFFD366E),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Upload Product Images',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click to browse or drag & drop\nSupports JPG, PNG, WebP (Max 10MB each)',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Image Preview Area
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFD366E).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            _selectedImages[index].bytes != null
                              ? Image.memory(
                                  _selectedImages[index].bytes!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.white.withOpacity(0.5),
                                        size: 32,
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 32,
                                  ),
                                ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 16),

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
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: const Color(0xFFFD366E),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Upload high-quality images (at least 1000x1000px) for better visibility. You can select multiple images at once.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: isDesktop ? 60 : 40),
        ],
      ),
    );
  }

  Widget _buildInventoryStep(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory & Shipping',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Manage stock and shipping information',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Inventory Management
          _buildSectionCard(
            title: 'Inventory Management',
            icon: Icons.inventory,
            children: [
              _buildModernTextField(
                controller: _skuController,
                label: 'SKU (Stock Keeping Unit)',
                hint: 'Enter unique SKU',
                icon: Icons.qr_code,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildModernTextField(
                      controller: _stockController,
                      label: 'Stock Quantity',
                      hint: '0',
                      icon: Icons.numbers,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModernDropdown(
                      label: 'Status',
                      value: _selectedStatus,
                      items: _statuses,
                      icon: Icons.flag,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildToggleOption(
                      title: 'Manage Stock',
                      subtitle: 'Track inventory',
                      value: _manageStock,
                      onChanged: (value) {
                        setState(() {
                          _manageStock = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildToggleOption(
                      title: 'Allow Backorders',
                      subtitle: 'Sell out of stock',
                      value: _allowBackorders,
                      onChanged: (value) {
                        setState(() {
                          _allowBackorders = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Shipping Information
          _buildSectionCard(
            title: 'Shipping Information',
            icon: Icons.local_shipping,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildModernTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      hint: '0.00',
                      icon: Icons.scale,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModernTextField(
                      controller: _dimensionsController,
                      label: 'Dimensions (L×W×H)',
                      hint: '10×20×5 cm',
                      icon: Icons.aspect_ratio,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: isDesktop ? 60 : 40),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        dropdownColor: const Color(0xFF1E293B),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item, style: const TextStyle(color: Colors.white)),
        )).toList(),
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? const Color(0xFFFD366E) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFD366E),
            activeTrackColor: const Color(0xFFFD366E).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
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
              Icon(
                icon,
                color: const Color(0xFFFD366E),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}