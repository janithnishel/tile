// lib/models/quotation_Invoice_screen/material_sale/material_sale_enums.dart

enum MaterialSaleStatus {
  pending,    // Just created, no payment
  partial,    // Advance payment made
  paid,       // Fully paid
  cancelled,  // Cancelled sale
}

enum MaterialCategory {
  floorTile,
  wallTile,
  granite,
  marble,
  porcelain,
  ceramic,
  mosaic,
  other,
}

extension MaterialSaleStatusExtension on MaterialSaleStatus {
  String get displayName {
    switch (this) {
      case MaterialSaleStatus.pending:
        return 'Pending';
      case MaterialSaleStatus.partial:
        return 'Partial Paid';
      case MaterialSaleStatus.paid:
        return 'Paid';
      case MaterialSaleStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get color {
    switch (this) {
      case MaterialSaleStatus.pending:
        return 'orange';
      case MaterialSaleStatus.partial:
        return 'blue';
      case MaterialSaleStatus.paid:
        return 'green';
      case MaterialSaleStatus.cancelled:
        return 'red';
    }
  }
}

extension MaterialCategoryExtension on MaterialCategory {
  String get displayName {
    switch (this) {
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

  String get icon {
    switch (this) {
      case MaterialCategory.floorTile:
        return '🏠';
      case MaterialCategory.wallTile:
        return '🧱';
      case MaterialCategory.granite:
        return '⬛';
      case MaterialCategory.marble:
        return '⬜';
      case MaterialCategory.porcelain:
        return '🔲';
      case MaterialCategory.ceramic:
        return '🔳';
      case MaterialCategory.mosaic:
        return '🎨';
      case MaterialCategory.other:
        return '📦';
    }
  }
}
