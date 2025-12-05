// lib/data/material_sale_data.dart


// ============================================
// MOCK MATERIAL SALES DATA
// ============================================

import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sales_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/payment_record.dart';

List<MaterialSaleDocument> materialSaleDocuments = [
  MaterialSaleDocument(
    invoiceNumber: '1001',
    saleDate: DateTime.now().subtract(const Duration(days: 2)),
    customerName: 'Kasun Perera',
    customerPhone: '0771234567',
    customerAddress: 'No. 45, Galle Road, Colombo 03',
    items: [
      MaterialSaleItem(
        category: MaterialCategory.floorTile,
        colorCode: 'FT-001-WHT',
        productName: 'Classic White Floor Tile',
        plank: 10,
        sqftPerPlank: 4.5,
        totalSqft: 45,
        unitPrice: 350,
        amount: 15750,
        costPerSqft: 280,
        totalCost: 12600,
      ),
    ],
    paymentHistory: [
      PaymentRecord(15750, DateTime.now().subtract(const Duration(days: 2)),
          description: 'Full Payment - Cash'),
    ],
    status: MaterialSaleStatus.paid,
  ),
  MaterialSaleDocument(
    invoiceNumber: '1002',
    saleDate: DateTime.now().subtract(const Duration(days: 1)),
    customerName: 'Nimal Silva',
    customerPhone: '0769876543',
    customerAddress: 'No. 78, Kandy Road, Kadawatha',
    items: [
      MaterialSaleItem(
        category: MaterialCategory.wallTile,
        colorCode: 'WT-022-BLU',
        productName: 'Ocean Blue Wall Tile',
        plank: 15,
        sqftPerPlank: 3.2,
        totalSqft: 48,
        unitPrice: 420,
        amount: 20160,
        costPerSqft: 320,
        totalCost: 15360,
      ),
      MaterialSaleItem(
        category: MaterialCategory.ceramic,
        colorCode: 'CR-105-BGE',
        productName: 'Beige Ceramic Border',
        plank: 5,
        sqftPerPlank: 2.0,
        totalSqft: 10,
        unitPrice: 550,
        amount: 5500,
        costPerSqft: 400,
        totalCost: 4000,
      ),
    ],
    paymentHistory: [
      PaymentRecord(10000, DateTime.now().subtract(const Duration(days: 1)),
          description: 'Advance Payment'),
    ],
    status: MaterialSaleStatus.partial,
  ),
  MaterialSaleDocument(
    invoiceNumber: '1003',
    saleDate: DateTime.now(),
    customerName: 'Sunil Fernando',
    customerPhone: '0712345678',
    items: [
      MaterialSaleItem(
        category: MaterialCategory.granite,
        colorCode: 'GR-050-BLK',
        productName: 'Black Galaxy Granite',
        plank: 8,
        sqftPerPlank: 5.0,
        totalSqft: 40,
        unitPrice: 850,
        amount: 34000,
        costPerSqft: 650,
        totalCost: 26000,
      ),
    ],
    paymentHistory: [],
    status: MaterialSaleStatus.pending,
  ),
];

// ============================================
// PRODUCT CATALOG (for dropdown selection)
// ============================================

class ProductCatalogItem {
  final String code;
  final String name;
  final MaterialCategory category;
  final double sqftPerPlank;
  final double sellingPrice;
  final double costPrice;

  const ProductCatalogItem({
    required this.code,
    required this.name,
    required this.category,
    required this.sqftPerPlank,
    required this.sellingPrice,
    required this.costPrice,
  });
}

final List<ProductCatalogItem> productCatalog = [
  // Floor Tiles
  ProductCatalogItem(
    code: 'FT-001-WHT',
    name: 'Classic White Floor Tile',
    category: MaterialCategory.floorTile,
    sqftPerPlank: 4.5,
    sellingPrice: 350,
    costPrice: 280,
  ),
  ProductCatalogItem(
    code: 'FT-002-GRY',
    name: 'Modern Grey Floor Tile',
    category: MaterialCategory.floorTile,
    sqftPerPlank: 4.5,
    sellingPrice: 380,
    costPrice: 300,
  ),
  ProductCatalogItem(
    code: 'FT-003-BEG',
    name: 'Natural Beige Floor Tile',
    category: MaterialCategory.floorTile,
    sqftPerPlank: 4.5,
    sellingPrice: 365,
    costPrice: 290,
  ),
  
  // Wall Tiles
  ProductCatalogItem(
    code: 'WT-021-WHT',
    name: 'Glossy White Wall Tile',
    category: MaterialCategory.wallTile,
    sqftPerPlank: 3.2,
    sellingPrice: 400,
    costPrice: 310,
  ),
  ProductCatalogItem(
    code: 'WT-022-BLU',
    name: 'Ocean Blue Wall Tile',
    category: MaterialCategory.wallTile,
    sqftPerPlank: 3.2,
    sellingPrice: 420,
    costPrice: 320,
  ),
  
  // Granite
  ProductCatalogItem(
    code: 'GR-050-BLK',
    name: 'Black Galaxy Granite',
    category: MaterialCategory.granite,
    sqftPerPlank: 5.0,
    sellingPrice: 850,
    costPrice: 650,
  ),
  ProductCatalogItem(
    code: 'GR-051-RED',
    name: 'Red Dragon Granite',
    category: MaterialCategory.granite,
    sqftPerPlank: 5.0,
    sellingPrice: 920,
    costPrice: 720,
  ),
  
  // Ceramic
  ProductCatalogItem(
    code: 'CR-105-BGE',
    name: 'Beige Ceramic Border',
    category: MaterialCategory.ceramic,
    sqftPerPlank: 2.0,
    sellingPrice: 550,
    costPrice: 400,
  ),
  
  // Porcelain
  ProductCatalogItem(
    code: 'PR-200-MAT',
    name: 'Matt Porcelain Large',
    category: MaterialCategory.porcelain,
    sqftPerPlank: 6.0,
    sellingPrice: 680,
    costPrice: 520,
  ),
];

// Get products by category
List<ProductCatalogItem> getProductsByCategory(MaterialCategory category) {
  return productCatalog.where((p) => p.category == category).toList();
}

// Get all categories with products
List<MaterialCategory> get availableCategories {
  return productCatalog.map((p) => p.category).toSet().toList();
}