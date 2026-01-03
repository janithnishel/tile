import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';

class MaterialSaleState {
  final List<MaterialSaleDocument> materialSales;
  final bool isLoading;
  final bool isLoadingMore; // For infinite scroll loading
  final String? errorMessage;
  final MaterialSaleDocument? selectedMaterialSale;

  // Pagination info
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final bool hasMoreData;

  const MaterialSaleState({
    this.materialSales = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.selectedMaterialSale,
    this.currentPage = 0,
    this.totalPages = 0,
    this.totalRecords = 0,
    this.hasMoreData = true,
  });

  MaterialSaleState copyWith({
    List<MaterialSaleDocument>? materialSales,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    MaterialSaleDocument? selectedMaterialSale,
    int? currentPage,
    int? totalPages,
    int? totalRecords,
    bool? hasMoreData,
  }) {
    return MaterialSaleState(
      materialSales: materialSales ?? this.materialSales,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedMaterialSale: selectedMaterialSale ?? this.selectedMaterialSale,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalRecords: totalRecords ?? this.totalRecords,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}
