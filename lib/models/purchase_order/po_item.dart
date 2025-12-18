class POItem {
  final String name;
  double quantity;
  final String unit;
  double unitPrice;

  POItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });

  // Factory constructor for JSON deserialization
  factory POItem.fromJson(Map<String, dynamic> json) {
    return POItem(
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
    };
  }

  double get totalAmount => quantity * unitPrice;

  // Display string for item
  String get displayText => '$name (x${quantity.toStringAsFixed(0)})';
}
