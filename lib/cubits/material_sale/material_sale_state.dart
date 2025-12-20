class MaterialSaleState {
  final List<dynamic> materialSales;
  final bool isLoading;
  final String? errorMessage;
  final dynamic selectedMaterialSale;

  const MaterialSaleState({
    this.materialSales = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedMaterialSale,
  });

  MaterialSaleState copyWith({
    List<dynamic>? materialSales,
    bool? isLoading,
    String? errorMessage,
    dynamic selectedMaterialSale,
  }) {
    return MaterialSaleState(
      materialSales: materialSales ?? this.materialSales,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedMaterialSale: selectedMaterialSale ?? this.selectedMaterialSale,
    );
  }
}
