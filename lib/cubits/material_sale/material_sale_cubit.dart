import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';
import 'package:tilework/repositories/material_sale/material_sale_repository.dart';
import 'material_sale_state.dart';

class MaterialSaleCubit extends Cubit<MaterialSaleState> {
  final MaterialSaleRepository _materialSaleRepository;
  final AuthCubit _authCubit;

  MaterialSaleCubit(this._materialSaleRepository, this._authCubit) : super(const MaterialSaleState()) {
    loadMaterialSales();
  }

  // Helper method to get current token
  String? get _currentToken {
    if (_authCubit.state is AuthAuthenticated) {
      return (_authCubit.state as AuthAuthenticated).token;
    }
    return null;
  }

  // 1. Load Material Sales
  Future<void> loadMaterialSales({Map<String, String>? queryParams}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 MaterialSaleCubit: Loading material sales...');
      final materialSales = await _materialSaleRepository.fetchMaterialSales(queryParams: queryParams);
      debugPrint('📦 MaterialSaleCubit: Loaded ${materialSales.length} material sales');
      emit(state.copyWith(materialSales: materialSales, isLoading: false));
    } catch (e) {
      debugPrint('💥 MaterialSaleCubit: Failed to load material sales: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load material sales. Please check your connection.',
      ));
    }
  }

  // 2. Create Material Sale
  Future<void> createMaterialSale(MaterialSaleDocument materialSale) async {
    try {
      debugPrint('📝 MaterialSaleCubit: Creating material sale...');

      // Basic validation
      if (materialSale.customerName.trim().isEmpty) {
        throw Exception('Customer name is required');
      }
      if (materialSale.customerPhone.trim().isEmpty) {
        throw Exception('Customer phone is required');
      }
      if (materialSale.items.isEmpty) {
        throw Exception('At least one item is required');
      }

      debugPrint('✅ MaterialSaleCubit: Validation passed, creating material sale...');
      final createdSale = await _materialSaleRepository.createMaterialSale(materialSale);
      debugPrint('✨ MaterialSaleCubit: Material sale created: ${createdSale.invoiceNumber}');

      // Add to local state
      final updatedList = List<MaterialSaleDocument>.from(state.materialSales)..insert(0, createdSale);
      emit(state.copyWith(materialSales: updatedList));
      debugPrint('📦 MaterialSaleCubit: Updated local state with ${updatedList.length} material sales');
    } catch (e) {
      debugPrint('💥 MaterialSaleCubit: Failed to create material sale: $e');
      emit(state.copyWith(errorMessage: 'Failed to create material sale: ${e.toString()}'));
      rethrow;
    }
  }

  // 3. Update Material Sale
  Future<void> updateMaterialSale(MaterialSaleDocument materialSale) async {
    try {
      final updatedSale = await _materialSaleRepository.updateMaterialSale(materialSale);

      // Update local state
      final updatedList = state.materialSales.map((sale) {
        return sale.id == updatedSale.id ? updatedSale : sale;
      }).toList();

      emit(state.copyWith(materialSales: updatedList));
    } catch (e) {
      debugPrint('💥 MaterialSaleCubit: Failed to update material sale: $e');
      emit(state.copyWith(errorMessage: 'Failed to update material sale.'));
      rethrow;
    }
  }

  // 4. Delete Material Sale
  Future<void> deleteMaterialSale(String id) async {
    try {
      await _materialSaleRepository.deleteMaterialSale(id);

      // Remove from local state
      final updatedList = state.materialSales.where((sale) => sale.id != id).toList();
      emit(state.copyWith(materialSales: updatedList));
    } catch (e) {
      debugPrint('💥 MaterialSaleCubit: Failed to delete material sale: $e');
      emit(state.copyWith(errorMessage: 'Failed to delete material sale.'));
      rethrow;
    }
  }

  // 5. Add Payment
  Future<void> addPayment(String id, Map<String, dynamic> paymentData) async {
    try {
      final updatedSale = await _materialSaleRepository.addPayment(id, paymentData);

      // Update local state
      final updatedList = state.materialSales.map((sale) {
        return sale.id == updatedSale.id ? updatedSale : sale;
      }).toList();

      emit(state.copyWith(materialSales: updatedList));
    } catch (e) {
      debugPrint('💥 MaterialSaleCubit: Failed to add payment: $e');
      emit(state.copyWith(errorMessage: 'Failed to add payment.'));
      rethrow;
    }
  }

  // 6. Update Status
  Future<void> updateStatus(String id, String status) async {
    try {
      final updatedSale = await _materialSaleRepository.updateStatus(id, status);

      // Update local state
      final updatedList = state.materialSales.map((sale) {
        return sale.id == updatedSale.id ? updatedSale : sale;
      }).toList();

      emit(state.copyWith(materialSales: updatedList));
    } catch (e) {
      debugPrint('💥 MaterialSaleCubit: Failed to update status: $e');
      emit(state.copyWith(errorMessage: 'Failed to update status.'));
      rethrow;
    }
  }

  // 7. Select Material Sale
  void selectMaterialSale(MaterialSaleDocument? materialSale) {
    emit(state.copyWith(selectedMaterialSale: materialSale));
  }

  // 8. Clear Error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
