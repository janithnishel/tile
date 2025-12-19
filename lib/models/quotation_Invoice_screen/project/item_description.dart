enum ItemType { material, service }

enum ServicePaymentStatus { paid, unpaid, fixed, variable }

class ItemDescription {
  final String name;
  final String category;
  final String categoryId;
  final String productName;
  final double sellingPrice;
  final String unit;
  final ItemType type;
  final ServicePaymentStatus? servicePaymentStatus; // Only applicable for services

  ItemDescription(
    this.name, {
    required this.sellingPrice,
    this.unit = 'units',
    this.category = '',
    this.categoryId = '',
    this.productName = '',
    this.type = ItemType.material,
    this.servicePaymentStatus,
  });

  // Factory constructor for JSON deserialization
  factory ItemDescription.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final paymentStatusStr = json['servicePaymentStatus'] as String?;

    ItemType type = ItemType.material;
    if (typeStr == 'service') {
      type = ItemType.service;
    }

    ServicePaymentStatus? servicePaymentStatus;
    if (paymentStatusStr == 'paid') {
      servicePaymentStatus = ServicePaymentStatus.paid;
    } else if (paymentStatusStr == 'unpaid') {
      servicePaymentStatus = ServicePaymentStatus.unpaid;
    }

    return ItemDescription(
      json['name'] as String? ?? '',
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'units',
      category: json['category'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      type: type,
      servicePaymentStatus: servicePaymentStatus,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    String? typeStr;
    if (type == ItemType.service) {
      typeStr = 'service';
    } else {
      typeStr = 'material';
    }

    String? paymentStatusStr;
    if (servicePaymentStatus == ServicePaymentStatus.paid) {
      paymentStatusStr = 'paid';
    } else if (servicePaymentStatus == ServicePaymentStatus.unpaid) {
      paymentStatusStr = 'unpaid';
    }

    return {
      'name': name,
      'category': category,
      'categoryId': categoryId,
      'productName': productName,
      'sellingPrice': sellingPrice,
      'unit': unit,
      'type': typeStr,
      if (paymentStatusStr != null) 'servicePaymentStatus': paymentStatusStr,
    };
  }

  // Copy with method for immutability
  ItemDescription copyWith({
    String? name,
    String? category,
    String? categoryId,
    String? productName,
    double? sellingPrice,
    String? unit,
    ItemType? type,
    ServicePaymentStatus? servicePaymentStatus,
  }) {
    return ItemDescription(
      name ?? this.name,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      servicePaymentStatus: servicePaymentStatus ?? this.servicePaymentStatus,
    );
  }
}
