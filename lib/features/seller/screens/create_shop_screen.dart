import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../services/appwrite_service.dart';
import '../../../models/shop_model.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({Key? key}) : super(key: key);

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  String _selectedTheme = 'Midnight Pro';
  String _shopName = '';
  String _shopSlug = '';
  String _shopDescription = '';
  String _shopEmail = '';
  String _shopPhone = '';
  int _currentStep = 0;
  
  final PageController _pageController = PageController();
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  
  final List<String> _themes = [
    'Midnight Pro',
    'Ocean Breeze',
    'Sunset Glow',
    'Forest Zen',
    'Royal Purple',
    'Aurora',
    'Cosmic Dark',
    'Golden Luxury',
  ];

  // Image selection state
  PlatformFile? _selectedLogo;
  PlatformFile? _selectedBanner;
  bool _isPickingLogo = false;
  bool _isPickingBanner = false;

  Future<void> _createShop() async {
    if (_shopName.isEmpty || _shopSlug.isEmpty || _shopEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      // Get current user
      final user = await AppwriteService.getCurrentUser();
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      // Upload logo and banner if selected
      String? logoUrl;
      String? bannerUrl;

      if (_selectedLogo != null) {
        final uploadedFileIds = await AppwriteService.uploadMultipleProductImages([_selectedLogo!]);
        final urls = await AppwriteService.getProductImageUrls(uploadedFileIds);
        logoUrl = urls.isNotEmpty ? urls[0] : null;
      }

      if (_selectedBanner != null) {
        final uploadedFileIds = await AppwriteService.uploadMultipleProductImages([_selectedBanner!]);
        final urls = await AppwriteService.getProductImageUrls(uploadedFileIds);
        bannerUrl = urls.isNotEmpty ? urls[0] : null;
      }

      // Create shop
      final shop = Shop(
        id: '',
        name: _shopName,
        slug: _shopSlug,
        description: _shopDescription,
        email: _shopEmail,
        phone: _shopPhone,
        sellerId: user.$id,
        theme: _selectedTheme,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
        createdAt: DateTime.now(),
      );

      final createdShop = await AppwriteService.createShop(shop);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shop "${createdShop.name}" created successfully!')),
      );

      // Navigate to dashboard using Go Router
      GoRouter.of(context).go('/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create shop: $e')),
      );
    }
  }

  Future<void> _pickLogo() async {
    if (_isPickingLogo) return;

    setState(() {
      _isPickingLogo = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedLogo = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick logo: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingLogo = false;
        });
      }
    }
  }

  Future<void> _pickBanner() async {
    if (_isPickingBanner) return;

    setState(() {
      _isPickingBanner = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedBanner = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick banner: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingBanner = false;
        });
      }
    }
  }

  void _removeLogo() {
    setState(() {
      _selectedLogo = null;
    });
  }

  void _removeBanner() {
    setState(() {
      _selectedBanner = null;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
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
                    _buildDesignStep(isDesktop),
                    _buildPreviewStep(isDesktop),
                  ],
                ),
              ),
              _buildBottomNavigation(isDesktop),
            ],
          ),
        ),
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
                  'Create Your Shop',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 20 : 18,
                  color: Colors.white,
                  ),
                ),
                Text(
                  'Build your dream store in minutes',
                  style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: Colors.white,
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
              'Step ${_currentStep + 1} of 3',
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
        children: List.generate(3, (index) {
          bool isActive = index <= _currentStep;

          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
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
                icon: Icon(_currentStep == 2 ? Icons.rocket_launch : Icons.arrow_forward),
                label: Text(_currentStep == 2 ? 'Launch Shop' : 'Continue'),
                onPressed: () {
                  if (_currentStep == 2) {
                    _createShop();
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
            'Tell customers about your shop',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Shop Details Section
          _buildSectionCard(
            title: 'Shop Details',
            icon: Icons.store,
            children: [
              _buildModernTextField(
                controller: _controllers[0],
                label: 'Shop Name',
                hint: 'Enter your shop name',
                icon: Icons.storefront,
                onChanged: (value) => setState(() => _shopName = value),
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                controller: _controllers[1],
                label: 'Shop URL',
                hint: 'your-shop-url',
                icon: Icons.link,
                onChanged: (value) => setState(() => _shopSlug = value),
                prefix: 'storepe.appwrite.network//',
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                controller: _controllers[2],
                label: 'Description',
                hint: 'Tell customers about your shop...',
                icon: Icons.edit_note,
                maxLines: 3,
                onChanged: (value) => setState(() => _shopDescription = value),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Contact Information Section
          _buildSectionCard(
            title: 'Contact Information',
            icon: Icons.contact_mail,
            children: [
              _buildModernTextField(
                controller: _controllers[3],
                label: 'Contact Email',
                hint: 'your@email.com',
                icon: Icons.email,
                onChanged: (value) => setState(() => _shopEmail = value),
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                controller: _controllers[4],
                label: 'Phone Number',
                hint: '+1 (555) 123-4567',
                icon: Icons.phone,
                onChanged: (value) => setState(() => _shopPhone = value),
              ),
            ],
          ),

          SizedBox(height: isDesktop ? 60 : 40),
        ],
      ),
    );
  }

  Widget _buildDesignStep(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Design & Branding',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose your shop theme and upload brand assets',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Theme Selection Section
          _buildSectionCard(
            title: 'Shop Theme',
            icon: Icons.palette,
            children: [
              _buildModernDropdown(
                label: 'Select Theme',
                value: _selectedTheme,
                items: _themes,
                icon: Icons.color_lens,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Brand Assets Section
          _buildSectionCard(
            title: 'Brand Assets',
            icon: Icons.image,
            children: [
              // Logo Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Logo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: isDesktop ? 120 : 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: _selectedLogo != null
                        ? Stack(
                            children: [
                              Center(
                                child: _selectedLogo!.bytes != null
                                    ? Image.memory(
                                        _selectedLogo!.bytes!,
                                        fit: BoxFit.contain,
                                        height: isDesktop ? 80 : 60,
                                      )
                                    : const Icon(
                                        Icons.image,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: _removeLogo,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _pickLogo,
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      color: Colors.white.withOpacity(0.7),
                                      size: isDesktop ? 32 : 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Click to upload logo',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Banner Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Banner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: isDesktop ? 120 : 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: _selectedBanner != null
                        ? Stack(
                            children: [
                              Center(
                                child: _selectedBanner!.bytes != null
                                    ? Image.memory(
                                        _selectedBanner!.bytes!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : const Icon(
                                        Icons.image,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: _removeBanner,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _pickBanner,
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      color: Colors.white.withOpacity(0.7),
                                      size: isDesktop ? 32 : 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Click to upload banner',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

  Widget _buildPreviewStep(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Launch',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Review your shop details before launching',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Shop Summary Section
          _buildSectionCard(
            title: 'Shop Summary',
            icon: Icons.storefront,
            children: [
              _buildSummaryRow('Shop Name', _shopName.isNotEmpty ? _shopName : 'Not provided'),
              const SizedBox(height: 12),
              _buildSummaryRow('Shop URL', _shopSlug.isNotEmpty ? 'storepe.appwrite.network//$_shopSlug' : 'Not provided'),
              const SizedBox(height: 12),
              _buildSummaryRow('Description', _shopDescription.isNotEmpty ? _shopDescription : 'Not provided'),
              const SizedBox(height: 12),
              _buildSummaryRow('Contact Email', _shopEmail.isNotEmpty ? _shopEmail : 'Not provided'),
              const SizedBox(height: 12),
              _buildSummaryRow('Phone', _shopPhone.isNotEmpty ? _shopPhone : 'Not provided'),
              const SizedBox(height: 12),
              _buildSummaryRow('Theme', _selectedTheme),
              const SizedBox(height: 12),
              _buildSummaryRow('Logo', _selectedLogo != null ? 'Uploaded' : 'Not provided'),
              const SizedBox(height: 12),
              _buildSummaryRow('Banner', _selectedBanner != null ? 'Uploaded' : 'Not provided'),
            ],
          ),

          SizedBox(height: isDesktop ? 60 : 40),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? prefix,
    Function(String)? onChanged,
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
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          prefixText: prefix,
          prefixStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
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
}
