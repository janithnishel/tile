import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/models/purchase_order_screen/purchase_order.dart';
import 'package:tilework/repositories/purchase_order/purchase_order_repository.dart';
import 'purchase_order_state.dart';

class PurchaseOrderCubit extends Cubit<PurchaseOrderState> {
  final PurchaseOrderRepository _purchaseOrderRepository;
  final AuthCubit _authCubit;

  PurchaseOrderCubit(this._purchaseOrderRepository, this._authCubit) : super(PurchaseOrderState());

  // Helper method to get current token
  String? get _currentToken {
    if (_authCubit.state is AuthAuthenticated) {
      final token = (_authCubit.state as AuthAuthenticated).token;
      debugPrint('🔑 PurchaseOrderCubit: Retrieved token: ${token.substring(0, min(20, token.length))}...');
      return token;
    }
    debugPrint('❌ PurchaseOrderCubit: No valid token found. Auth state: ${_authCubit.state.runtimeType}');
    return null;
  }

  // 1. 🔄 Load Purchase Orders
  Future<void> loadPurchaseOrders({Map<String, String>? queryParams}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 PurchaseOrderCubit: Starting to load purchase orders...');
      final loadedPurchaseOrders = await _purchaseOrderRepository.fetchPurchaseOrders(
        queryParams: queryParams,
        token: _currentToken,
      );
      debugPrint('📦 PurchaseOrderCubit: Loaded ${loadedPurchaseOrders.length} purchase orders');
      emit(state.copyWith(purchaseOrders: loadedPurchaseOrders, isLoading: false));
      debugPrint('✅ PurchaseOrderCubit: Successfully updated state with purchase orders');
    } catch (e) {
      debugPrint('💥 PurchaseOrderCubit: Failed to load purchase orders: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load purchase orders. Please check your connection.',
      ));
    }
  }

  // 2. ➕ Create Purchase Order
  Future<void> createPurchaseOrder(PurchaseOrder purchaseOrder) async {
    try {
      debugPrint('📝 PurchaseOrderCubit: Creating purchase order...');

      // Validate purchase order data before sending
      if (purchaseOrder.customerName.trim().isEmpty) {
        throw Exception('Customer name is required');
      }
      if (purchaseOrder.items.isEmpty) {
        throw Exception('At least one item is required');
      }
      if (purchaseOrder.items.any((item) => item.quantity <= 0)) {
        throw Exception('All items must have quantity greater than 0');
      }

      debugPrint('✅ PurchaseOrderCubit: Validation passed, sending to backend...');
      final createdPurchaseOrder = await _purchaseOrderRepository.createPurchaseOrder(
        purchaseOrder,
        token: _currentToken,
      );
      debugPrint('✨ PurchaseOrderCubit: Purchase order created successfully: ${createdPurchaseOrder.poId}');

      // Add to local state
      final updatedList = List<PurchaseOrder>.from(state.purchaseOrders)..insert(0, createdPurchaseOrder);
      emit(state.copyWith(purchaseOrders: updatedList));
      debugPrint('📦 PurchaseOrderCubit: Updated local state with ${updatedList.length} purchase orders');
    } catch (e) {
      debugPrint('💥 PurchaseOrderCubit: Failed to create purchase order: $e');
      emit(state.copyWith(errorMessage: 'Failed to create purchase order: ${e.toString()}'));
      rethrow;
    }
  }

  // 3. ✏️ Update Purchase Order
  Future<void> updatePurchaseOrder(PurchaseOrder purchaseOrder) async {
    try {
      final updatedPurchaseOrder = await _purchaseOrderRepository.updatePurchaseOrder(
        purchaseOrder,
        token: _currentToken,
      );

      // Update local state
      final updatedList = state.purchaseOrders.map((po) {
        return po.id == updatedPurchaseOrder.id ? updatedPurchaseOrder : po;
      }).toList();

      emit(state.copyWith(purchaseOrders: updatedList));
    } catch (e) {
      debugPrint('💥 PurchaseOrderCubit: Failed to update purchase order: $e');
      emit(state.copyWith(errorMessage: 'Failed to update purchase order.'));
      rethrow;
    }
  }

  // 4. 🗑️ Delete Purchase Order
  Future<void> deletePurchaseOrder(String id) async {
    try {
      await _purchaseOrderRepository.deletePurchaseOrder(id, token: _currentToken);

      // Remove from local state
      final updatedList = state.purchaseOrders.where((po) => po.id != id).toList();
      emit(state.copyWith(purchaseOrders: updatedList));
    } catch (e) {
      debugPrint('💥 PurchaseOrderCubit: Failed to delete purchase order: $e');
      emit(state.copyWith(errorMessage: 'Failed to delete purchase order.'));
      rethrow;
    }
  }

  // 5. 🔄 Update Purchase Order Status
  Future<void> updatePurchaseOrderStatus(String id, Map<String, dynamic> statusData) async {
    try {
      final updatedPurchaseOrder = await _purchaseOrderRepository.updatePurchaseOrderStatus(
        id,
        statusData,
        token: _currentToken,
      );

      // Update local state
      final updatedList = state.purchaseOrders.map((po) {
        return po.id == updatedPurchaseOrder.id ? updatedPurchaseOrder : po;
      }).toList();

      emit(state.copyWith(purchaseOrders: updatedList));
    } catch (e) {
      debugPrint('💥 PurchaseOrderCubit: Failed to update purchase order status: $e');
      emit(state.copyWith(errorMessage: 'Failed to update purchase order status.'));
      rethrow;
    }
  }

  // 6. 🎯 Select Purchase Order
  void selectPurchaseOrder(PurchaseOrder? purchaseOrder) {
    emit(state.copyWith(selectedPurchaseOrder: purchaseOrder));
  }

  // 7. 🧹 Clear Error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
