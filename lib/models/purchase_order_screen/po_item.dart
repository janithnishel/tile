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

  double get totalAmount => quantity * unitPrice;

  // Display string for item
  String get displayText => '$name (x${quantity.toStringAsFixed(0)})';
}