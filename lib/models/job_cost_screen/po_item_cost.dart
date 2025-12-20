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

  // JSON serialization
  factory POItemCost.fromJson(Map<String, dynamic> json) {
    return POItemCost(
      poId: json['poId'] as String,
      supplierName: json['supplierName'] as String? ?? '',
      itemName: json['itemName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num).toDouble(),
      orderDate: DateTime.parse(json['orderDate'] as String),
      status: json['status'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'poId': poId,
      'supplierName': supplierName,
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
    };
  }
}
