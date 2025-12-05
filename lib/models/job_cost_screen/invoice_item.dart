class InvoiceItem {
  final String name;
  final double quantity;
  final String unit;
  final double sellingPrice;
  double? costPrice;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.sellingPrice,
    this.costPrice,
  });

  double get profit => (sellingPrice - (costPrice ?? 0)) * quantity;
  double get totalSellingPrice => sellingPrice * quantity;
  double get totalCostPrice => (costPrice ?? 0) * quantity;

  bool get hasCostPrice => costPrice != null;

  InvoiceItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    double? sellingPrice,
    double? costPrice,
  }) {
    return InvoiceItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
    );
  }
}
