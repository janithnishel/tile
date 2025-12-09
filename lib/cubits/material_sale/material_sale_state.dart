import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';

class MaterialSaleState {
  final List<MaterialSaleDocument> materialSales;
  final bool isLoading;
  final String? errorMessage;
  final MaterialSaleDocument? selectedMaterialSale;

  const MaterialSaleState({
    this.materialSales = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedMaterialSale,
  });

  MaterialSaleState copyWith({
    List<MaterialSaleDocument>? materialSales,
    bool? isLoading,
    String? errorMessage,
    MaterialSaleDocument? selectedMaterialSale,
  }) {
    return MaterialSaleState(
      materialSales: materialSales ?? this.materialSales,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedMaterialSale: selectedMaterialSale ?? this.selectedMaterialSale,
    );
  }
}
