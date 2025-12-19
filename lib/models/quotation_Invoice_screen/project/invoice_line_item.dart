import 'item_description.dart';

class InvoiceLineItem {
  ItemDescription item;
  double quantity;
  String? customDescription;
  bool isOriginalQuotationItem;
  bool isSiteVisitPaid; // Track if site visit is paid (affects amount calculation)

  InvoiceLineItem({
    required this.item,
    this.quantity = 0,
    this.customDescription,
    this.isOriginalQuotationItem = true,
    this.isSiteVisitPaid = false, // Default to unpaid
  });

  // Factory constructor for JSON deserialization
  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItem(
      item: ItemDescription.fromJson(json['item'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      customDescription: json['customDescription'] as String?,
      isOriginalQuotationItem: json['isOriginalQuotationItem'] as bool? ?? true,
      isSiteVisitPaid: json['isSiteVisitPaid'] as bool? ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'item': item.toJson(),
      'quantity': quantity,
      if (customDescription != null) 'customDescription': customDescription,
      'isOriginalQuotationItem': isOriginalQuotationItem,
      'isSiteVisitPaid': isSiteVisitPaid,
    };
  }

  double get amount {
    final baseAmount = quantity * item.sellingPrice;
    // For site visit items that are paid, show negative amount
    if (item.type == ItemType.service &&
        item.name.toLowerCase().contains('site visit') &&
        isSiteVisitPaid) {
      return -baseAmount;
    }
    return baseAmount;
  }

  // Helper to get display name
  String get displayName {
    if (item.name == 'Other (Custom Item)' && customDescription != null) {
      return customDescription!;
    }
    return item.name;
  }
}
