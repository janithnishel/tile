import 'package:equatable/equatable.dart';
import 'package:tilework/models/purchase_order/purchase_order.dart';

class PurchaseOrderState extends Equatable {
  final List<PurchaseOrder> purchaseOrders;
  final bool isLoading;
  final String? errorMessage;
  final PurchaseOrder? selectedPurchaseOrder;

  const PurchaseOrderState({
    this.purchaseOrders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedPurchaseOrder,
  });

  PurchaseOrderState copyWith({
    List<PurchaseOrder>? purchaseOrders,
    bool? isLoading,
    String? errorMessage,
    PurchaseOrder? selectedPurchaseOrder,
  }) {
    return PurchaseOrderState(
      purchaseOrders: purchaseOrders ?? this.purchaseOrders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedPurchaseOrder: selectedPurchaseOrder ?? this.selectedPurchaseOrder,
    );
  }

  @override
  List<Object?> get props => [
    purchaseOrders,
    isLoading,
    errorMessage,
    selectedPurchaseOrder,
  ];
}
