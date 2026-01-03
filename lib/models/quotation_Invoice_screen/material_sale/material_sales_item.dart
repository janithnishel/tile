import 'package:tilework/models/category_model.dart';

class MaterialSaleItem {
  String categoryId;      // Reference to CategoryModel.id
  String categoryName;    // Display name from CategoryModel.name
  String itemId;          // Reference to ItemModel.id (if selected from catalog)
  String colorCode;
  String productName;
  double plank;           // Number of planks/boxes
  double sqftPerPlank;    // Sqft per plank (for calculation)
  double totalSqft;       // Total square feet
  double unitPrice;       // Price per sqft
  double amount;          // Total sale amount
  double costPerSqft;     // Cost per sqft
  double totalCost;       // Total cost

  MaterialSaleItem({
    this.categoryId = '',
    this.categoryName = '',
    this.itemId = '',
    this.colorCode = '',
    this.productName = '',
    this.plank = 0,
    this.sqftPerPlank = 0,
    this.totalSqft = 0,
    this.unitPrice = 0,
    this.amount = 0,
    this.costPerSqft = 0,
    this.totalCost = 0,
  });

  // Calculate total sqft from plank
  void calculateSqft() {
    if (plank > 0 && sqftPerPlank > 0) {
      totalSqft = plank * sqftPerPlank;
    }
  }

  // Calculate amount from sqft and unit price
  void calculateAmount() {
    if (totalSqft > 0 && unitPrice > 0) {
      amount = totalSqft * unitPrice;
    }
  }

  // Calculate total cost
  void calculateCost() {
    if (totalSqft > 0 && costPerSqft > 0) {
      totalCost = totalSqft * costPerSqft;
    }
  }

  // Get profit
  double get profit => amount - totalCost;

  // Get profit percentage
  double get profitPercentage {
    if (totalCost > 0) {
      return ((amount - totalCost) / totalCost) * 100;
    }
    return 0;
  }

  // Factory constructor for JSON deserialization
  factory MaterialSaleItem.fromJson(Map<String, dynamic> json) {
    return MaterialSaleItem(
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? json['category'] as String? ?? '',
      itemId: json['itemId'] as String? ?? '',
      colorCode: json['colorCode'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      plank: (json['plank'] as num?)?.toDouble() ?? 0,
      sqftPerPlank: (json['sqftPerPlank'] as num?)?.toDouble() ?? 0,
      totalSqft: (json['totalSqft'] as num?)?.toDouble() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      costPerSqft: (json['costPerSqft'] as num?)?.toDouble() ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'itemId': itemId,
      'colorCode': colorCode,
      'productName': productName,
      'plank': plank,
      'sqftPerPlank': sqftPerPlank,
      'totalSqft': totalSqft,
      'unitPrice': unitPrice,
      'amount': amount,
      'costPerSqft': costPerSqft,
      'totalCost': totalCost,
    };
  }

  // Copy method
  MaterialSaleItem copyWith({
    String? categoryId,
    String? categoryName,
    String? itemId,
    String? colorCode,
    String? productName,
    double? plank,
    double? sqftPerPlank,
    double? totalSqft,
    double? unitPrice,
    double? amount,
    double? costPerSqft,
    double? totalCost,
  }) {
    return MaterialSaleItem(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      itemId: itemId ?? this.itemId,
      colorCode: colorCode ?? this.colorCode,
      productName: productName ?? this.productName,
      plank: plank ?? this.plank,
      sqftPerPlank: sqftPerPlank ?? this.sqftPerPlank,
      totalSqft: totalSqft ?? this.totalSqft,
      unitPrice: unitPrice ?? this.unitPrice,
      amount: amount ?? this.amount,
      costPerSqft: costPerSqft ?? this.costPerSqft,
      totalCost: totalCost ?? this.totalCost,
    );
  }
}
