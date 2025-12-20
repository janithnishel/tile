class POItem {
  final String? id;
  final String itemName;
  final String? category;
  double quantity;
  final String unit;
  double unitPrice;

  POItem({
    this.id,
    required this.itemName,
    this.category,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });

  // Factory constructor for JSON deserialization
  factory POItem.fromJson(Map<String, dynamic> json) {
    return POItem(
      id: json['id'] as String?,
      itemName: json['name'] as String? ?? '',
      category: json['category'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': itemName,
      if (category != null) 'category': category,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
    };
  }

  double get totalAmount => quantity * unitPrice;

  // Display string for item
  String get displayText => '$itemName (x${quantity.toStringAsFixed(0)})';

  // Backward compatibility getter
  String get name => itemName;
}
