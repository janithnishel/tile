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

  double get amount => quantity * item.sellingPrice;

  // Helper to get display name
  String get displayName {
    if (item.name == 'Other (Custom Item)' && customDescription != null) {
      return customDescription!;
    }
    return item.name;
  }
}