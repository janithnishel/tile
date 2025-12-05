class QuotationItem {
  final String name;
  final double quantity;
  final String unit;
  final double estimatedPrice;
  bool isOrdered;

  QuotationItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.estimatedPrice,
    this.isOrdered = false,
  });

  double get totalEstimatedPrice => quantity * estimatedPrice;
}