import 'item_description.dart';

class InvoiceLineItem {
  ItemDescription item;
  double quantity;
  String? customDescription;
  bool isOriginalQuotationItem;

  InvoiceLineItem({
    required this.item,
    this.quantity = 0,
    this.customDescription,
    this.isOriginalQuotationItem = true,
  });

  // Factory constructor for JSON deserialization
  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItem(
      item: ItemDescription.fromJson(json['item'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      customDescription: json['customDescription'] as String?,
      isOriginalQuotationItem: json['isOriginalQuotationItem'] as bool? ?? true,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'item': item.toJson(),
      'quantity': quantity,
      if (customDescription != null) 'customDescription': customDescription,
      'isOriginalQuotationItem': isOriginalQuotationItem,
    };
  }

  double get amount => quantity * item.sellingPrice;

  // Helper to get display name
  String get displayName {
    if (item.name == 'Other (Custom Item)' && customDescription != null) {
      return customDescription!;
    }
    return item.name;
  }
}
