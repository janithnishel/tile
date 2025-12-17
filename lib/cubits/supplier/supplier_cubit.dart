import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/models/purchase_order_screen/supplier.dart';
import 'package:tilework/repositories/supplier/supplier_repository.dart';
import 'supplier_state.dart';

class SupplierCubit extends Cubit<SupplierState> {
  final SupplierRepository _supplierRepository;
  final AuthCubit _authCubit;

  SupplierCubit(this._supplierRepository, this._authCubit) : super(const SupplierState()) {
    // Listen to auth state changes
    _authCubit.stream.listen((authState) {
      if (authState is AuthAuthenticated && state.suppliers.isEmpty) {
        // Load suppliers when user logs in and we haven't loaded data yet
        loadSuppliers();
      }
    });

    // Only load if already authenticated
    if (_authCubit.state is AuthAuthenticated) {
      loadSuppliers();
    }
  }

  // Helper method to get current token
  String? get _currentToken {
    if (_authCubit.state is AuthAuthenticated) {
      final token = (_authCubit.state as AuthAuthenticated).token;
      debugPrint('🔑 SupplierCubit: Retrieved token: ${token.substring(0, min(20, token.length))}...');
      return token;
    }
    debugPrint('❌ SupplierCubit: No valid token found. Auth state: ${_authCubit.state.runtimeType}');
    return null;
  }

  // 1. Load Suppliers
  Future<void> loadSuppliers({Map<String, String>? queryParams}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 SupplierCubit: Loading suppliers...');
      final suppliers = await _supplierRepository.getSuppliers(
        token: _currentToken,
        search: queryParams?['search'],
        category: queryParams?['category'],
      );
      debugPrint('📦 SupplierCubit: Loaded ${suppliers.length} suppliers');
      emit(state.copyWith(suppliers: suppliers, isLoading: false));
    } catch (e) {
      debugPrint('💥 SupplierCubit: Failed to load suppliers: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load suppliers. Please check your connection.',
      ));
    }
  }

  // 2. Create Supplier
  Future<Supplier> createSupplier(Supplier supplier) async {
    try {
      debugPrint('📝 SupplierCubit: Creating supplier...');

      // Basic validation
      if (supplier.name.trim().isEmpty) {
        throw Exception('Supplier name is required');
      }
      if (supplier.phone.trim().isEmpty) {
        throw Exception('Phone number is required');
      }

      debugPrint('✅ SupplierCubit: Validation passed, creating supplier...');
      final createdSupplier = await _supplierRepository.createSupplier(supplier, token: _currentToken);
      debugPrint('✨ SupplierCubit: Supplier created: ${createdSupplier.name}');

      // Add to local state
      final updatedList = List<Supplier>.from(state.suppliers)..insert(0, createdSupplier);
      emit(state.copyWith(suppliers: updatedList));
      debugPrint('📦 SupplierCubit: Updated local state with ${updatedList.length} suppliers');

      return createdSupplier;
    } catch (e) {
      debugPrint('💥 SupplierCubit: Failed to create supplier: $e');
      emit(state.copyWith(errorMessage: 'Failed to create supplier: ${e.toString()}'));
      rethrow;
    }
  }

  // 3. Update Supplier
  Future<Supplier> updateSupplier(Supplier supplier) async {
    try {
      final updatedSupplier = await _supplierRepository.updateSupplier(supplier.id, supplier, token: _currentToken);

      // Update local state
      final updatedList = state.suppliers.map((s) {
        return s.id == updatedSupplier.id ? updatedSupplier : s;
      }).toList();

      emit(state.copyWith(suppliers: updatedList));
      return updatedSupplier;
    } catch (e) {
      debugPrint('💥 SupplierCubit: Failed to update supplier: $e');
      emit(state.copyWith(errorMessage: 'Failed to update supplier.'));
      rethrow;
    }
  }

  // 4. Delete Supplier
  Future<void> deleteSupplier(String id) async {
    try {
      await _supplierRepository.deleteSupplier(id, token: _currentToken);

      // Remove from local state
      final updatedList = state.suppliers.where((supplier) => supplier.id != id).toList();
      emit(state.copyWith(suppliers: updatedList));
    } catch (e) {
      debugPrint('💥 SupplierCubit: Failed to delete supplier: $e');
      emit(state.copyWith(errorMessage: 'Failed to delete supplier.'));
      rethrow;
    }
  }

  // 5. Get Single Supplier
  Future<Supplier> getSupplier(String id) async {
    try {
      return await _supplierRepository.getSupplier(id, token: _currentToken);
    } catch (e) {
      debugPrint('💥 SupplierCubit: Failed to get supplier: $e');
      emit(state.copyWith(errorMessage: 'Failed to get supplier details.'));
      rethrow;
    }
  }

  // 6. Select Supplier
  void selectSupplier(Supplier? supplier) {
    emit(state.copyWith(selectedSupplier: supplier));
  }

  // 7. Clear Error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
