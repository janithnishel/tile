class SupplierItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double price;
  final double? lastPurchasePrice;

  SupplierItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.price,
    this.lastPurchasePrice,
  });

  // Factory constructor for JSON deserialization
  factory SupplierItem.fromJson(Map<String, dynamic> json) {
    return SupplierItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      lastPurchasePrice: (json['lastPurchasePrice'] as num?)?.toDouble(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'unit': unit,
      'price': price,
      if (lastPurchasePrice != null) 'lastPurchasePrice': lastPurchasePrice,
    };
  }
}
