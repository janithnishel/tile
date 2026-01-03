import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';
import 'package:tilework/repositories/material_sale/material_sale_repository.dart';
import 'package:tilework/repositories/customer/customer_repository.dart';
import 'material_sale_state.dart';

class MaterialSaleCubit extends Cubit<MaterialSaleState> {
  final MaterialSaleRepository _materialSaleRepository;
  final CustomerRepository _customerRepository;
  final AuthCubit _authCubit;

  MaterialSaleCubit(this._materialSaleRepository, this._customerRepository, this._authCubit) : super(const MaterialSaleState()) {
    // Listen to auth state changes
    _authCubit.stream.listen((authState) {
      if (authState is AuthAuthenticated && state.materialSales.isEmpty) {
        // Load material sales when user logs in and we haven't loaded data yet
        loadMaterialSales();
      }
    });

    // Only load if already authenticated
    if (_authCubit.state is AuthAuthenticated) {
      loadMaterialSales();
    }
  }

  // Helper method to get current token
  String? get _currentToken {
    if (_authCubit.state is AuthAuthenticated) {
      final token = (_authCubit.state as AuthAuthenticated).token;
      debugPrint('🔑 MaterialSaleCubit: Retrieved token: ${token.substring(0, min(20, token.length))}...');
      return token;
    }
    debugPrint('❌ MaterialSaleCubit: No valid token found. Auth state: ${_authCubit.state.runtimeType}');
    return null;
  }

