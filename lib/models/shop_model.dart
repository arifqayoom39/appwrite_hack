class Shop {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String email;
  final String phone;
  final String sellerId;
  final String theme;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? logoUrl;
  final String? bannerUrl;
  final Map<String, dynamic>? settings;

  Shop({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.email,
    required this.phone,
    required this.sellerId,
    required this.theme,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.logoUrl,
    this.bannerUrl,
    this.settings,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['\$id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      sellerId: json['sellerId'] ?? '',
      theme: json['theme'] ?? 'Midnight Pro',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      logoUrl: json['logoUrl'],
      bannerUrl: json['bannerUrl'],
      settings: json['settings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'email': email,
      'phone': phone,
      'sellerId': sellerId,
      'theme': theme,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'settings': settings,
    };
  }

  Shop copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? email,
    String? phone,
    String? sellerId,
    String? theme,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? logoUrl,
    String? bannerUrl,
    Map<String, dynamic>? settings,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      sellerId: sellerId ?? this.sellerId,
      theme: theme ?? this.theme,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      settings: settings ?? this.settings,
    );
  }
}
