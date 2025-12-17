import 'package:tilework/models/purchase_order_screen/supplier.dart';

class SupplierState {
  final List<Supplier> suppliers;
  final bool isLoading;
  final String? errorMessage;
  final Supplier? selectedSupplier;

  const SupplierState({
    this.suppliers = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedSupplier,
  });

  SupplierState copyWith({
    List<Supplier>? suppliers,
    bool? isLoading,
    String? errorMessage,
    Supplier? selectedSupplier,
  }) {
    return SupplierState(
      suppliers: suppliers ?? this.suppliers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedSupplier: selectedSupplier ?? this.selectedSupplier,
    );
  }
}