  // 1. Load Material Sales (initial load - replaces existing data)
  Future<void> loadMaterialSales({
    int page = 1,
    int limit = 20, // Increased default limit for better UX
    String? status,
    String? search,
    String? startDate,
    String? endDate,
    bool resetPagination = false, // New parameter to force pagination reset
  }) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      // Reset pagination state when filters are applied
      currentPage: resetPagination ? 0 : state.currentPage,
      totalPages: resetPagination ? 0 : state.totalPages,
      totalRecords: resetPagination ? 0 : state.totalRecords,
      hasMoreData: resetPagination ? true : state.hasMoreData,
    ));
    try {
      debugPrint('🚀 MaterialSaleCubit: Loading material sales (page $page, reset: $resetPagination)...');
      final response = await _materialSaleRepository.fetchMaterialSales(
        token: _currentToken,
        page: page,
        limit: limit,
        status: status,
        search: search,
        startDate: startDate,
        endDate: endDate,
      );

      // Extract data from paginated response
      final data = response['data'] ?? [];
      final pagination = response['pagination'] ?? {};
      final List<dynamic> rawSales = data is List ? data : [];
      final List<MaterialSaleDocument> materialSales = rawSales.map((item) => MaterialSaleDocument.fromJson(item as Map<String, dynamic>)).toList();

      final currentPage = pagination['page'] ?? page;
      final totalPages = pagination['pages'] ?? 1;
      final totalRecords = pagination['total'] ?? materialSales.length;
      final hasMoreData = currentPage < totalPages;

      debugPrint('📄 MaterialSaleCubit: Loaded ${materialSales.length} material sales (page $currentPage/$totalPages, total: $totalRecords)');
      emit(state.copyWith(
        materialSales: materialSales,
        isLoading: false,
        currentPage: currentPage,
        totalPages: totalPages,
        totalRecords: totalRecords,
        hasMoreData: hasMoreData,
      ));
    } catch (e) {
      debugPrint('💥 MaterialSaleCubit: Failed to load material sales: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load material sales. Please check your connection.',
      ));
    }
  }

  // 1b. Load More Material Sales (infinite scroll - appends to existing data)
  Future<void> loadMoreMaterialSales({
    String? status,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    if (!state.hasMoreData || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    try {
      final nextPage = state.currentPage + 1;
      debugPrint('🚀 MaterialSaleCubit: Loading more material sales (page $nextPage)...');

      final response = await _materialSaleRepository.fetchMaterialSales(
        token: _currentToken,
        page: nextPage,
        limit: 20, // Same limit as initial load
        status: status,
        search: search,
        startDate: startDate,
        endDate: endDate,
      );

      // Extract data from paginated response
      final data = response['data'] ?? [];
      final pagination = response['pagination'] ?? {};
      final List<dynamic> rawSales = data is List ? data : [];
      final List<MaterialSaleDocument> newSales = rawSales.map((item) => MaterialSaleDocument.fromJson(item as Map<String, dynamic>)).toList();

      final currentPage = pagination['page'] ?? nextPage;
      final totalPages = pagination['pages'] ?? state.totalPages;
      final totalRecords = pagination['total'] ?? state.totalRecords;
      final hasMoreData = currentPage < totalPages;

      // Append new sales to existing list
      final updatedList = List<MaterialSaleDocument>.from(state.materialSales)..addAll(newSales);

      debugPrint('📄 MaterialSaleCubit: Loaded ${newSales.length} more sales (page $currentPage/$totalPages, total now: ${updatedList.length})');
      emit(state.copyWith(
        materialSales: updatedList,
        isLoadingMore: false,
        currentPage: currentPage,
        totalPages: totalPages,
        totalRecords: totalRecords,
        hasMoreData: hasMoreData,
      ));
    } catch (e) {
      debugPrint('💥 MaterialSaleCubit: Failed to load more material sales: $e');
      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Failed to load more material sales. Please check your connection.',
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
      final response = await _materialSaleRepository.createMaterialSale(materialSale.toJson(), token: _currentToken);
      final createdSale = MaterialSaleDocument.fromJson(response);
      debugPrint('✨ MaterialSaleCubit: Material sale created: ${createdSale.invoiceNumber}');

      // Refresh the list from API to ensure proper sorting and latest data
      debugPrint('🔄 MaterialSaleCubit: Refreshing material sales list after creation...');
      await loadMaterialSales();
    } catch (e) {
      debugPrint('💥 MaterialSaleCubit: Failed to create material sale: $e');
      emit(state.copyWith(errorMessage: 'Failed to create material sale: ${e.toString()}'));
      rethrow;
    }
  }

  // 3. Update Material Sale
  Future<void> updateMaterialSale(MaterialSaleDocument materialSale) async {
    try {
      debugPrint('🔄 MaterialSaleCubit: Updating material sale with ID: ${materialSale.id}');
      final response = await _materialSaleRepository.updateMaterialSale(materialSale.id!, materialSale.toJson(), token: _currentToken);
      debugPrint('📥 MaterialSaleCubit: Update response received');

      final updatedSale = MaterialSaleDocument.fromJson(response);
      debugPrint('📝 MaterialSaleCubit: Parsed updated sale with ID: ${updatedSale.id}');

      // Update local state
      final updatedList = state.materialSales.map((sale) {
        debugPrint('🔍 Checking sale ID: ${sale.id} against updated ID: ${updatedSale.id}');
        return sale.id! == updatedSale.id! ? updatedSale : sale;
      }).toList();

      emit(state.copyWith(materialSales: updatedList));
      debugPrint('✅ MaterialSaleCubit: Updated local state successfully');
    } catch (e) {
      debugPrint('💥 MaterialSaleCubit: Failed to update material sale: $e');
      emit(state.copyWith(errorMessage: 'Failed to update material sale.'));
      rethrow;
    }
  }

  // 4. Delete Material Sale
  Future<void> deleteMaterialSale(String id) async {
    try {
      await _materialSaleRepository.deleteMaterialSale(id, token: _currentToken);

      // Remove from local state
      final updatedList = state.materialSales.where((sale) => sale.id! != id).toList();
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
      final response = await _materialSaleRepository.addPayment(id, paymentData, token: _currentToken);
      final updatedSale = MaterialSaleDocument.fromJson(response);

      // Update local state
      final updatedList = state.materialSales.map((sale) {
        return sale.id! == updatedSale.id! ? updatedSale : sale;
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
      final response = await _materialSaleRepository.updateStatus(id, status, token: _currentToken);
      final updatedSale = MaterialSaleDocument.fromJson(response);

      // Update local state
      final updatedList = state.materialSales.map((sale) {
        return sale.id! == updatedSale.id! ? updatedSale : sale;
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

  // 8. Search Customer by Phone
  Future<Map<String, dynamic>> searchCustomerByPhone(String phone, {String? token}) async {
    try {
      return await _customerRepository.searchCustomerByPhone(phone, token: token);
    } catch (e) {
      debugPrint('💥 MaterialSaleCubit: Failed to search customer: $e');
      throw Exception('Failed to search customer: $e');
    }
  }

  // 9. Clear Error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
