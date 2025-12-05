/// Base interface for all line items across different modules
abstract class BaseItem {
  String get name;
  double get quantity;
  String get unit;
  double get unitPrice;
  double get totalAmount;
}

/// Base implementation for line items with common functionality
class LineItem implements BaseItem {
  @override
  final String name;
  @override
  final double quantity;
  @override
  final String unit;
  @override
  final double unitPrice;

  const LineItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });

  @override
  double get totalAmount => quantity * unitPrice;

  /// Create a copy with modified fields
  LineItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    double? unitPrice,
  }) {
    return LineItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  String toString() =>
      '$name (x${quantity.toStringAsFixed(0)}) - ${totalAmount.toStringAsFixed(2)}';
}
