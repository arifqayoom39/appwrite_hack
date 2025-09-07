class Order {
  final String id;
  final String customerId;
  final String sellerId;
  final String shopId;
  final int items;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? shippingAddress;
  final String? paymentMethod;
  final String? notes;

  Order({
    required this.id,
    required this.customerId,
    required this.sellerId,
    required this.shopId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.shippingAddress,
    this.paymentMethod,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['\$id'] ?? json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      sellerId: json['sellerId'] ?? '',
      shopId: json['shopId'] ?? '',
      items: (json['items'] as int?) ?? 0,
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      shippingAddress: json['shippingAddress'],
      paymentMethod: json['paymentMethod'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'sellerId': sellerId,
      'shopId': shopId,
      'items': items,
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }

  Order copyWith({
    String? id,
    String? customerId,
    String? sellerId,
    String? shopId,
    int? items,
    double? total,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? shippingAddress,
    String? paymentMethod,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      sellerId: sellerId ?? this.sellerId,
      shopId: shopId ?? this.shopId,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String? productImage;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.productImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      productImage: json['productImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'productImage': productImage,
    };
  }
}
