import 'supplier.dart';
import 'po_item.dart';

class PurchaseOrder {
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