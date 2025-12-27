import 'quotation_item.dart';

class ApprovedQuotation {
  final String quotationId;
  final String customerName;
  final String projectTitle;
  final DateTime approvedDate;
  final double totalAmount;
  final List<QuotationItem> items;

  ApprovedQuotation({
    required this.quotationId,
    required this.customerName,
    required this.projectTitle,
    required this.approvedDate,
    required this.totalAmount,
    required this.items,
  });

  String get displayId => 'QUO-$quotationId';

  String get displayName => '$displayId | $customerName - $projectTitle';

  // Get items that haven't been ordered yet
  List<QuotationItem> get availableItems =>
      items.where((item) => !item.isOrdered).toList();

  // Check if all items are ordered
  bool get allItemsOrdered => items.every((item) => item.isOrdered);
}

class ApprovedMaterialSale {
  final String saleId;
  final String customerName;
  final String projectTitle;
  final DateTime approvedDate;
  final double totalAmount;
  final List<QuotationItem> items;

  ApprovedMaterialSale({
    required this.saleId,
    required this.customerName,
    required this.projectTitle,
    required this.approvedDate,
    required this.totalAmount,
    required this.items,
  });

  String get displayId => 'MS-$saleId';

  String get displayName => '$displayId | $customerName - $projectTitle';

  // Get items that haven't been ordered yet
  List<QuotationItem> get availableItems =>
      items.where((item) => !item.isOrdered).toList();

  // Check if all items are ordered
  bool get allItemsOrdered => items.every((item) => item.isOrdered);
}
