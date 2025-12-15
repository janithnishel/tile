class ItemDescription {
  final String name;
  final String category;
  final String categoryId;
  final String productName;
  final double sellingPrice;
  final String unit;

  ItemDescription(
    this.name, {
    required this.sellingPrice,
    this.unit = 'units',
    this.category = '',
    this.categoryId = '',
    this.productName = '',
  });

  // Factory constructor for JSON deserialization
  factory ItemDescription.fromJson(Map<String, dynamic> json) {
    return ItemDescription(
      json['name'] as String? ?? '',
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'units',
      category: json['category'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'categoryId': categoryId,
      'productName': productName,
      'sellingPrice': sellingPrice,
      'unit': unit,
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
  }) {
    return ItemDescription(
      name ?? this.name,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      productName: productName ?? this.productName,
    );
  }
}
