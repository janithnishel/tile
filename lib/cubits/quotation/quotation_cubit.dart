import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';
import 'package:tilework/repositories/quotation/quotation_repository.dart';
import 'quotation_state.dart';

class QuotationCubit extends Cubit<QuotationState> {
  final QuotationRepository _quotationRepository;
  final AuthCubit _authCubit;

  QuotationCubit(this._quotationRepository, this._authCubit) : super(QuotationState());

  // Helper method to get current token
  String? get _currentToken {
    if (_authCubit.state is AuthAuthenticated) {
      final token = (_authCubit.state as AuthAuthenticated).token;
      debugPrint('🔑 QuotationCubit: Retrieved token: ${token.substring(0, min(20, token.length))}...');
      debugPrint('🔑 QuotationCubit: Token length: ${token.length}');
      debugPrint('🔑 QuotationCubit: Token starts with: ${token.substring(0, 10)}');
      return token;
    }
    debugPrint('❌ QuotationCubit: No valid token found. Auth state: ${_authCubit.state.runtimeType}');
    return null;
  }

  // 1. 🔄 Load Quotations (First page - replaces existing data)
  Future<void> loadQuotations({Map<String, String>? queryParams}) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 1,
      hasMoreData: true,
      quotations: [], // Clear existing data for fresh load
    ));
    try {
      debugPrint('🚀 QuotationCubit: Starting to load quotations...');
      final queryParamsWithPage = {
        'page': '1',
        'limit': '20', // Load 20 items per page
        ...?queryParams,
      };
      final loadedQuotations = await _quotationRepository.fetchQuotations(queryParams: queryParamsWithPage, token: _currentToken);
      debugPrint('📦 QuotationCubit: Loaded ${loadedQuotations.length} quotations');

      // Check if we have more data (if we got exactly the limit, assume there's more)
      final hasMore = loadedQuotations.length >= 20;

      emit(state.copyWith(
        quotations: loadedQuotations,
        isLoading: false,
        currentPage: 1,
        hasMoreData: hasMore,
      ));
      debugPrint('✅ QuotationCubit: Successfully updated state with quotations');
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to load quotations: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load quotations. Please check your connection.',
        hasMoreData: false,
      ));
    }
  }

  // 1.5. 📄 Fetch More Quotations (Infinite scroll - appends to existing data)
  Future<void> fetchMoreQuotations({Map<String, String>? queryParams}) async {
    if (state.isFetchingMoreValue || !state.hasMoreDataValue) return;

    emit(state.copyWith(isFetchingMore: true, errorMessage: null));
    try {
      debugPrint('🚀 QuotationCubit: Fetching more quotations (page ${state.currentPageValue + 1})...');
      final nextPage = state.currentPageValue + 1;
      final queryParamsWithPage = {
        'page': nextPage.toString(),
        'limit': '20',
        ...?queryParams,
      };

      final moreQuotations = await _quotationRepository.fetchQuotations(queryParams: queryParamsWithPage, token: _currentToken);
      debugPrint('📦 QuotationCubit: Loaded ${moreQuotations.length} more quotations');

      // Check if we have more data
      final hasMore = moreQuotations.length >= 20;

      // Append new data to existing list
      final updatedList = List<QuotationDocument>.from(state.quotations)..addAll(moreQuotations);

      emit(state.copyWith(
        quotations: updatedList,
        isFetchingMore: false,
        currentPage: nextPage,
        hasMoreData: hasMore,
      ));
      debugPrint('✅ QuotationCubit: Successfully appended ${moreQuotations.length} more quotations');
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to fetch more quotations: $e');
      emit(state.copyWith(
        isFetchingMore: false,
        errorMessage: 'Failed to load more quotations.',
      ));
    }
  }

  // 2. ➕ Create Quotation
  Future<void> createQuotation(QuotationDocument quotation) async {
    try {
      debugPrint('📝 QuotationCubit: Creating quotation...');

      // Validate quotation data before sending
      if (quotation.customerName.trim().isEmpty) {
        throw Exception('Customer name is required');
      }
      if (quotation.customerPhone.trim().isEmpty) {
        throw Exception('Customer phone is required');
      }
      if (quotation.lineItems.isEmpty) {
        throw Exception('At least one item is required');
      }
      if (quotation.lineItems.any((item) => item.quantity <= 0)) {
        throw Exception('All items must have quantity greater than 0');
      }

      debugPrint('✅ QuotationCubit: Validation passed, sending to backend...');
      final createdQuotation = await _quotationRepository.createQuotation(quotation, token: _currentToken);
      debugPrint('✨ QuotationCubit: Quotation created successfully: ${createdQuotation.documentNumber}');

      // Add to local state
      final updatedList = List<QuotationDocument>.from(state.quotations)..insert(0, createdQuotation);
      emit(state.copyWith(quotations: updatedList));
      debugPrint('📦 QuotationCubit: Updated local state with ${updatedList.length} quotations');
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to create quotation: $e');
      emit(state.copyWith(errorMessage: e.toString()));
      rethrow;
    }
  }

  // 3. ✏️ Update Quotation
  Future<void> updateQuotation(QuotationDocument quotation) async {
    try {
      final updatedQuotation = await _quotationRepository.updateQuotation(quotation, token: _currentToken);

      // Update local state
      final updatedList = state.quotations.map((q) {
        return q.id == updatedQuotation.id ? updatedQuotation : q;
      }).toList();

      emit(state.copyWith(quotations: updatedList));
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to update quotation: $e');
      emit(state.copyWith(errorMessage: e.toString()));
      rethrow;
    }
  }

  // 4. 🗑️ Delete Quotation
  Future<void> deleteQuotation(String id) async {
    try {
      await _quotationRepository.deleteQuotation(id, token: _currentToken);

      // Remove from local state
      final updatedList = state.quotations.where((q) => q.id != id).toList();
      emit(state.copyWith(quotations: updatedList));
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to delete quotation: $e');
      emit(state.copyWith(errorMessage: e.toString()));
      rethrow;
    }
  }

  // 5. 💰 Add Payment to Quotation
  Future<void> addPayment(String id, Map<String, dynamic> paymentData) async {
    try {
      final updatedQuotation = await _quotationRepository.addPayment(id, paymentData, token: _currentToken);

      // Update local state
      final updatedList = state.quotations.map((q) {
        return q.id == updatedQuotation.id ? updatedQuotation : q;
      }).toList();

      emit(state.copyWith(quotations: updatedList));
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to add payment: $e');
      emit(state.copyWith(errorMessage: e.toString()));
      rethrow;
    }
  }

  // 6. 🔄 Convert Quotation to Invoice
  Future<QuotationDocument> convertToInvoice(String id, {List<Map<String, dynamic>>? advancePayments}) async {
    try {
      final convertedInvoice = await _quotationRepository.convertToInvoice(id, advancePayments: advancePayments, token: _currentToken);

      // Update local state
      final updatedList = state.quotations.map((q) {
        return q.id == convertedInvoice.id ? convertedInvoice : q;
      }).toList();

      emit(state.copyWith(quotations: updatedList));

      return convertedInvoice;
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to convert quotation: $e');
      emit(state.copyWith(errorMessage: e.toString()));
      rethrow;
    }
  }

  // 7. 📊 Update Quotation Status
  Future<void> updateQuotationStatus(String id, Map<String, dynamic> statusData) async {
    try {
      final updatedQuotation = await _quotationRepository.updateQuotationStatus(id, statusData, token: _currentToken);

      // Update local state
      final updatedList = state.quotations.map((q) {
        return q.id == updatedQuotation.id ? updatedQuotation : q;
      }).toList();

      emit(state.copyWith(quotations: updatedList));
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to update quotation status: $e');
      emit(state.copyWith(errorMessage: e.toString()));
      rethrow;
    }
  }

  // 7. 🎯 Select Quotation
  void selectQuotation(QuotationDocument? quotation) {
    emit(state.copyWith(selectedQuotation: quotation));
  }

  // 8. 🧹 Clear Error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
