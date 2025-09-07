class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? salePrice;
  final String category;
  final List<String> images;
  final String sellerId;
  final String shopId;
  final int stock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? sku;
  final double? weight;
  final Map<String, dynamic>? dimensions;
  final List<String>? tags;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.salePrice,
    required this.category,
    required this.images,
    required this.sellerId,
    required this.shopId,
    required this.stock,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.sku,
    this.weight,
    this.dimensions,
    this.tags,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['\$id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      salePrice: json['salePrice']?.toDouble(),
      category: json['category'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      sellerId: json['sellerId'] ?? '',
      shopId: json['shopId'] ?? '',
      stock: json['stock'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      sku: json['sku'],
      weight: json['weight']?.toDouble(),
      dimensions: json['dimensions'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'salePrice': salePrice,
      'category': category,
      'images': images,
      'sellerId': sellerId,
      'shopId': shopId,
      'stock': stock,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'sku': sku,
      'weight': weight,
      'dimensions': dimensions,
      'tags': tags,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? salePrice,
    String? category,
    List<String>? images,
    String? sellerId,
    String? shopId,
    int? stock,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sku,
    double? weight,
    Map<String, dynamic>? dimensions,
    List<String>? tags,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      category: category ?? this.category,
      images: images ?? this.images,
      sellerId: sellerId ?? this.sellerId,
      shopId: shopId ?? this.shopId,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sku: sku ?? this.sku,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      tags: tags ?? this.tags,
    );
  }
}
