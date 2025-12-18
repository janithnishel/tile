class QuotationItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final double estimatedPrice;
  final double? lastPurchasePrice;
  final String? lastPurchaseDate;
  bool isOrdered;

  QuotationItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.estimatedPrice,
    this.lastPurchasePrice,
    this.lastPurchaseDate,
    this.isOrdered = false,
  });

  double get totalEstimatedPrice => quantity * estimatedPrice;
}
