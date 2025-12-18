import 'supplier.dart';
import 'po_item.dart';

class PurchaseOrder {
  final String? id; // MongoDB ObjectId
  final String poId;
  final String quotationId;
  final String customerName;
  final Supplier supplier;
  final DateTime orderDate;
  final DateTime? expectedDelivery;
  String status;
  final List<POItem> items;
  String? invoiceImagePath;
  String? notes;

  PurchaseOrder({
    this.id,
    required this.poId,
    required this.quotationId,
    required this.customerName,
    required this.supplier,
    required this.orderDate,
    this.expectedDelivery,
    this.status = 'Draft',
    required this.items,
    this.invoiceImagePath,
    this.notes,
  });

  // Factory constructor for JSON deserialization
  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['_id'] as String?,
      poId: json['poId']?.toString() ?? '',
      quotationId: json['quotationId']?.toString() ?? '',
      customerName: json['customerName'] as String? ?? '',
      supplier: Supplier.fromJson(json['supplier'] as Map<String, dynamic>),
      orderDate: DateTime.parse(json['orderDate'] as String? ?? DateTime.now().toIso8601String()),
      expectedDelivery: json['expectedDelivery'] != null
          ? DateTime.parse(json['expectedDelivery'] as String)
          : null,
      status: json['status'] as String? ?? 'Draft',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => POItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      invoiceImagePath: json['invoiceImagePath'] as String?,
      notes: json['notes'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'poId': poId,
      'quotationId': quotationId,
      'customerName': customerName,
      'supplier': supplier.id, // Send only the supplier ID, not the full object
      'orderDate': orderDate.toIso8601String(),
      if (expectedDelivery != null) 'expectedDelivery': expectedDelivery!.toIso8601String(),
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      if (invoiceImagePath != null) 'invoiceImagePath': invoiceImagePath,
      if (notes != null) 'notes': notes,
    };
  }

  // Total amount calculation
  double get totalAmount =>
      items.fold(0, (sum, item) => sum + item.totalAmount);

  // Display quotation ID
  String get displayQuotationId => 'QUO-$quotationId';

  // Check status
  bool get isDraft => status == 'Draft';
  bool get isOrdered => status == 'Ordered';
  bool get isDelivered => status == 'Delivered';
  bool get isPaid => status == 'Paid';

  // Get next status
  String get nextStatus {
    switch (status) {
      case 'Draft':
        return 'Ordered';
      case 'Ordered':
        return 'Delivered';
      case 'Delivered':
        return 'Paid';
      default:
        return status;
    }
  }

  // Get next action text
  String get nextActionText {
    switch (status) {
      case 'Draft':
        return 'Place Order';
      case 'Ordered':
        return 'Mark Delivered';
      case 'Delivered':
        return 'Mark Paid';
      default:
        return 'Completed';
    }
  }

  // Items display text
  String get itemsDisplayText =>
      items.map((i) => i.displayText).join(', ');

  // Days until expected delivery
  int? get daysUntilDelivery {
    if (expectedDelivery == null) return null;
    return expectedDelivery!.difference(DateTime.now()).inDays;
  }
}
