// lib/models/quotation_Invoice_screen/material_sale/material_sales_item.dart

import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_enums.dart';

class MaterialSaleItem {
  MaterialCategory category;
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
    this.category = MaterialCategory.floorTile,
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
      category: _categoryFromString(json['category'] as String? ?? 'Floor Tile'),
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
      'category': _categoryToString(category),
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

  // Helper method to convert category string to enum
  static MaterialCategory _categoryFromString(String category) {
    switch (category) {
      case 'Floor Tile':
        return MaterialCategory.floorTile;
      case 'Wall Tile':
        return MaterialCategory.wallTile;
      case 'Granite':
        return MaterialCategory.granite;
      case 'Marble':
        return MaterialCategory.marble;
      case 'Porcelain':
        return MaterialCategory.porcelain;
      case 'Ceramic':
        return MaterialCategory.ceramic;
      case 'Mosaic':
        return MaterialCategory.mosaic;
      case 'Other':
        return MaterialCategory.other;
      default:
        return MaterialCategory.floorTile;
    }
  }

  // Helper method to convert category enum to string
  static String _categoryToString(MaterialCategory category) {
    switch (category) {
      case MaterialCategory.floorTile:
        return 'Floor Tile';
      case MaterialCategory.wallTile:
        return 'Wall Tile';
      case MaterialCategory.granite:
        return 'Granite';
      case MaterialCategory.marble:
        return 'Marble';
      case MaterialCategory.porcelain:
        return 'Porcelain';
      case MaterialCategory.ceramic:
        return 'Ceramic';
      case MaterialCategory.mosaic:
        return 'Mosaic';
      case MaterialCategory.other:
        return 'Other';
    }
  }

  // Copy method
  MaterialSaleItem copyWith({
    MaterialCategory? category,
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
      category: category ?? this.category,
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
