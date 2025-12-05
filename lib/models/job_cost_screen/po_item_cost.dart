class POItemCost {
  final String poId;
  final String supplierName;
  final String itemName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final DateTime orderDate;
  final String status;

  POItemCost({
    required this.poId,
    required this.supplierName,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.orderDate,
    required this.status,
  });

  double get totalCost => quantity * unitPrice;

  String get quantityDisplay => '${quantity.toStringAsFixed(0)} $unit';
}